class User {
  final int id;
  final String email;

  User({
    required this.id,
    required this.email,
  });

  factory User.fromJson(dynamic json) {
    var user = User(
      id: json['id'] as int,
      email: json["email"] as String,
    );
    return user;
  }
}
