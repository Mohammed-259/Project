import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medication_reminder/core/utils/appColor.dart';

abstract class AppStyles {
  static final textStyle14w700FF = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      fontFamily: 'FF Shamel Family',
      fontFamilyFallback: const ['Roboto']);
  static final textStyle20w400FF = TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'FF Shamel Family',
      fontFamilyFallback: const ['Roboto']);
  static final textStyle16w400 = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'FF Shamel Family',
      fontFamilyFallback: const ['Roboto']);
  static final textStyle18w400 = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'FF Shamel Family',
      fontFamilyFallback: const ['Roboto']);
  static final textStyle14w400FF = TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'FF Shamel Family',
      fontFamilyFallback: const ['Roboto']);
  static final textStyle20w400MA = TextStyle(
      fontSize: 20.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'MadaniArabic-Regular',
      fontFamilyFallback: const ['Roboto']);
  static final textStyle12w400FF = TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w400,
      fontFamily: 'FF Shamel Family',
      fontFamilyFallback: const ['Roboto']);
  static final textStyle18w700 = TextStyle(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      fontFamily: 'FF Shamel Family',
      fontFamilyFallback: const ['Roboto']);
  static final textStyle19w700 = TextStyle(
      color:AppColors.white,
      fontSize: 26.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
  );
  static final textStyle12w700 = TextStyle(
  fontSize: 24.sp,
  fontWeight: FontWeight.bold,
  color: AppColors.black87,
  );
}