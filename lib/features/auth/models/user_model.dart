class UserModel {
  final String uid;
  final String email;
  final bool isAdmin;
  final String? favoriteFuelType;
  final String? favoriteStationId;

  UserModel({
    required this.uid,
    required this.email,
    required this.isAdmin,
    this.favoriteFuelType,
    this.favoriteStationId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      favoriteFuelType: map['favoriteFuelType'],
      favoriteStationId: map['favoriteStationId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'isAdmin': isAdmin,
      'favoriteFuelType': favoriteFuelType,
      'favoriteStationId': favoriteStationId,
    };
  }
}
