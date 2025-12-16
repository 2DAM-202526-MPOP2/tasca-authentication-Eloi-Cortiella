import 'package:flutter/material.dart';
import 'package:first_flutter/data/models/profile.dart';
import 'package:first_flutter/data/models/user.dart';
import 'package:first_flutter/data/repositories/authentication_repository.dart';

class ProfileVM extends ChangeNotifier {
  final IAuthenticationRepository _authenticationRepository;

  ProfileVM({required IAuthenticationRepository authenticationRepository})
    : _authenticationRepository = authenticationRepository;

  Profile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadProfile(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _authenticationRepository.getProfile(user);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
