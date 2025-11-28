import 'package:flutter/material.dart';
import 'package:medication_reminder/features/onboarding/widgets/onboarding_page.dart';


class OnBoarding3 extends StatelessWidget {
  const OnBoarding3({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingPage(
      title: "Track Your Progress ",
      description: "Monitor your medication history and stay on top of your health💊⏰",
      activeIndex: 2,
      showSkip: false,
    );
  }
}
