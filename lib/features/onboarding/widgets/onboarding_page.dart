import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medication_reminder/core/helper/my_navgator.dart';
import 'package:medication_reminder/core/utils/appColor.dart';
import 'package:medication_reminder/core/utils/appIcons.dart';
import 'package:medication_reminder/core/utils/appPaddings.dart';
import 'package:medication_reminder/core/utils/appStyles.dart';
import 'package:medication_reminder/core/widgets/CustomButton.dart';
import 'package:medication_reminder/core/widgets/customSvg.dart';
import 'package:medication_reminder/features/auth/views/login_screen.dart';
import 'package:medication_reminder/features/onboarding/views/onboarding2.dart';
import 'package:medication_reminder/features/onboarding/views/onboarding3.dart';

class OnBoardingPage extends StatelessWidget {
  final String title;
  final String description;
  final int activeIndex;
  final bool showSkip;

  const OnBoardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.activeIndex,
    this.showSkip = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white2,
      body: Padding(
        padding: AppPaddings.mainPadding,
        child: Column(
          children: [
            SizedBox(height: 80.h),
            Center(
              child:SvgPicture.asset(
                AppIcons.onboardingicon1,
                width: 300.w,
                height: 350.h,
              ),
            ),
            SizedBox(height: 30.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                bool isActive = index == activeIndex;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Container(
                    width: isActive ? 15.w : 10.w,
                    height: isActive ? 15.h : 10.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.green
                          : AppColors.green.withOpacity(0.26),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 40.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppStyles.textStyle20w400FF.copyWith(
                color: AppColors.black,
                height: 1.35,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppStyles.textStyle16w400.copyWith(
                color: AppColors.gray,
                height: 1.5,
              ),
            ),
            const Spacer(),

            Row(
              mainAxisAlignment: showSkip
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (showSkip)
                  TextButton(
                    onPressed: () {
                      MyNavigator.goTo(
                        context,
                        LoginScreen(),
                        type: NavigatorType.pushAndRemoveUntil,
                      );
                    },
                    child: Text(
                      "Skip",
                      style: AppStyles.textStyle16w400.copyWith(
                        color: AppColors.gray2,
                        height: 1.0,
                      ),
                    ),
                  ),
                CustomButton(
                  width: showSkip ? 231.w : 300.w,
                  height: 57.h,
                  text: showSkip ? "Next" : "Start",
                  color: showSkip ? AppColors.green : AppColors.red,
                  textStyle: AppStyles.textStyle14w700FF.copyWith(
                    color: AppColors.white,
                    fontSize: 14.sp,
                  ),
                  icon: showSkip
                      ? CustomSvg(
                    path: AppIcons.arrowforwerd,
                    color: AppColors.white,
                  )
                      : null,
                  onPressed: () {
                    if (activeIndex == 0) {
                      MyNavigator.goTo(
                        context,
                        const OnBoarding2(),
                        type: NavigatorType.pushReplacement,
                      );
                    } else if (activeIndex == 1) {
                      MyNavigator.goTo(
                        context,
                        const OnBoarding3(),
                        type: NavigatorType.pushReplacement,
                      );
                    } else {
                      MyNavigator.goTo(
                        context,
                        LoginScreen(),
                        type: NavigatorType.pushAndRemoveUntil,
                      );
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
