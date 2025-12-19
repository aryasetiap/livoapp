import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lvoapp/features/feed/data/post_repository.dart';
import 'package:lvoapp/features/feed/domain/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';

class PostItem extends ConsumerStatefulWidget {
  final PostModel post;
  final bool isDetail;

  const PostItem({super.key, required this.post, this.isDetail = false});

  @override
  ConsumerState<PostItem> createState() => _PostItemState();
}

class _PostItemState extends ConsumerState<PostItem> {
  late bool _isLiked;
  late int _likeCount;
  bool _showHeartOverlay = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likeCount;
  }

  @override
  void didUpdateWidget(PostItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post != widget.post) {
      _isLiked = widget.post.isLiked;
      _likeCount = widget.post.likeCount;
    }
  }

  Future<void> _sharePost() async {
    final postUrl = 'https://lvoapp.com/post/${widget.post.id}';
    final text =
        'Lihat postingan ${widget.post.username} di LVO:\n\n${widget.post.caption ?? ''}\n\n$postUrl';

    await Share.share(text);
  }

  Future<void> _toggleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    try {
      await ref.read(postRepositoryProvider).toggleLike(widget.post.id);
    } catch (e) {
      // Revert if failed
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03), // Glassmorphism background
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.black,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey.shade900,
                      backgroundImage: widget.post.avatarUrl != null
                          ? CachedNetworkImageProvider(widget.post.avatarUrl!)
                          : null,
                      child: widget.post.avatarUrl == null
                          ? const Icon(
                              CupertinoIcons.person_fill,
                              color: Colors.white54,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username ?? 'User',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        timeago.format(widget.post.createdAt, locale: 'id'),
                        style: GoogleFonts.inter(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    CupertinoIcons.ellipsis,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Image with Double Tap to Like
          if (widget.post.imageUrl.isNotEmpty)
            GestureDetector(
              onDoubleTap: () async {
                if (!_isLiked) {
                  _toggleLike();
                }
                setState(() {
                  _showHeartOverlay = true;
                });
                await Future.delayed(const Duration(milliseconds: 500));
                if (mounted) {
                  setState(() {
                    _showHeartOverlay = false;
                  });
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.post.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 400,
                      color: Colors.grey.shade900,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: Colors.grey.shade900,
                      child: const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                  if (_showHeartOverlay)
                    const Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.white,
                      size: 80,
                    ).animate().scale(duration: 400.ms).fadeOut(delay: 200.ms),
                ],
              ),
            ),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _toggleLike,
                      icon: Icon(
                        _isLiked
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: _isLiked
                            ? const Color(0xFFE91E63)
                            : Colors.white,
                        size: 26,
                      ),
                    ),
                    if (_likeCount > 0)
                      Text(
                        '$_likeCount Suka',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: widget.isDetail
                      ? null
                      : () {
                          context.push(
                            '/post/${widget.post.id}',
                            extra: widget.post,
                          );
                        },
                  icon: const Icon(
                    CupertinoIcons.chat_bubble,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                IconButton(
                  onPressed: _sharePost,
                  icon: const Icon(
                    CupertinoIcons.paperplane,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    CupertinoIcons.bookmark,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // Caption
          if (widget.post.caption != null && widget.post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: '${widget.post.username ?? 'User'} ',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
