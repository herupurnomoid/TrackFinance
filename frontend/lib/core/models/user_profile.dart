class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    DateTime? parsedCreatedAt;
    if (map['createdAt'] != null) {
      if (map['createdAt'] is DateTime) {
        parsedCreatedAt = map['createdAt'] as DateTime;
      } else if (map['createdAt'] is String) {
        parsedCreatedAt = DateTime.tryParse(map['createdAt'] as String);
      }
    }

    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'UserProfile(uid: $uid, displayName: $displayName, email: $email, createdAt: $createdAt)';
}
