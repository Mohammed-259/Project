import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/appStyles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final LinearGradient? gradient;
  final Color textColor;
  final double width;
  final double height;
  final Widget? icon;
  final TextStyle? textStyle;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = const Color(0xFF2A72AD),
    this.gradient,
    this.textColor = Colors.white,
    this.width = 340,
    this.height = 51,
    this.icon,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final buttonContent = Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: (textStyle ?? AppStyles.textStyle14w700FF).copyWith(
              color: textColor,
            ),
          ),
        ),

        if (icon != null)
          Positioned(
            right: 10.w,
            child: SizedBox(
              width: 20.w,
              height: 20.h,
              child: icon,
            ),
          ),
      ],
    );

    if (gradient != null) {
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          width: width.w,
          height: height.h,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: buttonContent,
        ),
      );
    } else {
      return SizedBox(
        width: width.w,
        height: height.h,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
          ),
          onPressed: onPressed,
          child: buttonContent,
        ),
      );
    }
  }
}
