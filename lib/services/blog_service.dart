import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/blog_model.dart';
import '../models/comment_model.dart';

class BlogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> createBlog(Blog blog) async {
    final docRef = _firestore.collection('blogs').doc();
    final blogWithId = blog.copyWith(id: docRef.id);

    final blogData = blogWithId.toMap();
    blogData['authorProfileImageUrl'] = blog.authorProfileImageUrl ?? '';

    await docRef.set(blogData);
  }



  Stream<List<Blog>> getAllBlogs() {
    return _firestore
        .collection('blogs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Blog.fromMap(doc.id, doc.data())).toList());
  }


  Stream<List<Blog>> getBlogsByUser(String userId) {
    return _firestore
        .collection('blogs')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Blog.fromMap(doc.id, doc.data())).toList());
  }


  Future<void> deleteBlog(String blogId) async {
    await _firestore.collection('blogs').doc(blogId).delete();
  }


  Future<void> updateBlog({
    required String blogId,
    required String title,
    required String content,
  }) async {
    await _firestore.collection('blogs').doc(blogId).update({
      'title': title,
      'content': content,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }


  Future<void> updateLikes(String blogId, List<String> likes) async {
    await _firestore.collection('blogs').doc(blogId).update({'likes': likes});
  }

  Future<void> addComment(String blogId, Comment comment) async {
    await _firestore.collection('blogs')
        .doc(blogId)
        .collection('comments')
        .add(comment.toMap());
  }

  Stream<List<Comment>> getComments(String blogId) {
    return _firestore
        .collection('blogs')
        .doc(blogId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Comment.fromMap(doc.id, doc.data()))
        .toList());
  }



  Future<Blog?> getBlogById(String id) async {
    final doc = await _firestore.collection('blogs').doc(id).get();
    if (doc.exists) {
      return Blog.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
  Stream<List<Blog>> getBlogsByAuthorIds(List<String> authorIds) {
    if (authorIds.isEmpty) {
      return const Stream.empty();
    }

    return _firestore
        .collection('blogs')
        .where('authorId', whereIn: authorIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Blog.fromMap(doc.id, doc.data()))
        .toList());
  }




}
