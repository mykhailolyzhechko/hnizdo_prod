class CurrentUser {
  final String uid;
  final String email;

  const CurrentUser({
    this.uid = '',
    this.email = '',
  });

  // Create from Firebase Database map
  factory CurrentUser.fromMap(Map<String, dynamic> map, String uid) {
    return CurrentUser(
      uid: uid,
      email: map['email'] ?? '',
    );
  }

  // Copy with method for immutability
  CurrentUser copyWith({
    String? uid,
    String? email,
    DateTime? createdAt,
    Map<String, dynamic>? additionalData,
  }) {
    return CurrentUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
    );
  }

  // Convert to map for database storage
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'email': email,
    };

    return map;
  }

  // Check if user is logged in
  bool get isLoggedIn => uid.isNotEmpty;
}
