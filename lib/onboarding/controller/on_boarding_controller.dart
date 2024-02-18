
import 'package:chatnous/global/common/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/color.dart';
import '../../constants/image_string.dart';
import '../../constants/text_string.dart';
import '../../main.dart';
import '../on_Boarding_Page_widget.dart';
import '../on_boarding_controller.dart';

class OnBoardingController extends GetxController {
  final contrller = LiquidController();
  int nextPage =0;
  // LiquidController contrller = LiquidController();
  RxInt currenPage = 0.obs;
  final pages = [
    OnBoardingPage(
        model: OnBoardingModel(
      image: tbounding1,
      title: title1,
      subtitle: subtitle1,
      numPage: numtitle1,
      bgcolor: tonBoardingPage1color,
    )),
    OnBoardingPage(
        model: OnBoardingModel(
      image: tbounding2,
      title: title2,
      subtitle: subtitle2,
      numPage: numtitle2,
      bgcolor: tonBoardingPage2color,
    )),
    OnBoardingPage(
        model: OnBoardingModel(
      image: tbounding3,
      title: title3,
      subtitle: subtitle3,
      numPage: numtitle3,
      bgcolor: tonBoardingPage3color,
    )),
    OnBoardingPage(
        model: OnBoardingModel(
          image: company,
          title: title4,
          subtitle: subtitle4,
          numPage: numtitle4,
          bgcolor: tonBoardingPage3color,
          num: 4,
        ))
  ];

  void OnPageChangeCallback(int activePageIndex) =>
      currenPage.value = activePageIndex;

  skip() => contrller.jumpToPage(page: 3);


  Future<void> animateToNextSlid(BuildContext context) async {
    int nextPage = contrller.currentPage + 1;

    print(nextPage);
    if (nextPage == 4  ) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('onboardingShown', true);

      // Use Navigator to navigate to the LoginScreen
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyApp(onboardingShown: true)));}
     else {
      contrller.animateToPage(page: nextPage);
    }
  }

}
