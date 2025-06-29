import 'package:flutter/material.dart';
import '../models/blog_model.dart';
import '../services/blog_service.dart';

class BlogProvider with ChangeNotifier {
  final BlogService _service = BlogService();
  List<Blog> _blogs = [];

  List<Blog> get blogs => _blogs;

  void listenToBlogs() {
    _service.getAllBlogs().listen((data) {
      _blogs = data;
      notifyListeners();
    });
  }
}
