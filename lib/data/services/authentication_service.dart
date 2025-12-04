import 'dart:convert';

import 'package:first_flutter/data/models/user.dart';
import 'package:http/http.dart' as http;

abstract class IAuthenticationService {
  Future<User> validateLogin(String username, String password);
}

class AuthenticationService implements IAuthenticationService {
  @override
  Future<User> validateLogin(String username, String password) async {
    final url = Uri.parse('https://httpbin.org/basic-auth/admin/adminpassword');
    final response = await http.get(
      url,
      headers: {
        'Authorization':
            'Basic ${
              base64Encode(utf8.encode('$username:$password'))
              }',
      },
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)); // HTTP OK
    } else if (response.statusCode == 401) {
      throw Exception('Invalid credentials'); // HTTP Unauthorized
    } else {
      throw Exception('Login error'); // HTTP Error
    }
  }
}
