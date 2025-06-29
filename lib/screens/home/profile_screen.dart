import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/blog_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/blog_service.dart';
import '../blog/blog_detail_screen.dart';
import '../../../widgets/user_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final BlogService _blogService = BlogService();
  late TextEditingController _profileUrlController;
  late Future<List<Blog>> _userBlogsFuture;



  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _userBlogsFuture = _blogService.getBlogsByUser(user.uid).first;
      _profileUrlController = TextEditingController(text: user.profileImageUrl ?? '');
    }
  }

  @override
  void dispose() {
    _profileUrlController.dispose();
    super.dispose();
  }

  Widget _buildProfileImage(String? imageUrl) {
    try {
      if (imageUrl == null || imageUrl.isEmpty) {
        return Image.asset(
          'assets/placeholder.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );
      }

      return Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Image load error: $error');
          return Image.asset(
            'assets/placeholder.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          );
        },
      );
    } catch (e) {
      debugPrint('Exception in image loading: $e');
      return Image.asset(
        'assets/placeholder.png',
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
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

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('@${user.username}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Center(child: UserAvatar(imageUrl: user.profileImageUrl, size: 100)),
              const SizedBox(height: 16),


              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _profileUrlController,
                          decoration: InputDecoration(
                            labelText: 'Profile Image URL',
                            prefixIcon: const Icon(Icons.image_outlined),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final url = _profileUrlController.text.trim();
                          if (url.isNotEmpty) {
                            await Provider.of<AuthProvider>(context, listen: false).updateProfileImage(url);
                            setState(() {});
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(10),
                          elevation: 3,
                        ),
                        child: const Icon(Icons.check, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(user.username,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user.email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 20),


              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text('${user.followers.length}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('Followers', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('${user.following.length}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text('Following', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),


              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Blogs',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),


              FutureBuilder<List<Blog>>(
                future: _userBlogsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final blogs = snapshot.data ?? [];
                  if (blogs.isEmpty) {
                    return const Center(child: Text("You haven't posted any blogs yet."));
                  }

                  return Column(
                    children: blogs.map((blog) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(blog.title),
                          subtitle: Text('Likes: ${blog.likes.length}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => BlogDetailScreen(blog: blog)),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),


              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.black),
                  label: const Text(
                    "Logout",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Provider.of<AuthProvider>(context, listen: false).logout();
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
