import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FormHeaderWidget extends StatelessWidget {
  FormHeaderWidget(
      {super.key,
      this.imageColor,
      this.heightBetwwen,
      required this.image,
      required this.title,
      required this.subtitle,
      required this.width,
      this.textaling,
      this.imageHeight = 0.2,
      this.crossAxisAlignment = CrossAxisAlignment.end});

  final Color? imageColor;
  final double imageHeight;
  final double? heightBetwwen;
  final CrossAxisAlignment crossAxisAlignment;
  final String image, title, subtitle;
  final TextAlign? textaling;
  final width;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Center(
          child: Lottie.asset(image,width:size.width * width,),

        ),
        SizedBox(
          height: heightBetwwen,
        ),
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(fontFamily:"MyFont",fontSize: 26, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium!
              .copyWith(fontFamily:"MyFont",fontSize: 20, fontWeight: FontWeight.bold),

        ),
      ],
    );
  }
}
