import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../business/authentication.dart';
import 'homescreen.dart';
import 'loginScreen.dart';


class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {

  @override
  Widget build(BuildContext context) {

    final authService = context.read<AuthenticationService>();
    return WillPopScope(
      onWillPop: ()async{
        return false;
      },
      child: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen(authService: authService);
          } else {
            return const HomeScreen();
          }
        },
      ),
    );
  }
}