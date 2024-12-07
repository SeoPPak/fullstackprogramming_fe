class User {
  final String uid;
  final String email;
  final String name;

  User({
    required this.uid,
    required this.email,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json['uid'],
    email: json['email'],
    name: json['name'],
  );
}