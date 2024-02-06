import 'package:flutter/material.dart';

import '../constants/size.dart';
import 'widget/LoginFooterWidget.dart';
import 'widget/LoginForm.dart';
import 'widget/LoginHeaderWidget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefualtsize),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LoginHeaderWidget(size: size),
                const LoginForm(),
                const LoginFooterWidget()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
