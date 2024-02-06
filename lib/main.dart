
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'DashBord/HomeScreen.dart';
import 'LoginWithGoogle/GoogleLogin.dart';
import 'firebase_options.dart';
import 'login/login_screen.dart';
import 'onboarding/on_boarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingShown = prefs.getBool('onboardingShown') ?? false;
  await prefs.setString('lang', 'Women');
  runApp(MyApp(onboardingShown: onboardingShown));
}

class MyApp extends StatelessWidget {
  final bool onboardingShown;

  MyApp({required this.onboardingShown});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(
          onboardingShown: onboardingShown,
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final bool onboardingShown;

  SplashScreen({required this.onboardingShown});

  @override
  Widget build(BuildContext context) {
    // Simulating some initialization process
    Future.delayed(Duration(seconds: 2), () {
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ChatterScreen()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => onboardingShown ? LoginScreen() : OnBoardingScreen()));
      }
    });

    // This is your splash screen
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image(
                image: const AssetImage("assets/logo/icon.png"),
              ), // Replace with your app name
            ),
          ],
        ),
      ),
    );
  }
}
