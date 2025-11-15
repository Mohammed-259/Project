import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medication_reminder/features/onboarding/manager/onboarding_cubit.dart';
import 'package:medication_reminder/features/onboarding/views/onboarding1.dart';
import 'package:medication_reminder/features/onboarding/views/onboarding2.dart';
import 'package:medication_reminder/features/onboarding/views/onboarding3.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: PageView(
        onPageChanged: (index) {
          context.read<OnboardingCubit>().changePage(index);
        },
        children: const [
          OnBoarding1(),
          OnBoarding2(),
          OnBoarding3(),
        ],
      ),
    );
  }
}
