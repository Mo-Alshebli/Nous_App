
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../DashBord/HomeScreen.dart';
import '../DashBord/ReaitimeData.dart';
import '../Form/Form_header_wifget.dart';
import '../LoginWithGoogle/GoogleLogin.dart';
import '../constants/image_string.dart';
import '../constants/size.dart';
import '../constants/text_string.dart';
import '../global/common/toast.dart';
import '../login/login_screen.dart';
import 'Widget/SignUpFormWidget.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var googleSignInProvider = Provider.of<GoogleSignInProvider>(context, listen: false);
    double responsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;

      return (screenWidth * scale).clamp(12.0, 18.0); // Ensures font size is between 12 and 36
    }
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(tDefualtsize),
            child: Column(
              children: [
                FormHeaderWidget(

                    image: lotti_sigin,
                    title: Title_,
                    subtitle: Signupsubtitle,
                    width: 0.8),
                const SignUpFormWidget(),
                Column(
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
                          label:  Text("إنشاء حساب بواسطة جوجل", style: Theme.of(context)
                              .textTheme
                              .headlineMedium!
                              .copyWith(fontFamily:"MyFont",fontSize: responsiveFontSize(0.5), fontWeight: FontWeight.bold),
                          ),
                        )),
                    TextButton(
                        onPressed: () {

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ),
                          );
                        },
                        child: Text.rich(TextSpan(
                          children: [
                            TextSpan(
                                text: "هل لديك حساب بالفعل ؟ ",
                                style: Theme.of(context).textTheme.bodyMedium),
                            const TextSpan(text: " دخول")
                          ],
                        )))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
