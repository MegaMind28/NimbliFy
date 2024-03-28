import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../business/authentication.dart';

class AuthenticationProvider with ChangeNotifier {
  final AuthenticationService _authenticationService;
  User? _user;

  AuthenticationService get authenticationService => _authenticationService;
  User? get user => _user;

  AuthenticationProvider({
    required AuthenticationService authenticationService,
  }) : _authenticationService = authenticationService {
    _authenticationService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }
}
