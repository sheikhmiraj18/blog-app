import 'package:flutter/material.dart';
import '../../models/blog_model.dart';
import '../screens/blog/blog_detail_screen.dart';

class BlogTile extends StatelessWidget {
  final Blog blog;

  const BlogTile({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          blog.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              blog.content.length > 100
                  ? "${blog.content.substring(0, 100)}..."
                  : blog.content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),
                Text(blog.authorUsername),
                const Spacer(),
                const Icon(Icons.favorite, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Text("${blog.likes.length}"),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlogDetailScreen(blog: blog),
            ),
          );
        },
      ),
    );
  }
}
