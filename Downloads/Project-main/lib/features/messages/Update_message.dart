
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medication_reminder/core/utils/appColor.dart';
import 'package:medication_reminder/core/utils/appStyles.dart';
import 'package:medication_reminder/core/widgets/CustomButton.dart';

class SuccessDialog {
  static void show(
      BuildContext context, {
        required VoidCallback onConfirm,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: SizedBox(
          width: 339.w,
          height: 303.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                Text(
                  "Changes have been saved successfully",
                  style: AppStyles.textStyle18w700.copyWith(
                    color: AppColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                CustomButton(
                  text: "Go to home page",
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  gradient: LinearGradient(
                    colors: AppColors.login,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  textStyle: AppStyles.textStyle14w700FF.copyWith(
                    color: Colors.white,
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
