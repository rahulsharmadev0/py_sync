class User {
  final String username;
  final String jwtToken;

  const User({required this.username, required this.jwtToken});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] as String,
      jwtToken: json['jwt_token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'jwt_token': jwtToken};
  }

  User copyWith({String? username, String? jwtToken}) {
    return User(username: username ?? this.username, jwtToken: jwtToken ?? this.jwtToken);
  }

  @override
  String toString() {
    return 'User(username: $username, jwtToken: $jwtToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.username == username && other.jwtToken == jwtToken;
  }

  @override
  int get hashCode {
    return username.hashCode ^ jwtToken.hashCode;
  }
}
