import 'package:first_flutter/data/models/user.dart';
import 'package:first_flutter/data/services/authentication_service.dart';

abstract class IAuthenticationRepository {
  Future<User> get current;
  Future<User> validateLogin(String username, String password);
}

class AuthenticationRepository implements IAuthenticationRepository {
  AuthenticationRepository({
    required IAuthenticationService authenticationService,
  }) : _authenticationService = authenticationService;

  final IAuthenticationService _authenticationService;

  late var _currentUser = _authenticationService.validateLogin('','');


  @override
  Future<User> get current => _currentUser;

  @override
  Future<User> validateLogin(String username, String password) {
    return _authenticationService.validateLogin(username, password);
  }
}
