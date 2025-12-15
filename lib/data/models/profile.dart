class Profile {
  final String username;
  final int id;
  final String email;
  final String firstname;
  final String lastname;
  final String birthdate;
  Profile({
    required this.username,
    required this.id,
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.birthdate,
  });
  factory Profile.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'firstName': String firstname,
        'lastName': String lastname,
        'email': String email,
        'username': String username,
        'birthDate': String birthdate,
      } =>
        Profile(
          username: username,
          id: id,
          email: email,
          firstname: firstname,
          lastname: lastname,
          birthdate: birthdate,
        ),
      _ => throw const FormatException('Failed to load Profile.'),
    };
  }
}
