import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idea_chatbot/signup_screen.dart';
import 'package:provider/provider.dart';

import 'DashBord/style.dart';
import 'LoginWithGoogle/GoogleLogin.dart';
import 'DashBord/ReaitimeData.dart';
import 'choose.dart';
import 'constants/image_string.dart';
import 'global/common/toast.dart';
import '../../firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'Category.dart';


class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSigning = false;
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

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
    var googleSignInProvider = Provider.of<GoogleSignInProvider>(context, listen: false);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [kBlueDarkColor, kLightDarkColor],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset("assets/images/sss.svg", height: MediaQuery.of(context).size.height / 3,),
                  TextField(
                    controller: _emailController,

                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "الإيميل",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(kRaduis)),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  TextField(
                    controller: _passwordController,

                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "كلمة السر",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRaduis)),
                    ),
                  ),
                  const SizedBox(height: 35.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _signIn();
                      },
                      child:  Padding(
                        padding: EdgeInsets.all(20.0),
                        child:_isSigning ? SizedBox(
                          height: 20, // Specify the height you want
                          width: 20,  // Specify the width you want
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2, // You can adjust the strokeWidth for a thinner progress indicator
                          ),
                        )
                            : Text("تسجيل الدخول",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,

                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15.0),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                        onPressed: () async{
                          bool success = await googleSignInProvider.googleLogin();
                          if (success) {
                            // If the login was successful, proceed to the next screen or do something else
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => MyPage(),
                              ),
                            );  } else {
                            // If the login failed, display an error or do something else
                            showToast(message: "Failed to sign in with Google.");

                          }
                        },

                        icon: const Image(
                          image: AssetImage(Googlelogo),
                          width: 20.0,
                        ),
                        label: Text(
                          "تسجيل الدخول باستخدام جوجل",
                            style: TextStyle(color: Colors.white,fontSize: responsiveFontSize(0.03))


                        )
                    ),
                  ),

                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("لا يوجد لديك حساب ؟", style: TextStyle(color: Colors.white)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignupScreen(),
                            ),
                          );
                        },
                        child: const Text("إنشاء حساب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      showToast(message: "User is successfully signed in");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyPage(),
        ),
      );
    } else {
      showToast(message: "some error occured");
    }
  }

}
