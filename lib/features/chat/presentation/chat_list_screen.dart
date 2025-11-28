import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:livoapp/features/chat/data/chat_repository.dart';
import 'package:livoapp/features/chat/domain/chat_model.dart';
import 'package:livoapp/features/auth/data/auth_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

final chatsProvider = FutureProvider<List<ChatModel>>((ref) {
  return ref.watch(chatRepositoryProvider).getChats();
});

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsState = ref.watch(chatsProvider);
    final currentUserId = ref.watch(authRepositoryProvider).currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: chatsState.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pesan',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];

              if (chat.participants == null || chat.participants!.isEmpty) {
                return const SizedBox.shrink();
              }

              // Find other participant
              final otherUser = chat.participants!.firstWhere(
                (u) => u.id != currentUserId,
                orElse: () => chat.participants!.first,
              );

              return InkWell(
                onTap: () {
                  context.push('/chat/${chat.id}', extra: otherUser);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: otherUser.avatarUrl != null
                            ? CachedNetworkImageProvider(otherUser.avatarUrl!)
                            : null,
                        child: otherUser.avatarUrl == null
                            ? const Icon(Icons.person, size: 28)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    otherUser.username,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (chat.lastMessage != null)
                                  Text(
                                    timeago.format(
                                      chat.lastMessage!.createdAt,
                                      locale: 'id',
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (chat.lastMessage != null)
                              Text(
                                chat.lastMessage!.content,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color:
                                      chat.lastMessage!.isRead ||
                                          chat.lastMessage!.senderId ==
                                              currentUserId
                                      ? Colors.grey[400]
                                      : Colors.white,
                                  fontWeight:
                                      chat.lastMessage!.isRead ||
                                          chat.lastMessage!.senderId ==
                                              currentUserId
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              )
                            else
                              const Text(
                                'Mulai percakapan',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
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
    );
  }
}
