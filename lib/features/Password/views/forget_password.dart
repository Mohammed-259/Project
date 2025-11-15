import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:medication_reminder/core/helper/my_navgator.dart';
import 'package:medication_reminder/core/utils/appColor.dart';
import 'package:medication_reminder/core/utils/appIcons.dart';
import 'package:medication_reminder/core/utils/appPaddings.dart';
import 'package:medication_reminder/core/utils/appStyles.dart';
import 'package:medication_reminder/core/widgets/CustomButton.dart';
import 'package:medication_reminder/core/widgets/customtextField.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: AppPaddings.mainPadding,
            child: Column(
              children: [
                SizedBox(height: 25.h),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          AppIcons.forgetten_pass,
                          width: 300.w,
                          height: 350.h,
                        ),
                      ),
                      Text(
                        "Forgot Your Password?",
                        style: AppStyles.textStyle18w400.copyWith(
                          color: AppColors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 19.h),
                      Text(
                        "Enter your phone number / email to recover the password",
                        style: AppStyles.textStyle14w400FF.copyWith(
                          color: AppColors.gray,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                CustomTextField(hintText: "", controller: _controller),
                SizedBox(height: 70.h),
                CustomButton(
                  text: "Send Code",
                  gradient: LinearGradient(
                    colors: AppColors.login,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onPressed: () {
                    // MyNavigator.goTo(context, OtpToUpdatePasswordScreen(emailOrPhone: ''));
                  },
                  height: 48.h,
                  width: 335.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
