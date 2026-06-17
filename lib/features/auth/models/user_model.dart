class UserModel {
  final String uid;
  final String email;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.email,
    required this.isAdmin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'isAdmin': isAdmin,
    };
  }
}
