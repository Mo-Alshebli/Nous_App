import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';

import 'controller/on_boarding_controller.dart';

class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final obcontroller = OnBoardingController();

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          LiquidSwipe(
            pages: obcontroller.pages,
            slideIconWidget: const Icon(Icons.arrow_back_ios),
            onPageChangeCallback: obcontroller.OnPageChangeCallback,
            liquidController: obcontroller.contrller,
            enableSideReveal: true,
          ),
          Positioned(
              bottom: 60.0,
              child: OutlinedButton(
                  onPressed: () => obcontroller.animateToNextSlid(context),
                  style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.black26),
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      onPrimary: Colors.white),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                        color: Color(0xff272727), shape: BoxShape.circle),
                    child: Icon(Icons.arrow_forward_ios),
                  ))),
          Positioned(
              top: 50,
              right: 20,
              child: TextButton(
                onPressed: () => obcontroller.skip(),
                child: const Text(
                  "تخطي",
                  style: TextStyle(color: Colors.grey),
                ),
              )),
          Obx(
            () => Positioned(
                bottom: 10,
                child: AnimatedSmoothIndicator(
                  activeIndex: obcontroller.currenPage.value,
                  count: 4,
                  effect: const WormEffect(
                      activeDotColor: Color(0xFF272727), dotHeight: 5.0),
                )),
          )
        ],
      ),
    );
  }
}
