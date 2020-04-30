class User {
  final String name;
  final String email;
  final String password;

  User({this.name, this.email, this.password});

  factory User.fromMap(Map<String, dynamic> data) {
    return User(name: data['name'], email: data['email'], password: data['password']);
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "password": password
    };
  }
}