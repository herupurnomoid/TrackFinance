class UserProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  @override
  String toString() => 'UserProfile(uid: $uid, displayName: $displayName, email: $email)';
}
