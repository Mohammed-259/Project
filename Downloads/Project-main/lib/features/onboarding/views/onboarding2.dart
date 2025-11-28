import 'package:flutter/material.dart';
import 'package:medication_reminder/features/onboarding/widgets/onboarding_page.dart';


class OnBoarding2 extends StatelessWidget {
  const OnBoarding2({super.key});

  @override
  Widget build(BuildContext context) {
    return OnBoardingPage(
      title: "Smart Reminders",
      description: "Set daily reminders for your medicines and get notified on time⏰",
      activeIndex: 1,
      showSkip: true,
    );
  }
}
