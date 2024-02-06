import 'package:flutter/material.dart';

import '../../constants/image_string.dart';
import '../../constants/text_string.dart';
import 'package:lottie/lottie.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {

    // Improved responsive font size calculation
    double responsiveFontSize(double scale) {
      double screenWidth = MediaQuery.of(context).size.width;

      return (screenWidth * scale).clamp(12.0, 36.0); // Ensures font size is between 12 and 36
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Center(

          child: Lottie.asset(lotti_login,width:size.width * 0.7,),
        ),
        Text(
          Title_,
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(
              fontFamily: "MyFont",
              fontSize: responsiveFontSize(0.05), // Using the responsiveFontSize function
              fontWeight: FontWeight.bold
          ),
        ),
        Text(
          LoginSubTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(
              fontFamily: "MyFont",
              fontSize: responsiveFontSize(0.04), // Slightly smaller font for the subtitle
              fontWeight: FontWeight.bold
          ),
        ),
      ],
    );
  }
}
