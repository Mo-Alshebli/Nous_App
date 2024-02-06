import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'DashBord/HomeScreen.dart';
import 'login/login_screen.dart';

class AuthenticationRepository extends StatefulWidget {
  const AuthenticationRepository({Key? key}) : super(key: key);

  @override
  _AuthenticationRepositoryState createState() => _AuthenticationRepositoryState();
}

class _AuthenticationRepositoryState extends State<AuthenticationRepository> {
  bool? authenticated;

  @override
  void initState() {
    super.initState();
    checkAuthenticationStatus();
  }

  Future<void> checkAuthenticationStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? action = prefs.getString('Uid');
    if (action != null) {
      setState(() {
        authenticated = true;
      });
    } else {
      setState(() {
        authenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (authenticated == null) {
      // If the authentication status is not determined yet, return a loading indicator or another widget.
      return CircularProgressIndicator(); // You can replace this with your loading widget.
    } else if (authenticated!) {
      return ChatterScreen(); // Return the home screen widget when authenticated.
    } else {
      return LoginScreen(); // Return the login screen widget when not authenticated.
    }
  }
}
