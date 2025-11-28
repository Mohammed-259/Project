import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medication_reminder/core/helper/my_navgator.dart';
import 'package:medication_reminder/core/utils/appColor.dart';
import 'package:medication_reminder/core/utils/appIcons.dart';
import 'package:medication_reminder/core/utils/appPaddings.dart';
import 'package:medication_reminder/core/utils/appStyles.dart';
import 'package:medication_reminder/core/widgets/CustomButton.dart';
import 'package:medication_reminder/features/OTP/manager/otp/otp_cubit.dart';
import 'package:medication_reminder/features/OTP/manager/otp/otp_state.dart';
import 'package:medication_reminder/features/auth/views/login_screen.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreen extends StatefulWidget {
  final String emailOrPhone;

  const OtpScreen({super.key, required this.emailOrPhone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OtpCubit(),
      child: BlocBuilder<OtpCubit, OtpState>(
        builder: (context, state) {
          final cubit = context.read<OtpCubit>();
          final minutes = (state.secondsRemaining ~/ 60).toString().padLeft(2, '0');
          final seconds = (state.secondsRemaining % 60).toString().padLeft(2, '0');

          return Scaffold(
            backgroundColor: AppColors.white,
            body: SingleChildScrollView(
              child: Padding(
                padding: AppPaddings.mainPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20.h),
                    Center(
                      child: SvgPicture.asset(
                        AppIcons.verification,
                        width: 300.w,
                        height: 350.h,
                      ),
                    ),
                    Text(
                      "Verification code",
                      style: AppStyles.textStyle18w400.copyWith(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(height: 10.h),
                    Text(
                      'Please enter the verification code that was sent to you in a message on: ${widget.emailOrPhone}',
                      style: AppStyles.textStyle14w400FF.copyWith(
                        color: AppColors.gray,
                      ),
                    ),
                    SizedBox(height: 33.h),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (state.hasError) {
                                cubit.clearError();
                              }
                            },
                            textStyle: AppStyles.textStyle20w400MA.copyWith(
                              color: AppColors.blue,
                            ),
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(12.r),
                              fieldHeight: 74.h,
                              fieldWidth: 78.w,
                              activeColor: state.hasError ? Colors.red : AppColors.blue,
                              inactiveColor:
                              state.hasError ? Colors.red : AppColors.grayOtp,
                              selectedColor: state.hasError ? Colors.red : AppColors.blue,
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              selectedFillColor: Colors.white,
                            ),
                            enableActiveFill: true,
                          ),
                          if (state.hasError) ...[
                            SizedBox(height: 8.h),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    AppIcons.warningOtp,
                                    width: 16.w,
                                    height: 16.h,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    state.errorMessage,
                                    textAlign: TextAlign.right,
                                    style: AppStyles.textStyle14w400FF
                                        .copyWith(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 80.h),
                  CustomButton(
                    text: 'Confirm',
                    onPressed: () => cubit.verifyOtp(
                      otpController.text,
                          () => MyNavigator.goTo(
                        context,
                        LoginScreen(),
                        type: NavigatorType.pushReplacement,
                      ),
                    ),
                    gradient: state.hasError
                        ? null
                        : LinearGradient(
                      colors: AppColors.login,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    color: state.hasError ? AppColors.gray : Colors.transparent,
                    textStyle: AppStyles.textStyle14w400FF.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 21.h),
                    Center(
                      child: state.enableResend
                          ? GestureDetector(
                        onTap: cubit.resendCode,
                        child: Text(
                          "Resend the code",
                          style: AppStyles.textStyle14w400FF
                              .copyWith(color: AppColors.blue),
                        ),
                      )
                          : RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Resend after ",
                              style: AppStyles.textStyle14w400FF
                                  .copyWith(color: AppColors.gray),
                            ),
                            TextSpan(
                              text: "$minutes:$seconds",
                              style: AppStyles.textStyle14w400FF
                                  .copyWith(color: AppColors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
