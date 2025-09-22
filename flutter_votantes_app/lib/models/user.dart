class User {
  final int id;
  final String name;
  final String email;
  final int type;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: json['type'],
      photoUrl: json['photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
      'photo_url': photoUrl,
    };
  }

  bool get isAdmin => type == 1;
}