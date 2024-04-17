import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idea_chatbot/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'DashBord/style.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {

  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlueDarkColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: OnBoardingSlider(
            finishButtonText: 'إنشاء حساب',
            onFinish: () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('onboardingShown', true);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignupScreen(),
                ),
              );
            },
            finishButtonStyle: const FinishButtonStyle(
              backgroundColor: kOrangeColor,
            ),
            skipTextButton: const Text(
              '',
              style: TextStyle(
                fontSize: 18,
                color: kOrangeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontSize: 18,
                color: kGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailingFunction: () async {
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setBool('onboardingShown', true);
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) =>  LoginScreen(),
                ),
              );
            },
            controllerColor: kGreen,
            totalPage: 3,
            headerBackgroundColor: kBlueDarkColor,
            pageBackgroundColor: kBlueDarkColor,
            background: [
              SvgPicture.asset(
                'assets/images/1.svg',
                height: 400,
              ),
              SvgPicture.asset(
                'assets/images/2.svg',
                height: 400,
              ),
              SvgPicture.asset(
                'assets/images/1.svg',
                height: 400,
              ),
            ],
            speed: 1.8,
            pageBodies: [
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 480,
                    ),
                    Text(
                      'مرحبًا أنا نوس ..  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kOrangeColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'روبوت محادثة متخصص بخدمة العملاء بالذكاء الاصطناعي',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 480,
                    ),
                    Text(
                      'اسأل نوس ..  ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kOrangeColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'يمكنني الإجابة على استفسارات العملاء بطريقة إبداعية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 480,
                    ),
                    Text(
                      'لنبدأ رحلتنا',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: kOrangeColor,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'اختر الجهة التي تريد .. واحصل على الإجابات ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}