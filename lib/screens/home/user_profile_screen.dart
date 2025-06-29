import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/blog_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/blog_service.dart';
import '../../services/user_service.dart';
import '../blog/blog_detail_screen.dart';
import '../../widgets/user_avatar.dart';


class UserProfileScreen extends StatefulWidget {
  final AppUser viewedUser;

  const UserProfileScreen({super.key, required this.viewedUser});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final BlogService _blogService = BlogService();
  final UserService _userService = UserService();

  late Future<List<Blog>> _userBlogsFuture;

  @override
  void initState() {
    super.initState();
    _userBlogsFuture = _blogService.getBlogsByUser(widget.viewedUser.uid).first;
  }

  Future<void> _toggleFollow(AuthProvider authProvider) async {
    try {
      final currentUser = authProvider.user;
      if (currentUser == null) {
        debugPrint('[ERROR] No current user found.');
        return;
      }

      final targetUid = widget.viewedUser.uid;

      if (currentUser.following.contains(targetUid)) {
        debugPrint('Attempting to unfollow user: $targetUid');
        await _userService.unfollowUser(currentUser.uid, targetUid);
      } else {
        debugPrint('Attempting to follow user: $targetUid');
        await _userService.followUser(currentUser.uid, targetUid);
      }


      await authProvider.refreshUser();


      final updatedViewedUser = await _userService.getUserById(targetUid);

      if (updatedViewedUser != null) {
        setState(() {
          widget.viewedUser.followers
            ..clear()
            ..addAll(updatedViewedUser.followers);
          widget.viewedUser.following
            ..clear()
            ..addAll(updatedViewedUser.following);
        });
      }

    } catch (e, stack) {
      debugPrint('[ERROR] Failed to follow/unfollow: $e');
      debugPrint(stack.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong: $e')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user;
    final viewedUser = widget.viewedUser;
    final isFollowing = currentUser?.following.contains(viewedUser.uid) ?? false;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '@${viewedUser.username}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            Center(child: UserAvatar(imageUrl: viewedUser.profileImageUrl, size: 100)),
            const SizedBox(height: 16),


            ElevatedButton.icon(
              icon: Icon(isFollowing ? Icons.person_remove : Icons.person_add),
              label: Text(isFollowing ? 'Unfollow' : 'Follow'),
              onPressed: () => _toggleFollow(authProvider),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 16),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text('${viewedUser.followers.length}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Followers', style: TextStyle(fontSize: 16)),
                  ],
                ),
                Column(
                  children: [
                    Text('${viewedUser.following.length}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Text('Following', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),


            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'User Blogs',
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
                  return const Center(child: Text("No blogs yet."));
                }

                return Column(
                  children: blogs.map((blog) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                      child: ListTile(
                        title: Text(blog.title),
                        subtitle: Text('Likes: ${blog.likes.length}'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BlogDetailScreen(blog: blog)),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

}
