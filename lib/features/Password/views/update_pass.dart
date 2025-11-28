import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medication_reminder/core/helper/my_navgator.dart';
import 'package:medication_reminder/core/utils/appColor.dart';
import 'package:medication_reminder/core/utils/appIcons.dart';
import 'package:medication_reminder/core/utils/appPaddings.dart';
import 'package:medication_reminder/core/utils/appStyles.dart';
import 'package:medication_reminder/core/widgets/CustomButton.dart';
import 'package:medication_reminder/core/widgets/customtextField.dart';
import 'package:medication_reminder/core/helper/app_validator.dart';
import 'package:medication_reminder/features/auth/views/login_screen.dart';
import 'package:medication_reminder/features/messages/Update_message.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
<<<<<<< HEAD
  final bool _obscureNewPass = true;
  final bool _obscureConfirmPass = true;
=======
  bool _obscureNewPass = true;
  bool _obscureConfirmPass = true;
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127

  @override
  void dispose() {
    _newPassController.dispose();
    _confirmPassController.dispose();
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 25.h),
                  Center(
                    child: SvgPicture.asset(
                      AppIcons.forgetten_pass,
                      width: 250.w,
                      height: 300.h,
                    ),
                  ),
                  Text(
                    "Update Password",
                    style: AppStyles.textStyle18w400.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    "Please enter your new password and confirm it below.",
                    style: AppStyles.textStyle14w400FF.copyWith(
                      color: AppColors.gray,
                    ),
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  SizedBox(height: 40.h),


                  CustomTextField(
                    hintText: "New Password",
                    controller: _newPassController,
                    obscureText: true,
                    validator: AppValidator.passwordValidator,
                  ),


                  SizedBox(height: 20.h),


                  CustomTextField(
                    hintText: "Confirm New Password",
                    controller: _confirmPassController,
                    obscureText: true,
                    validator: (value) => AppValidator.confirmPasswordValidator(
                      value,
                      _newPassController.text,
                    ),
                  ),


                  SizedBox(height: 60.h),


                  CustomButton(
                    text: "Update Password",
                    height: 48.h,
                    width: 335.w,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        SuccessDialog.show(
                          context,
                          onConfirm: () {
                            MyNavigator.goTo(
                              context,
                              LoginScreen(),
                              type: NavigatorType.pushReplacement,
                            );
                          },
                        );
                      }
                    },
                    gradient: LinearGradient(
                      colors: AppColors.login,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: Colors.transparent,
                    textStyle: AppStyles.textStyle14w700FF.copyWith(color: Colors.white),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
