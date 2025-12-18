import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lvoapp/core/config/theme.dart';
import 'package:lvoapp/features/chat/data/chat_repository.dart';
import 'package:lvoapp/features/chat/domain/chat_model.dart';
import 'package:lvoapp/features/auth/data/auth_repository.dart';
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
        title: Text(
          'Pesan',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
                    AppTheme.backgroundColor,
                    Color(0xFF1A1A2E), // Deep Dark Blue
                    Color(0xFF2D1B4E), // Deep Purple
                    Colors.black,
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // 2. Ambient Orbs (Animated)
          Positioned(
            top: 50,
            right: -100,
            child:
                ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                        ),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.2, 1.2),
                      duration: 6.seconds,
                    ),
          ),

          // 3. Content
          SafeArea(
            child: chatsState.when(
              data: (chats) {
                if (chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.chat_bubble_2,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada pesan',
                          style: GoogleFonts.inter(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];

                    if (chat.participants == null ||
                        chat.participants!.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Find other participant
                    final otherUser = chat.participants!.firstWhere(
                      (u) => u.id != currentUserId,
                      orElse: () => chat.participants!.first,
                    );

                    return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              context.push(
                                '/chat/${chat.id}',
                                extra: otherUser,
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: CircleAvatar(
                                      radius: 26,
                                      backgroundColor: Colors.grey.shade900,
                                      backgroundImage:
                                          otherUser.avatarUrl != null
                                          ? CachedNetworkImageProvider(
                                              otherUser.avatarUrl!,
                                            )
                                          : null,
                                      child: otherUser.avatarUrl == null
                                          ? const Icon(
                                              CupertinoIcons.person_fill,
                                              size: 24,
                                              color: Colors.white54,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                otherUser.username,
                                                style: GoogleFonts.outfit(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white,
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
                                                  allowFromNow: true,
                                                ),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  color: Colors.white30,
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
                                            style: GoogleFonts.inter(
                                              color:
                                                  chat.lastMessage!.isRead ||
                                                      chat
                                                              .lastMessage!
                                                              .senderId ==
                                                          currentUserId
                                                  ? Colors.white54
                                                  : Colors.white,
                                              fontWeight:
                                                  chat.lastMessage!.isRead ||
                                                      chat
                                                              .lastMessage!
                                                              .senderId ==
                                                          currentUserId
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                            ),
                                          )
                                        else
                                          Text(
                                            'Mulai percakapan',
                                            style: GoogleFonts.inter(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (chat.lastMessage != null &&
                                      !chat.lastMessage!.isRead &&
                                      chat.lastMessage!.senderId !=
                                          currentUserId)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .animate(delay: (index * 50).ms)
                        .slideX(begin: 0.1, end: 0, curve: Curves.easeOut)
                        .fadeIn();
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
