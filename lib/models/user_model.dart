class AppUser {
  final String uid;
  final String username;
  final String email;
  final List<String> followers;
  final List<String> following;
  final String? profileImageUrl;

  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    this.followers = const [],
    this.following = const [],
    this.profileImageUrl,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      username: data['username'],
      email: data['email'],
      profileImageUrl: data['profileImageUrl'],
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'username': username,
    'email': email,
    'profileImageUrl': profileImageUrl,
    'followers': followers,
    'following': following,
  };

  AppUser copyWith({
    String? uid,
    String? email,
    String? username,
    String? profileImageUrl,
    List<String>? followers,
    List<String>? following,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
    );
  }

}
