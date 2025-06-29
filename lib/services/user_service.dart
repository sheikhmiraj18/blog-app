import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> createUser(AppUser user) async {
    await users.doc(user.uid).set(user.toMap());
  }

  Future<AppUser?> getUserById(String uid) async {
    DocumentSnapshot doc = await users.doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();

    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data()))
        .toList();
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    final currentUserRef = users.doc(currentUserId);
    final targetUserRef = users.doc(targetUserId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final currentUserDoc = await transaction.get(currentUserRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      if (!currentUserDoc.exists || !targetUserDoc.exists) return;

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final targetUserData = targetUserDoc.data() as Map<String, dynamic>;

      final following = List<String>.from(currentUserData['following'] ?? []);
      final followers = List<String>.from(targetUserData['followers'] ?? []);

      if (!following.contains(targetUserId)) {
        following.add(targetUserId);
        followers.add(currentUserId);

        transaction.update(currentUserRef, {'following': following});
        transaction.update(targetUserRef, {'followers': followers});
      }
    });
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final currentUserRef = users.doc(currentUserId);
    final targetUserRef = users.doc(targetUserId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final currentUserDoc = await transaction.get(currentUserRef);
      final targetUserDoc = await transaction.get(targetUserRef);

      if (!currentUserDoc.exists || !targetUserDoc.exists) return;

      final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
      final targetUserData = targetUserDoc.data() as Map<String, dynamic>;

      final following = List<String>.from(currentUserData['following'] ?? []);
      final followers = List<String>.from(targetUserData['followers'] ?? []);

      if (following.contains(targetUserId)) {
        following.remove(targetUserId);
        followers.remove(currentUserId);

        transaction.update(currentUserRef, {'following': following});
        transaction.update(targetUserRef, {'followers': followers});
      }
    });
  }

}
