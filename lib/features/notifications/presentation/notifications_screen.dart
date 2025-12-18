import 'dart:ui' as ui;
import 'package:go_router/go_router.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:lvoapp/core/config/theme.dart';
import 'package:lvoapp/features/notifications/data/notification_repository.dart';
import 'package:lvoapp/features/notifications/domain/notification_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) {
  return ref.watch(notificationRepositoryProvider).getUserNotifications();
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);

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
          'Notifikasi',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (notificationsState.hasValue &&
              notificationsState.value!.any((n) => !n.isRead))
            IconButton(
              onPressed: () {
                ref
                    .read(notificationRepositoryProvider)
                    .markAllNotificationsAsRead();
                ref.invalidate(notificationsProvider);
              },
              icon: const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: Colors.blueAccent,
              ),
              tooltip: 'Tandai semua dibaca',
            ),
        ],
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

          // 2. Animated Orbs
          Positioned(
            top: -50,
            left: -50,
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
          Positioned(
            bottom: 100,
            right: -50,
            child:
                ImageFiltered(
                      imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                    )
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1, 1),
                      duration: 5.seconds,
                    ),
          ),

          // 3. Content
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
            },
            child: notificationsState.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.bell_slash,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada notifikasi',
                          style: GoogleFonts.inter(color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.only(
                    top:
                        MediaQuery.of(context).padding.top +
                        kToolbarHeight +
                        16,
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ui.ImageFilter.blur(
                                sigmaX: 10,
                                sigmaY: 10,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: notification.isRead
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Theme.of(context).colorScheme.primary
                                            .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: notification.isRead
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Theme.of(context).colorScheme.primary
                                              .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  onTap: () {
                                    if (!notification.isRead) {
                                      ref
                                          .read(notificationRepositoryProvider)
                                          .markNotificationAsRead(
                                            notification.id,
                                          );
                                      ref.invalidate(notificationsProvider);
                                    }

                                    if ((notification.isLike ||
                                            notification.isComment) &&
                                        notification.relatedId != null) {
                                      context.push(
                                        '/post/${notification.relatedId}',
                                      );
                                    } else if (notification.isFollow &&
                                        notification.relatedUserId != null) {
                                      context.push(
                                        '/profile/${notification.relatedUserId}',
                                      );
                                    }
                                  },
                                  leading: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context).colorScheme.primary,
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.black,
                                      backgroundImage:
                                          notification.relatedUser?.avatarUrl !=
                                              null
                                          ? CachedNetworkImageProvider(
                                              notification
                                                  .relatedUser!
                                                  .avatarUrl!,
                                            )
                                          : null,
                                      child:
                                          notification.relatedUser?.avatarUrl ==
                                              null
                                          ? const Icon(
                                              CupertinoIcons.person_fill,
                                              size: 20,
                                              color: Colors.white70,
                                            )
                                          : null,
                                    ),
                                  ),
                                  title: Text(
                                    notification.displayTitle,
                                    style: GoogleFonts.outfit(
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (notification.body != null)
                                        Text(
                                          notification.body!,
                                          style: GoogleFonts.inter(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      const SizedBox(height: 6),
                                      Text(
                                        timeago.format(
                                          notification.createdAt,
                                          locale: 'id',
                                        ),
                                        style: GoogleFonts.inter(
                                          color: Colors.white30,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: !notification.isRead
                                      ? Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    .withValues(alpha: 0.5),
                                                blurRadius: 5,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        )
                        .animate(delay: (50 * index).ms)
                        .slideX(begin: 0.2, end: 0)
                        .fadeIn();
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
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
