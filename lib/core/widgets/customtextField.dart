import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/appStyles.dart';
import 'CustomSvg.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final int? maxLines;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? iconPath;
  final Color? iconColor;
  final double width;
  final double height;
  final Color? backgroundColor;
  final VoidCallback? onIconTap; // for svg iconPath taps
  final Widget? prefixIcon;
  final String? Function(String?)? validator;

<<<<<<< HEAD
  final bool readOnly;
  final VoidCallback? onTap; 
=======
  // NEW:
  final bool readOnly;
  final VoidCallback? onTap; // tap on the field itself
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127

  const CustomTextField({
    super.key,
    this.maxLines,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.iconPath,
    this.iconColor,
    this.width = 340,
    this.height = 56,
    this.backgroundColor,
    this.onIconTap,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final textDirection = Directionality.of(context);

    return SizedBox(
      width: widget.width.w,
      height: widget.height.h,
      child: TextFormField(
        controller: widget.controller,
        obscureText: _obscure,
        keyboardType: widget.keyboardType,
        textAlign: textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
        maxLines: widget.maxLines ?? 1,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        style: AppStyles.textStyle12w400FF.copyWith(
          fontSize: 12.sp,
          height: 1.5,
        ),
        validator: widget.validator,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppStyles.textStyle12w400FF.copyWith(
            fontSize: 12.sp,
            color: const Color(0xFFA4ACAD),
            height: 1.5,
          ),
          filled: true,
          fillColor: widget.backgroundColor ?? Colors.white,
          contentPadding: EdgeInsets.symmetric(
            vertical: 15.h,
            horizontal: 20.w,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.blue),
          ),

          // prefix icon (widget) OR svg path
          prefixIcon: widget.prefixIcon ??
              (widget.iconPath != null
                  ? GestureDetector(
                onTap: widget.onIconTap,
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 8.w),
                  child: CustomSvg(
                    path: widget.iconPath!,
                    width: 24.w,
                    height: 24.h,
                    color: widget.iconColor,
                  ),
                ),
              )
                  : null),


          suffixIcon: widget.obscureText
              ? IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility,
              size: 20.sp,
              color: Colors.grey.shade600,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          )
              : null,
        ),
      ),
    );
  }
}
