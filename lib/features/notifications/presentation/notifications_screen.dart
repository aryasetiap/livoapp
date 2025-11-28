import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:livoapp/features/notifications/data/notification_repository.dart';
import 'package:livoapp/features/notifications/domain/notification_model.dart';
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
      appBar: AppBar(
        title: const Text(
          'Notifikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
              icon: const Icon(Icons.mark_email_read_outlined),
              tooltip: 'Tandai semua dibaca',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notificationsProvider);
        },
        child: notificationsState.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Center(child: Text('Belum ada notifikasi'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    onTap: () {
                      // Mark as read when tapped
                      if (!notification.isRead) {
                        ref
                            .read(notificationRepositoryProvider)
                            .markNotificationAsRead(notification.id);
                        ref.invalidate(notificationsProvider);
                      }
                      // Navigate based on notification type if needed
                    },
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage:
                          notification.relatedUser?.avatarUrl != null
                          ? CachedNetworkImageProvider(
                              notification.relatedUser!.avatarUrl!,
                            )
                          : null,
                      child: notification.relatedUser?.avatarUrl == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                    title: Text(
                      notification.displayTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification.body != null)
                          Text(
                            notification.body!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(notification.createdAt, locale: 'id'),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (notification.isRead)
                          const Icon(
                            Icons.mark_email_read,
                            color: Colors.grey,
                            size: 20,
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
    );
  }
}
