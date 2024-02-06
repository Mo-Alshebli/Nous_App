import 'dart:ui';

class OnBoardingModel {
  final String image;
  final String title;
  final String subtitle;
  final String numPage;
  final Color bgcolor;
  final int? num;

  OnBoardingModel({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.numPage,
    required this.bgcolor,
    this.num,
  });
}


