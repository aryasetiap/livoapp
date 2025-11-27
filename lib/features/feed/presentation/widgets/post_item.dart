import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:livoapp/features/feed/domain/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostItem extends StatelessWidget {
  final PostModel post;

  const PostItem({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: post.avatarUrl != null
                    ? CachedNetworkImageProvider(post.avatarUrl!)
                    : null,
                child: post.avatarUrl == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.username ?? 'User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    timeago.format(post.createdAt, locale: 'id'),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CachedNetworkImage(
            imageUrl: post.imageUrl,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 300,
              color: Colors.grey.shade900,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 300,
              color: Colors.grey.shade900,
              child: const Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
        if (post.caption != null && post.caption!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              post.caption!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.favorite_border, color: Colors.white),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }
}
