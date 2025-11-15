import 'package:flutter/material.dart';
import 'package:medication_reminder/features/onboarding/widgets/onboarding_page.dart';

class OnBoarding1 extends StatelessWidget {
  const OnBoarding1({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingPage(
      title: "Welcome To Remedi",
      description: "Keep track of your medications easily and never miss a dose again!",
      activeIndex: 0,
      showSkip: true,
    );
  }
}
