import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lvoapp/features/chat/data/chat_repository.dart';
import 'package:lvoapp/features/chat/domain/message_model.dart';
import 'package:lvoapp/features/auth/domain/user_model.dart';
import 'package:lvoapp/features/auth/data/auth_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  chatId,
) {
  return ref.watch(chatRepositoryProvider).subscribeToMessages(chatId);
});

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final UserModel? otherUser;

  const ChatRoomScreen({super.key, required this.chatId, this.otherUser});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  UserModel? _otherUser;
  bool _isLoadingUser = false;

  @override
  void initState() {
    super.initState();
    _otherUser = widget.otherUser;

    // Mark messages as read when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRepositoryProvider).markMessagesAsRead(widget.chatId);
      if (_otherUser == null) {
        _loadOtherUser();
      }
    });
  }

  Future<void> _loadOtherUser() async {
    setState(() => _isLoadingUser = true);
    try {
      final currentUserId = ref.read(authRepositoryProvider).currentUser?.id;
      if (currentUserId == null) return;

      final supabase = Supabase.instance.client;

      // 1. Fetch participant user_id directly without join
      final participantResponse = await supabase
          .from('chat_participants')
          .select('user_id')
          .eq('chat_id', widget.chatId)
          .neq('user_id', currentUserId)
          .maybeSingle();

      if (participantResponse == null) return;

      final otherUserId = participantResponse['user_id'] as String;

      // 2. Fetch profile directly
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', otherUserId)
          .maybeSingle();

      if (profileResponse != null) {
        if (mounted) {
          setState(() {
            _otherUser = UserModel.fromJson(profileResponse);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _messageController.clear(); // Clear immediately for UX

    try {
      await ref
          .read(chatRepositoryProvider)
          .sendMessage(widget.chatId, content);

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      debugPrint('Validation error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim pesan: $e')));
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Hari Ini';
    } else if (dateToCheck == yesterday) {
      return 'Kemarin';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Fallback if user loading failed
    final user =
        _otherUser ??
        UserModel(
          id: 'unknown',
          email: '',
          username: 'Unknown User',
          createdAt: DateTime.now(),
        );

    final messagesState = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUserId = ref.watch(authRepositoryProvider).currentUser?.id;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.surface.withValues(alpha: 0.5),
            ),
          ),
        ),
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.grey.shade900,
              backgroundImage: user.avatarUrl != null
                  ? CachedNetworkImageProvider(user.avatarUrl!)
                  : null,
              child: user.avatarUrl == null
                  ? const Icon(
                      CupertinoIcons.person_fill,
                      size: 18,
                      color: Colors.white54,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              user.username,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F0F1A), // Very dark blue/black
                    Color(0xFF1A1A2E),
                    Color(0xFF201A30),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: messagesState.when(
                    data: (messages) {
                      debugPrint(
                        'UI: Loaded ${messages.length} messages for Chat ${widget.chatId}',
                      );
                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            'Mulai percakapan dengan ${user.username}',
                            style: GoogleFonts.inter(color: Colors.white30),
                          ),
                        ).animate().fadeIn();
                      }

                      // Process messages to inject date headers
                      final combinedList = <dynamic>[];
                      for (int i = 0; i < messages.length; i++) {
                        combinedList.add(messages[i]);
                        final currentMsgDate = messages[i].createdAt;
                        final nextMsgDate = (i + 1 < messages.length)
                            ? messages[i + 1].createdAt
                            : null;

                        if (nextMsgDate == null ||
                            !_isSameDay(currentMsgDate, nextMsgDate)) {
                          combinedList.add(_formatDateHeader(currentMsgDate));
                        }
                      }

                      return ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: combinedList.length,
                        itemBuilder: (context, index) {
                          final item = combinedList[index];

                          if (item is String) {
                            // Date Header
                            return Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          }

                          final message = item as MessageModel;
                          final isMe = message.senderId == currentUserId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child:
                                Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.75,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: isMe
                                            ? LinearGradient(
                                                colors: [
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              )
                                            : null,
                                        color: isMe
                                            ? null
                                            : Colors.white.withValues(
                                                alpha: 0.1,
                                              ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(20),
                                          topRight: const Radius.circular(20),
                                          bottomLeft: isMe
                                              ? const Radius.circular(20)
                                              : const Radius.circular(4),
                                          bottomRight: isMe
                                              ? const Radius.circular(4)
                                              : const Radius.circular(20),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            message.content,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _formatTime(message.createdAt),
                                                style: GoogleFonts.inter(
                                                  fontSize: 10,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                              if (isMe) ...[
                                                const SizedBox(width: 4),
                                                Icon(
                                                  message.isRead
                                                      ? Icons.done_all
                                                      : Icons.check,
                                                  size: 14,
                                                  color: message.isRead
                                                      ? Colors.lightBlueAccent
                                                      : Colors.white70,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                    .animate()
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      curve: Curves.easeOut,
                                    )
                                    .fadeIn(),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Text(
                        'Error: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),

                // Input Area
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                style: GoogleFonts.inter(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Tulis pesan...',
                                  hintStyle: GoogleFonts.inter(
                                    color: Colors.white30,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                ),
                                textCapitalization:
                                    TextCapitalization.sentences,
                                minLines: 1,
                                maxLines: 5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.primary,
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                              ),
                              child: IconButton(
                                onPressed: _sendMessage,
                                icon: const Icon(
                                  CupertinoIcons.arrow_up,
                                  color: Colors.white,
                                ),
                                tooltip: 'Kirim',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
