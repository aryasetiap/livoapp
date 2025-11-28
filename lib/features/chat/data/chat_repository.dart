import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livoapp/features/chat/domain/chat_model.dart';
import 'package:livoapp/features/chat/domain/message_model.dart';
import 'package:livoapp/features/auth/domain/user_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(Supabase.instance.client);
});

class ChatRepository {
  final SupabaseClient _supabase;

  ChatRepository(this._supabase);

  Future<List<ChatModel>> getChats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // 1. Fetch chats where current user is a participant
      final response = await _supabase
          .from('chat_participants')
          .select('chat_id, chats(*)')
          .eq('user_id', userId);

      final chatsData = List<Map<String, dynamic>>.from(response);
      final List<ChatModel> chats = [];

      for (var chatData in chatsData) {
        try {
          if (chatData['chats'] == null) continue;

          final chat = chatData['chats'] as Map<String, dynamic>;
          final chatId = chat['id'] as String;

          // 2. Fetch participants for each chat
          final participantsResponse = await _supabase
              .from('chat_participants')
              .select('profiles(*)')
              .eq('chat_id', chatId);

          final participants = (participantsResponse as List)
              .where((p) => p['profiles'] != null)
              .map((p) {
                try {
                  final profile = Map<String, dynamic>.from(p['profiles']);

                  // Ensure ID is present
                  if (profile['id'] == null) {
                    // print('Warning: Participant has no ID in chat $chatId');
                    return null;
                  }

                  // Sanitize username
                  if (profile['username'] == null) {
                    profile['username'] = 'Unknown User';
                  }

                  // Sanitize created_at
                  if (profile['created_at'] == null) {
                    profile['created_at'] = DateTime.now().toIso8601String();
                  }

                  return UserModel.fromJson(profile);
                } catch (e) {
                  // print('Error parsing participant in chat $chatId: $e');
                  return null;
                }
              })
              .whereType<UserModel>()
              .toList();

          // 3. Fetch last message
          final lastMessageResponse = await _supabase
              .from('messages')
              .select()
              .eq('chat_id', chatId)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

          MessageModel? lastMessage;
          if (lastMessageResponse != null) {
            try {
              lastMessage = MessageModel.fromJson(lastMessageResponse);
            } catch (e) {
              // print('Error parsing last message in chat $chatId: $e');
            }
          }

          chats.add(
            ChatModel.fromJson({
              ...chat,
              'participants': participants.map((p) => p.toJson()).toList(),
              'last_message': lastMessage?.toJson(),
            }),
          );
        } catch (e) {
          // print('Error processing chat item: $e');
        }
      }

      // Sort by updated_at or last message time
      chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return chats;
    } catch (e) {
      // print('Error fetching chats: $e');
      return [];
    }
  }

  Future<List<MessageModel>> getMessages(String chatId) async {
    try {
      final response = await _supabase
          .from('messages')
          .select('*, profiles(*)') // Fetch sender profile
          .eq('chat_id', chatId)
          .order('created_at', ascending: true);

      return (response as List).map((json) {
        try {
          final messageData = Map<String, dynamic>.from(json);
          // Map profiles to sender
          if (messageData['profiles'] != null) {
            messageData['sender'] = messageData['profiles'];
          }
          return MessageModel.fromJson(messageData);
        } catch (e) {
          // print('Error parsing message: $e');
          rethrow;
        }
      }).toList();
    } catch (e) {
      // print('Error fetching messages: $e');
      return [];
    }
  }

  Future<void> sendMessage(String chatId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': userId,
        'content': content,
      });

      // Update chat updated_at
      await _supabase
          .from('chats')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', chatId);
    } catch (e) {
      // print('Error sending message: $e');
      rethrow;
    }
  }

  Future<String> createChat(String otherUserId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');

    // Check if chat already exists
    // Simplified check:
    final myChats = await getChats();
    for (var chat in myChats) {
      final participantIds = chat.participants?.map((u) => u.id).toSet();
      if (participantIds != null &&
          participantIds.contains(currentUserId) &&
          participantIds.contains(otherUserId) &&
          participantIds.length == 2) {
        return chat.id;
      }
    }

    // Create new chat
    final chatResponse = await _supabase
        .from('chats')
        .insert({
          'created_by': currentUserId,
        }) // ID and timestamps auto-generated
        .select()
        .single();

    final chatId = chatResponse['id'] as String;

    // Add participants
    await _supabase.from('chat_participants').insert([
      {'chat_id': chatId, 'user_id': currentUserId},
      {'chat_id': chatId, 'user_id': otherUserId},
    ]);

    return chatId;
  }

  Future<void> markMessagesAsRead(String chatId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _supabase
          .from('messages')
          .update({'is_read': true})
          .eq('chat_id', chatId)
          .neq('sender_id', userId)
          .eq('is_read', false);
    } catch (e) {
      // print('Error marking messages as read: $e');
    }
  }

  Stream<List<MessageModel>> subscribeToMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .map((maps) => maps.map((map) => MessageModel.fromJson(map)).toList());
  }
}
