import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lvoapp/features/chat/domain/chat_model.dart';
import 'package:lvoapp/features/chat/domain/message_model.dart';
import 'package:lvoapp/features/auth/domain/user_model.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

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

          // 4. Get unread count
          final unreadCount = await _supabase
              .from('messages')
              .count()
              .eq('chat_id', chatId)
              .eq('is_read', false)
              .neq('sender_id', userId);

          chats.add(
            ChatModel.fromJson({
              ...chat,
              'participants': participants.map((p) => p.toJson()).toList(),
              'last_message': lastMessage?.toJson(),
              'unread_count': unreadCount,
            }),
          );
        } catch (e) {
          // debugPrint('Error processing chat item: $e');
        }
      }

      // Sort by updated_at or last message time
      chats.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      // debugPrint('getChats: returning ${chats.length} chats');
      return chats;
    } catch (e) {
      // debugPrint('Error fetching chats: $e');
      return [];
    }
  }

  /// Returns a stream of chat lists that updates in real-time.
  Stream<List<ChatModel>> getChatsStream() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    // Create a stream controller to manage the data
    late final StreamController<List<ChatModel>> controller;

    // Subscription channels
    RealtimeChannel? participantsChannel;
    RealtimeChannel? messagesChannel;

    void fetchAndEmit() async {
      try {
        final chats = await getChats();
        if (!controller.isClosed) {
          controller.add(chats);
        }
      } catch (e) {
        // debugPrint('Error refreshing chats: $e');
      }
    }

    controller = StreamController<List<ChatModel>>(
      onListen: () {
        // 1. Initial Fetch
        fetchAndEmit();

        // 2. Listen for new chats (where I am added as participant)
        participantsChannel = _supabase.channel(
          'public:chat_participants:$userId',
        );
        participantsChannel!
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'chat_participants',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'user_id',
                value: userId,
              ),
              callback: (payload) {
                // debugPrint('New chat detected, refreshing...');
                fetchAndEmit();
              },
            )
            .subscribe();

        // 3. Listen for new messages (in chats I can see - relies on RLS)
        // Note: Listening to all messages might be heavy if not RLS filtered,
        // but Supabase Realtime respects RLS if enabled on the table and 'broadcast' is off/configured correctly.
        // Assuming RLS is set up properly for 'messages'.
        messagesChannel = _supabase.channel('public:messages_global');
        messagesChannel!
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'messages',
              callback: (payload) {
                // Ideally check if payload['new']['chat_id'] is in my known chats,
                // but for now, just refreshing is safer and simpler to ensure UI consistency.
                // debugPrint('New message detected, refreshing...');
                fetchAndEmit();
              },
            )
            .subscribe();
      },
      onCancel: () {
        participantsChannel?.unsubscribe();
        messagesChannel?.unsubscribe();
        controller.close();
      },
    );

    return controller.stream;
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
      // Temporarily wrapped in try-catch to prevent blocking message send
      try {
        await _supabase
            .from('chats')
            .update({'updated_at': DateTime.now().toIso8601String()})
            .eq('id', chatId);
      } catch (e) {
        // print('Error updating chat timestamp: $e');
      }
    } catch (e) {
      // print('Error sending message: $e');
      rethrow;
    }
  }

  Future<String> createChat(String otherUserId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) throw Exception('Not authenticated');

    // Self-Healing: Ensure current user has a profile before participating in chat
    // This prevents foreign key violation if profile trigger failed
    await _ensureProfileExists(currentUserId);

    // Check for existing chat using robust direct query
    final existingChatId = await _findExistingChatId(
      currentUserId,
      otherUserId,
    );
    if (existingChatId != null) {
      debugPrint('Found existing chat: $existingChatId');
      return existingChatId;
    }

    debugPrint('Creating new chat with $otherUserId');

    // Create new chat
    final chatResponse = await _supabase
        .from('chats')
        .insert({'created_by': currentUserId})
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

  Future<String?> _findExistingChatId(
    String myUserId,
    String otherUserId,
  ) async {
    try {
      // 1. Get all chat_ids where I am a participant
      final myChatsRes = await _supabase
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', myUserId);

      final myChatIds = (myChatsRes as List)
          .map((e) => e['chat_id'] as String)
          .toList();

      if (myChatIds.isEmpty) return null;

      // 2. Check if otherUserId is in any of these chats
      final commonRes = await _supabase
          .from('chat_participants')
          .select('chat_id')
          .eq('user_id', otherUserId)
          .filter('chat_id', 'in', myChatIds)
          .maybeSingle();

      if (commonRes != null) {
        return commonRes['chat_id'] as String;
      }
    } catch (e) {
      debugPrint('Error finding existing chat: $e');
    }
    return null;
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

  Future<int> getTotalUnreadCount() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return 0;

    try {
      final response = await _supabase
          .from('messages')
          .count()
          .eq('is_read', false)
          .neq('sender_id', userId);

      return response;
    } catch (e) {
      return 0;
    }
  }

  Stream<List<MessageModel>> subscribeToMessages(String chatId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .map((maps) {
          debugPrint(
            'Stream received ${maps.length} raw messages for chat $chatId',
          );
          return maps
              .map((map) {
                try {
                  return MessageModel.fromJson(map);
                } catch (e) {
                  debugPrint('Error parsing message: $e, map: $map');
                  return null;
                }
              })
              .whereType<MessageModel>()
              .toList();
        });
  }

  Future<void> _ensureProfileExists(String userId) async {
    try {
      final exists = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (exists == null) {
        debugPrint('createChat: Profile missing for $userId, auto-creating...');
        final currentUser = _supabase.auth.currentUser;
        if (currentUser != null && currentUser.id == userId) {
          final username =
              currentUser.userMetadata?['username'] ??
              currentUser.email?.split('@')[0] ??
              'User';

          await _supabase.from('profiles').insert({
            'id': userId,
            'username': username,
            'full_name': username,
            // 'email': currentUser.email, // Removed: No email column
            // 'created_at': DateTime.now().toIso8601String(), // Optional
          });
        }
      }
    } catch (e) {
      debugPrint('Error ensuring profile exists: $e');
    }
  }
}
