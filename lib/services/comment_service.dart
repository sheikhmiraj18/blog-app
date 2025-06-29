import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addComment(String blogId, Comment comment) async {
    await _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .add(comment.toMap());
  }

  Stream<List<Comment>> getComments(String blogId) {
    return _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Comment.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> deleteComment(String blogId, String commentId) async {
    await FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .doc(commentId)
        .delete();
  }

  Future<void> updateComment(String blogId, String commentId, String newText) async {
    await FirebaseFirestore.instance
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .doc(commentId)
        .update({'text': newText});
  }

}
