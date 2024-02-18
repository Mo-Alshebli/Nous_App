import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/size.dart';
import 'on_boarding_controller.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({
    super.key,
    required this.model,
  });

  final OnBoardingModel model;

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.all(tDefualtsize),
      color: widget.model.bgcolor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
         Lottie.asset(widget.model.image, height: size.height * 0.5,
             width: size.width * 0.9,),

          Column(
            children: [
              SizedBox(
                height: 50.0,
              ),
              Text(
                widget.model.title,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                widget.model.subtitle,
                textAlign: TextAlign.center,
              )
            ],
          ),

          Text(
            widget.model.numPage,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(
            height: 120.0,
          ),
        ],
      ),
    );
  }
}
