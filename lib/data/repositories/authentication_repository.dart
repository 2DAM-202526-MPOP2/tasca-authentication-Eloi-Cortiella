import 'package:first_flutter/data/models/user.dart';
import 'package:first_flutter/data/services/authentication_service.dart';

abstract class IAuthenticationRepository {
  Future<User> get current;
  Future<User> validateLogin(String username, String password);
}

class AuthenticationRepository implements IAuthenticationRepository {
  AuthenticationRepository({
    required IAuthenticationService authenticationService,
  }) : _authenticationService = authenticationService {
    // Usuari inicial "anònim"
    _currentUser = Future.value(
      User(username: '', authenticated: false),
    );
  }

  final IAuthenticationService _authenticationService;

  late Future<User> _currentUser;

  @override
  Future<User> get current => _currentUser;

  @override
  Future<User> validateLogin(String username, String password) {
    final futureUser =
        _authenticationService.validateLogin(username, password);
      // s'actualitza l'usuari a l'actual
    _currentUser = futureUser; 
    return futureUser;
  }
}

