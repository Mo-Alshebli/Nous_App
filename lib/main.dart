import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'DashBord/style.dart';
import 'LoginWithGoogle/GoogleLogin.dart';
import 'DashBord/ReaitimeData.dart';
import 'firebase_options.dart';
import 'on_boarding.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'splash.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool onboardingShown = prefs.getBool('onboardingShown') ?? false;
  await prefs.setString('lang', 'Women');
  await fetchData();
  Gemini.init(apiKey: 'AIzaSyDHHCM4jdLio7svg2c_KRupC93lvShT6fg');

  print("====================================");

  runApp( MyApp(onboardingShown: onboardingShown));
}

class MyApp extends StatelessWidget {
final bool onboardingShown;

   MyApp({super.key,  required this.onboardingShown});

  get kDarkBlue => null;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
    child: MaterialApp(

      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AE') , // OR Locale('ar', 'AE') OR Other RTL locales
      ],

      locale: const Locale("fa", "IR"),
      debugShowCheckedModeBanner: false,
      title: 'Idea Chat Bot',
      theme: ThemeData(

        fontFamily: 'Lama',

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(kOrangeColor), // Button color
            foregroundColor: MaterialStateProperty.all(Colors.white), // Text color
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRaduis),
                side: BorderSide(color: kOrangeColor),
              ),
            ),
            elevation: MaterialStateProperty.all(10), // Shadow elevation
          ),
        ),

        primaryColor: kDarkBlue,
        colorScheme: ColorScheme.fromSeed(seedColor: kLightDarkColor),
        useMaterial3: true,
      ),
      home:SplashScreen(
        onboardingShown: onboardingShown,
      ),
    )
    );
  }
}