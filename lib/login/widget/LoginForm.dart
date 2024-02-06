import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../DashBord/HomeScreen.dart';
import '../../DashBord/ReaitimeData.dart';
import '../../constants/size.dart';
import '../../firebase_auth_implementation/firebase_auth_services.dart';
import '../../global/common/toast.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _isSigning = false;
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuthService _auth = FirebaseAuthService();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool _passwordVisible = false; // Add this line
  @override
  void dispose() {
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
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: tDefualtsize - 10),
        child: Column(
          children: [
            const SizedBox(height:10.0),
            buildTextFormField(
              controller: _emailController,
              labelText: "الايميل",
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 15.0),
            buildTextFormField(
              controller: _passwordController,
              labelText: "كلمة المرور",
              prefixIcon: Icons.password_rounded,
              obscureText: true, // Set this to true to hide the password
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signIn,
               child:_isSigning ? CircularProgressIndicator(color: Colors.white,): Text(

                  "تسجيل الدخول",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: responsiveFontSize(0.06),
                    fontFamily: "MyFont",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(prefixIcon),
          contentPadding: EdgeInsets.fromLTRB(0, 0, 16, 0),
          // Add the eye icon here as a suffix icon
    suffixIcon: labelText == "كلمة المرور" ? IconButton(
    icon: Icon(
    // Change the icon based on the state of _passwordVisible
    _passwordVisible ? Icons.visibility : Icons.visibility_off,
    ),
    onPressed: () {
    // Update the state to toggle password visibility
    setState(() {
    _passwordVisible = !_passwordVisible;
    });
    },
    ) : null,),
    obscureText: labelText == "كلمة المرور" ? !_passwordVisible : obscureText,
    validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  void _signIn() async {

    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = await _auth.signInWithEmailAndPassword(email, password);
    print("===============f======");

    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      showToast(message: "User is successfully signed in");
      print("=====================");
      UserData();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ChatterScreen(),
        ),
      );
    } else {
      showToast(message: "some error occured");
    }
  }

}
