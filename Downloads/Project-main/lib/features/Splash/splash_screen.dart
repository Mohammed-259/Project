import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medication_reminder/features/auth/views/login_screen.dart';
import 'package:medication_reminder/features/auth/views/register_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _navigateToRegister(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF4A90A4);
    final Color secondaryColor = const Color(0xFF81C7D4);
    final Color backgroundColor = const Color(0xFFF8F9FA);

    return WillPopScope(
      onWillPop: () async => false, // منع زرار back
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [primaryColor, secondaryColor],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Top Section (Logo & Text)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 20.h,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150.w,
                          height: 150.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/app_icon.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 25.h),
                        Text(
                          'Remedi',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Your Personal Medication Assistant',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          'Never miss a dose again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Section (Buttons)
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40.r),
                        topRight: Radius.circular(40.r),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(30.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Get Started Button
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                elevation: 5,
                                shadowColor: primaryColor.withOpacity(0.3),
                              ),
                              onPressed: () => _navigateToRegister(context),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Get Started',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15.h),
                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: primaryColor,
                                side: BorderSide(
                                  color: primaryColor,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              onPressed: () => _navigateToLogin(context),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 25.h),
                          // Terms Text
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              children: [
                                Text(
                                  'By continuing, you agree to our',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: const Color(0xFF7F8C8D),
                                    fontSize: 12.sp,
                                    height: 1.4,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Terms of Service & Privacy Policy coming soon',
                                        ),
                                        backgroundColor: Colors.blue,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Terms of Service & Privacy Policy',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
