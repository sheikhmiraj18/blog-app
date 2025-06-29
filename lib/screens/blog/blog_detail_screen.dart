import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/blog_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/blog_service.dart';
import '../comments/comment_screen.dart';
import '../blog/edit_blog_screen.dart';
import '../../services/user_service.dart';
import '../home/user_profile_screen.dart';
import '../home/profile_screen.dart';
import '../../models/user_model.dart';
import '../../../widgets/user_avatar.dart';


class BlogDetailScreen extends StatefulWidget {
  final Blog blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final BlogService _blogService = BlogService();
  final UserService _userService = UserService();
  late Blog _blog;
  AppUser? _author;

  @override
  void initState() {
    super.initState();
    _blog = widget.blog;
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    final author = await _userService.getUserById(_blog.authorId);
    if (mounted && author != null) {
      setState(() {
        _author = author;
      });
    }
  }

  Future<void> _toggleLike(String userId) async {
    setState(() {
      if (_blog.likes.contains(userId)) {
        _blog.likes.remove(userId);
      } else {
        _blog.likes.add(userId);
      }
    });
    await _blogService.updateLikes(_blog.id, _blog.likes);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this blog?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),

        ],
      ),
    );

    if (confirmed == true) {
      await _blogService.deleteBlog(_blog.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAuthor = user.uid == _blog.authorId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          _blog.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: isAuthor
            ? [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black87),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditBlogScreen(blog: _blog)),
              );
              if (updated == true) {
                final refreshed = await _blogService.getBlogById(_blog.id);
                if (refreshed != null && mounted) {
                  setState(() => _blog = refreshed);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.black87),
            onPressed: _handleDelete,
          ),
        ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                UserAvatar(imageUrl: _author?.profileImageUrl ?? '', size: 40),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    final author = await _userService.getUserById(_blog.authorId);
                    if (author != null) {
                      final route = author.uid == user.uid
                          ? MaterialPageRoute(builder: (_) => const ProfileScreen())
                          : MaterialPageRoute(builder: (_) => UserProfileScreen(viewedUser: author));
                      Navigator.push(context, route);
                    }
                  },
                  child: Text(
                    _author?.username ?? _blog.authorUsername,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _toggleLike(user.uid),
                  child: Row(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _blog.likes.contains(user.uid)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          key: ValueKey(_blog.likes.contains(user.uid)),
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text('${_blog.likes.length}'),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),


            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _blog.content,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                ),
              ),
            ),

            const SizedBox(height: 20),


            Center(
              child: SizedBox(
                width: 250,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommentScreen(blog: _blog, currentUser: user),
                      ),
                    );
                  },
                  icon: const Icon(Icons.comment),
                  label: const Text("View Comments"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


}
