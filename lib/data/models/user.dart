class User {
  final String username;
  final bool authenticated;
  User({required this.username, required this.authenticated});
  factory User.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {'authenticated': bool authenticated, 'user': String username} => User(
        username: username,
        authenticated: authenticated,
      ),
      _ => throw const FormatException('Failed to load User.'),
    };
  }
}
