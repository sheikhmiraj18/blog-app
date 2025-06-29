import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  final _userService = UserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AppUser? _user;
  AppUser? get user => _user;

  Future<void> loadUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      _user = await _userService.getUserById(firebaseUser.uid);
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = await _userService.getUserById(credential.user!.uid);
      notifyListeners();
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }


  Future<void> followUser(String targetUserId) async {
    if (_user == null || _user!.following.contains(targetUserId)) return;

    await _firestore.collection('users').doc(_user!.uid).update({
      'following': FieldValue.arrayUnion([targetUserId]),
    });

    _user!.following.add(targetUserId);
    notifyListeners();
  }

  Future<void> unfollowUser(String targetUserId) async {
    if (_user == null || !_user!.following.contains(targetUserId)) return;

    await _firestore.collection('users').doc(_user!.uid).update({
      'following': FieldValue.arrayRemove([targetUserId]),
    });

    _user!.following.remove(targetUserId);
    notifyListeners();
  }


  Future<void> refreshUser() async {
    if (_user == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    _user = AppUser.fromMap(userDoc.data()!..['uid'] = userDoc.id);

    notifyListeners();
  }


  Future<void> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        username: username,
        followers: [],
        following: [],
      );

      await _userService.createUser(newUser);
      _user = newUser;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


  void logout() async {
    await _firebaseAuth.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfileImage(String newUrl) async {
    if (_user == null) return;

    final userId = _user!.uid;

    await _firestore.collection('users').doc(userId).update({
      'profileImageUrl': newUrl,
    });

    _user = _user!.copyWith(profileImageUrl: newUrl);
    notifyListeners();

    final blogDocs = await _firestore
        .collection('blogs')
        .where('authorId', isEqualTo: userId)
        .get();

    for (final doc in blogDocs.docs) {
      await doc.reference.update({
        'authorProfileImageUrl': newUrl,
      });
    }
  }



}
