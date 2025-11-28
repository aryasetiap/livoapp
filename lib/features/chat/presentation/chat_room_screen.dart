import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livoapp/features/chat/data/chat_repository.dart';
import 'package:livoapp/features/chat/domain/message_model.dart';
import 'package:livoapp/features/auth/domain/user_model.dart';
import 'package:livoapp/features/auth/data/auth_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

final chatMessagesProvider = StreamProvider.family<List<MessageModel>, String>((
  ref,
  chatId,
) {
  return ref.watch(chatRepositoryProvider).subscribeToMessages(chatId);
});

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final UserModel otherUser;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.otherUser,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Mark messages as read when entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatRepositoryProvider).markMessagesAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(chatRepositoryProvider).sendMessage(widget.chatId, content);
    _messageController.clear();

    // Scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUserId = ref.watch(authRepositoryProvider).currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.otherUser.avatarUrl != null
                  ? CachedNetworkImageProvider(widget.otherUser.avatarUrl!)
                  : null,
              child: widget.otherUser.avatarUrl == null
                  ? const Icon(Icons.person, size: 16)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              widget.otherUser.username,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesState.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pesan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // Group messages or just show list
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade800,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomRight: isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message.content,
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(message.createdAt, locale: 'id'),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tulis pesan...',
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
