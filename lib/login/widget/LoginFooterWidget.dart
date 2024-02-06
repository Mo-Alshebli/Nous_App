
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../DashBord/HomeScreen.dart';
import '../../DashBord/ReaitimeData.dart';
import '../../LoginWithGoogle/GoogleLogin.dart';
import '../../Signup/SignUp_Screen.dart';
import '../../constants/image_string.dart';
import '../../global/common/toast.dart';
import '../login_screen.dart';

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double responsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;

      return (screenWidth * scale).clamp(12.0, 18.0); // Ensures font size is between 12 and 36
    }
    var googleSignInProvider = Provider.of<GoogleSignInProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("أو"),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              onPressed: () async{
  bool success = await googleSignInProvider.googleLogin();
  if (success) {
    // If the login was successful, proceed to the next screen or do something else
    UserData();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => ChatterScreen(),
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
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(fontFamily:"MyFont",fontSize: responsiveFontSize(0.05), fontWeight: FontWeight.bold),

              )),
        ),
        const SizedBox(
          height: 5.0,
        ),
        TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SignUpScreen(),
                ),
              );

            },
            child: Text.rich(TextSpan(text: " هل تريد ?", style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontFamily:"MyFont",fontSize: responsiveFontSize(0.5), fontWeight: FontWeight.bold),
                children: [
              TextSpan(
                  text: " انشاء حساب ", style: TextStyle(color: Colors.blue))
            ])))
      ],
    );
  }
}
