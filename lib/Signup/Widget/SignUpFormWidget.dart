
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../DashBord/HomeScreen.dart';
import '../../DashBord/ReaitimeData.dart';
import '../../constants/size.dart';
import '../../firebase_auth_implementation/firebase_auth_services.dart';
import '../../global/common/toast.dart';

class SignUpFormWidget extends StatefulWidget {
  const SignUpFormWidget({
    super.key,
  });

  @override
  State<SignUpFormWidget> createState() => _SignUpFormWidgetState();
}

class _SignUpFormWidgetState extends State<SignUpFormWidget> {
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false; // Add this line

  bool isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    double responsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;

      return (screenWidth * scale).clamp(12.0, 18.0); // Ensures font size is between 12 and 36
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: tDefualtsize - 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              height: 50.0,
            ),
            Directionality(
              textDirection: TextDirection.rtl, // Set the text direction to right-to-left
              child: TextFormField(
                controller: _usernameController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: "اسم المستخدم",
                  prefixIcon: Icon(Icons.person),
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 16, 0), // Adjust content padding for the icon
                ),
              ),
            )
            ,
            const SizedBox(
              height: 10.0,
            ),
            Directionality(
              textDirection: TextDirection.rtl, // Set the text direction to right-to-left
              child: TextFormField(
                controller: _emailController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: "الايميل",
                  prefixIcon: Icon(Icons.email_outlined),
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 16, 0), // Adjust content padding for the icon
                ),
              ),
            )
            ,

            const SizedBox(
              height: 10.0,
            ),

        Directionality(
          textDirection: TextDirection.rtl, // Set the text direction to right-to-left
          child: TextFormField(
            controller: _passwordController,
            textAlign: TextAlign.right,
            obscureText: !_passwordVisible, // Use the _passwordVisible state here
            decoration: InputDecoration(
              labelText: "كلمة المرور",
              prefixIcon: Icon(Icons.password_sharp),
              // Add a suffix icon to toggle password visibility
              suffixIcon: IconButton(
                icon: Icon(
                  // Change the icon based on the _passwordVisible state
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  // Update the state to toggle visibility
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
              contentPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
            ),
          ),
        ),

            const SizedBox(
              height: 20.0,
            ),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: _signUp,
                    child: Text("انشاء حساب", style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(fontFamily:"MyFont",fontSize: responsiveFontSize(0.5), fontWeight: FontWeight.bold),
                    )))
          ],
        ),
      ),
    );
  }
  void _signUp() async {

    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
print(user);
    setState(() {
      isSigningUp = false;
    });
    if (user != null) {
      showToast(message: "User is successfully created");
      UserData();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChatterScreen(),
        ),
      );
    } else {
      showToast(message: "Some error happend");
    }
  }
}
