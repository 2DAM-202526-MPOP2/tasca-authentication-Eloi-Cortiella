import 'package:first_flutter/data/models/profile.dart';
import 'package:first_flutter/data/models/user.dart';
import 'package:first_flutter/data/services/authentication_service.dart';

abstract class IAuthenticationRepository {
  Future<User> get current;
  Future<User> validateLogin(String username, String password);
  Future<Profile> getProfile(User user);
}

class AuthenticationRepository implements IAuthenticationRepository {
  AuthenticationRepository({
    required IAuthenticationService authenticationService,
  }) : _authenticationService = authenticationService {
    // Usuari inicial "anònim"
    _currentUser = Future.value(
      User(
        username: '',
        authenticated: false,
        id: 0,
        email: '',
        accessToken: '',
      ),
    );
  }

  final IAuthenticationService _authenticationService;

  late Future<User> _currentUser;

  @override
  Future<User> get current => _currentUser;

  @override
  Future<User> validateLogin(String username, String password) {
    final futureUser = _authenticationService.validateLogin(username, password);
    // s'actualitza l'usuari a l'actual
    _currentUser = futureUser;
    return futureUser;
  }

  @override
  Future<Profile> getProfile(User user) {
    return _authenticationService.getProfile(user);
  }
}
