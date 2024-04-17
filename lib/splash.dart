import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:idea_chatbot/global/common/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Category.dart';
import 'DashBord/HomeScreen.dart';
import 'DashBord/style.dart';
import 'login_screen.dart';
import 'on_boarding.dart';

class SplashScreen extends StatelessWidget {
  final bool onboardingShown;

  const SplashScreen({super.key, required this.onboardingShown});

  @override
  Widget build(BuildContext context) {
    // Simulating some initialization process
    Future.delayed(const Duration(seconds: 2), () async {
      if (FirebaseAuth.instance.currentUser != null ) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String? Selected_name = prefs.getString('Selected_name');
        if(Selected_name ==null){
          showToast(message: "قم باختيار جهة ");
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyPage()));
        }
        else{
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ChatterScreen()));
        }
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => onboardingShown ? LoginScreen() : OnboardingScreen()));
      }
    });
    // This is your splash screen
    return  Scaffold(
      backgroundColor: kBlueDarkColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: SvgPicture.asset("assets/images/sss.svg", height: MediaQuery.of(context).size.height / 8,),
              // Replace with your app name
            ),
          ],
        ),
      ),
    );
  }
}
