class UserProfile {
  final String? imageUrl;
  final String userName;
  final String userEmail;

  UserProfile({
    this.imageUrl,
    required this.userName,
    required this.userEmail,
  });

  factory UserProfile.fromMap(Map<dynamic, dynamic> map, String? email) {
    return UserProfile(
      imageUrl: map['image']?.toString(),
      userName: map['username']?.toString() ?? 'User',
      userEmail: email ?? map['email']?.toString() ?? 'Smart User',
    );
  }
}