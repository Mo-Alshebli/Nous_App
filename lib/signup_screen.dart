import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idea_chatbot/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DashBord/style.dart';
import 'LoginWithGoogle/GoogleLogin.dart';
import 'DashBord/ReaitimeData.dart';
import 'constants/image_string.dart';
import 'firebase_auth_implementation/firebase_auth_services.dart';
import 'global/common/toast.dart';
import 'Category.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();

  TextEditingController _emailController = TextEditingController();

  TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;
 // Add this line
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
    var googleSignInProvider = Provider.of<GoogleSignInProvider>(context, listen: false);

    double responsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;

      return (screenWidth * scale).clamp(12.0, 18.0); // Ensures font size is between 12 and 36
    }

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
                  SvgPicture.asset("assets/images/sss.svg", height: MediaQuery.of(context).size.height / 4,),
                  TextField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "اسم المستخدم",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRaduis)),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  TextField(
                    controller: _emailController,

                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "الإيميل",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRaduis)),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible, // Use the _passwordVisible state here

                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "كلمة السر",
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRaduis)),
                      // prefixIcon: Icon(Icons.password_sharp),
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
                    ),
                  ),

                  const SizedBox(height: 35.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {_signUp();},
                      child: const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("إنشاء حساب",
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
                            showToast(message: "مشكلة اثناء التسجيل الدخول بواسطة جوجل");

                          }
                        },
                        icon: const Image(
                          image: AssetImage(Googlelogo),
                          width: 20.0,
                        ),
                        label:  Text("إنشاء حساب بواسطة جوجل",
                            style: TextStyle(color: Colors.white,fontSize: responsiveFontSize(0.03))

                        ),
                      )),

                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text("لديك حساب بالفعل ؟", style: TextStyle(color: Colors.white)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: const Text("تسجيل الدخول", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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


  void _signUp() async {

    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);

    User? user = await _auth.signUpWithEmailAndPassword(email, password);
    print(user);
    setState(() {
      isSigningUp = false;
    });
    if (user != null) {
      showToast(message: "تم إنشاء حساب بنجاح😍");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyPage(),
        ),
      );
    } else {
      showToast(message: "حدث خطاء اثناء التسجيل لم استطيع ايجاد المستخدم");
    }
  }

}
