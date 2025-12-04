import 'package:flutter/material.dart';

import 'package:first_flutter/data/repositories/authentication_repository.dart';
import 'package:first_flutter/data/models/user.dart';

class LoginVM extends ChangeNotifier {
  final IAuthenticationRepository _authenticationRepository;

  bool isLoading = false;
  late User _currentUser;

  LoginVM ({
    required IAuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository {
    _initCurrent();
  }

  Future<void> _initCurrent() async {
    isLoading = true;
    _currentUser = await _authenticationRepository.current;
    isLoading = false;
    notifyListeners();
  }

  // Getters
  User get currentUser => _currentUser;

  Future<User> validateLogin(String username, String password) {
    return _authenticationRepository.validateLogin(username, password);
  }
}
