import 'package:cloud_firestore/cloud_firestore.dart';


class Blog {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorUsername;
  final DateTime createdAt;
  final List<String> likes;
  final List<String> comments;
  final String? authorProfileImageUrl;


  Blog({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorUsername,
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
    this.authorProfileImageUrl,
  });

  factory Blog.fromMap(String id, Map<String, dynamic> data) {
    return Blog(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorId: data['authorId'] ?? '',
      authorUsername: data['authorUsername'] ?? '',
      authorProfileImageUrl: data['authorProfileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likes: List<String>.from(data['likes'] ?? []),
      comments: List<String>.from(data['comments'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'authorId': authorId,
      'authorUsername': authorUsername,
      'createdAt': createdAt,
      'likes': likes,
      'comments': comments,
      'authorProfileImageUrl': authorProfileImageUrl,
    };
  }


  Blog copyWith({
    String? id,
    String? title,
    String? content,
    String? authorId,
    String? authorUsername,
    DateTime? createdAt,
    List<String>? comments,
    String? authorProfileImageUrl,
  }) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      authorId: authorId ?? this.authorId,
      authorUsername: authorUsername ?? this.authorUsername,
      authorProfileImageUrl: authorProfileImageUrl ?? this.authorProfileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
    );
  }
}



