class UserModel {
  final int id;
  final String username;
  final String email;
  final String madhab;
  final String country;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.madhab,
    this.country = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      madhab: json['madhab'] ?? 'hanafi',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'madhab': madhab,
      'country': country,
    };
  }
}