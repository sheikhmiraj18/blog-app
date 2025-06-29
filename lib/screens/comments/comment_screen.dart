import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/comment_model.dart';
import '../../models/blog_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/comment_service.dart';
import '../../widgets/user_avatar.dart';

class CommentScreen extends StatefulWidget {
  final Blog blog;
  final AppUser currentUser;

  const CommentScreen({
    super.key,
    required this.blog,
    required this.currentUser,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService _commentService = CommentService();
  bool _loading = false;
  String? _error;

  Future<void> _addComment(AppUser currentUser) async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final comment = Comment(
        id: '',
        authorId: currentUser.uid,
        authorUsername: currentUser.username,
        text: _commentController.text.trim(),
        createdAt: DateTime.now(),
        authorAvatarUrl: currentUser.profileImageUrl ?? '',
      );
      await _commentService.addComment(widget.blog.id, comment);
      _commentController.clear();
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("You must be logged in to comment.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Comments"),
      ),

      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: _commentService.getComments(widget.blog.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      "No comments yet.",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  reverse: true,
                  itemCount: comments.length,
                  itemBuilder: (_, index) {
                    final c = comments[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserAvatar(
                            imageUrl: c.authorAvatarUrl,
                            size: 40,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        c.authorUsername,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        timeago.format(c.createdAt),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      if (c.authorId == currentUser.uid || widget.blog.authorId == currentUser.uid)
                                        PopupMenuButton<String>(
                                          onSelected: (value) async {
                                            if (value == 'edit') {
                                              final newText = await showDialog<String>(
                                                context: context,
                                                builder: (context) {
                                                  final controller = TextEditingController(text: c.text);
                                                  return AlertDialog(
                                                    title: const Text('Edit Comment'),
                                                    content: TextField(
                                                      controller: controller,
                                                      decoration: const InputDecoration(hintText: 'Edit your comment'),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        child: const Text('Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, controller.text),
                                                        child: const Text('Save'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );

                                              if (newText != null &&
                                                  newText.trim().isNotEmpty &&
                                                  newText != c.text) {
                                                await _commentService.updateComment(
                                                  widget.blog.id,
                                                  c.id,
                                                  newText.trim(),
                                                );
                                              }
                                            } else if (value == 'delete') {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Delete Comment'),
                                                  content: const Text('Are you sure you want to delete this comment?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, false),
                                                      child: const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirm == true) {
                                                await _commentService.deleteComment(widget.blog.id, c.id);
                                              }
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            if (c.authorId == currentUser.uid)
                                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                          ],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    c.text,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1.2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.grey, Colors.transparent],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _loading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : IconButton(
                    icon: const Icon(Icons.send, color: Colors.blueAccent),
                    onPressed: () => _addComment(currentUser),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
