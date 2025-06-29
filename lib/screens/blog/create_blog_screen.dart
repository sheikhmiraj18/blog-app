import 'package:flutter/material.dart';
import '../../models/blog_model.dart';
import '../../services/blog_service.dart';
import '../../models/user_model.dart';
import '../../widgets/user_avatar.dart';

class CreateBlogScreen extends StatefulWidget {
  final AppUser currentUser;
  final VoidCallback? onPostSuccess;

  const CreateBlogScreen({
    super.key,
    required this.currentUser,
    this.onPostSuccess,
  });

  @override
  State<CreateBlogScreen> createState() => _CreateBlogScreenState();
}

class _CreateBlogScreenState extends State<CreateBlogScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final BlogService _blogService = BlogService();

  bool _loading = false;
  String? _error;

  Future<void> _handlePost() async {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      setState(() => _error = 'Title and content cannot be empty.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final blog = Blog(
        id: '',
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: widget.currentUser.uid,
        authorUsername: widget.currentUser.username,
        authorProfileImageUrl: widget.currentUser.profileImageUrl,
        createdAt: DateTime.now(),
        likes: [],
        comments: [],
      );

      await _blogService.createBlog(blog);
      widget.onPostSuccess?.call();
    } catch (e) {
      setState(() => _error = 'Failed to post blog.');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;

      return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text(
            'Create Blog',
            style: TextStyle(color: Colors.black87),
          ),
          iconTheme: const IconThemeData(color: Colors.black87),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    UserAvatar(imageUrl: user.profileImageUrl, size: 48),
                    const SizedBox(width: 12),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter blog title...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),


                TextField(
                  controller: _contentController,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText: 'Write your blog content here...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),


                SizedBox(
                  width: double.infinity,
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: _handlePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Post Blog',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
