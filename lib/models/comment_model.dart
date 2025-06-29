class Comment {
  final String id;
  final String authorId;
  final String authorUsername;
  final String text;
  final DateTime createdAt;
  final String authorAvatarUrl;


  Comment({
    required this.id,
    required this.authorId,
    required this.authorUsername,
    required this.text,
    required this.createdAt,
    required this.authorAvatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorUsername': authorUsername,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'authorAvatarUrl': authorAvatarUrl,
    };
  }

  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    return Comment(
      id: id,
      authorId: map['authorId'],
      authorUsername: map['authorUsername'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
      authorAvatarUrl: map['authorAvatarUrl'] ?? '',
    );
  }
}
