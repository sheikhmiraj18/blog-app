import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import 'user_avatar.dart';
class UserTile extends StatelessWidget {
  final AppUser user;
  final VoidCallback? onTap;

  const UserTile({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.user!;
    final isFollowing = currentUser.following.contains(user.uid);
    final isSelf = user.uid == currentUser.uid;

    return ListTile(
      leading: UserAvatar(imageUrl: user.profileImageUrl),
      title: Text(user.username),
      onTap: onTap,
      trailing: isSelf
          ? null
          : TextButton(
        onPressed: () {
          if (isFollowing) {
            authProvider.unfollowUser(user.uid);
          } else {
            authProvider.followUser(user.uid);
          }
        },
        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
      ),
    );
  }
}
