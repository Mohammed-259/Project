import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/features/auth/views/auth_service.dart';
import '/models/sqlite.dart';
import '/models/user_session.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final FirebaseAuthService _authService = FirebaseAuthService();

  // ألوان
  final Color _primaryColor = const Color(0xFF4A90A4);
  final Color _backgroundColor = const Color(0xFFF8F9FA);

  // الدور المختار
  String _selectedRole = 'adult';

  Future<void> _loginWithFirebase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      print('''
🔐 LOGIN ATTEMPT:
   - Email: $email
   - Role: $_selectedRole
''');

      // 1. تسجيل الدخول مع Firebase
      final firebaseUser = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (firebaseUser != null) {
        print('✅ Firebase login successful: ${firebaseUser.uid}');

        // 2. البحث في SQLite بـ Firebase UID أولاً (الأكثر دقة)
        var localUser = await DatabaseHelper().getUserByFirebaseUid(
          firebaseUser.uid,
        );

        // 3. إذا لم نجده، نبحث بالبريد الإلكتروني
        if (localUser == null) {
          localUser = await DatabaseHelper().getUserByEmail(email);

          // إذا وجدناه بالبريد، نربط حساب Firebase به
          if (localUser != null) {
            await DatabaseHelper().updateUserFirebaseData(
              localUser['id'] as int,
              firebaseUser.uid,
              true,
            );
            print('🔗 Linked existing user with Firebase UID');
          }
        }

        if (localUser != null) {
          // ✅ المستخدم موجود - تسجيل الدخول
          final userId = localUser['id'] as int;
          UserSession().setUser(userId, localUser);

          print('''
✅ LOGIN SUCCESSFUL:
   - User ID: $userId
   - Name: ${localUser['name']}
   - Role: ${localUser['role']}
   - Firebase UID: ${firebaseUser.uid}
''');

          _navigateToHomeScreen();
        } else {
          // 🆕 مستخدم جديد - المزامنة
          print('🆕 New user - syncing from Firebase...');
          await _syncUserFromFirebase(firebaseUser);
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleFirebaseError(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _syncUserFromFirebase(User firebaseUser) async {
    try {
      // 🔍 أولاً: تحقق إذا كان المستخدم موجود بالفعل في SQLite
      final existingUser = await DatabaseHelper().getUserByFirebaseUid(
        firebaseUser.uid,
      );

      if (existingUser != null) {
        // ✅ المستخدم موجود بالفعل - استخدام بياناته
        final userId = existingUser['id'] as int;
        UserSession().setUser(userId, existingUser);
        print('✅ Existing user found in SQLite - ID: $userId');
        _navigateToHomeScreen();
        return;
      }

      // 🆕 إنشاء مستخدم جديد
      final userData = {
        'name':
            firebaseUser.displayName ??
            'User ${firebaseUser.uid.substring(0, 6)}',
        'email': firebaseUser.email!,
        'password': '', // لا نحتاج تخزين الباسوورد محلياً
        'role': _selectedRole,
        'birthDate': DateTime.now().toIso8601String(),
        'monitorId': null,
        'relationship': _selectedRole == 'child'
            ? 'Child'
            : _selectedRole == 'elderly'
            ? 'Elderly'
            : 'Self',
        'firebaseUid': firebaseUser.uid, // 🔥 حفظ Firebase UID
        'isSynced': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final userId = await DatabaseHelper().addUser(userData);

      print('''
✅ NEW USER SYNCED:
   - SQLite ID: $userId
   - Firebase UID: ${firebaseUser.uid}
   - Role: $_selectedRole
   - Email: ${firebaseUser.email}
''');

      UserSession().setUser(userId, userData);
      _showSuccessMessage('Welcome to Remedi!');
      _navigateToHomeScreen();
    } catch (e) {
      print('❌ Error syncing user from Firebase: $e');
      _showErrorMessage('Error setting up your account. Please try again.');
    }
  }

  void _handleFirebaseError(FirebaseAuthException e) {
    String errorMessage = 'Login failed';
    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'No user found with this email';
        break;
      case 'wrong-password':
        errorMessage = 'Incorrect password';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address';
        break;
      default:
        errorMessage = e.message ?? 'Authentication failed';
    }
    _showErrorMessage(errorMessage);
  }

  void _handleGenericError(dynamic e) {
    print('❌ Login error: $e');
    _showErrorMessage('An unexpected error occurred. Please try again.');
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToHomeScreen() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(fontSize: 18.sp, color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120.w,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: _primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medical_services,
                        size: 60.sp,
                        color: _primaryColor,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Sign in to continue to Remedi',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF7F8C8D),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),

              // Email Field
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, color: _primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: const Color(0xFF7F8C8D),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),

              // Role Selection
              Text(
                'Select your role:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'adult', child: Text('Adult User')),
                    DropdownMenuItem(
                      value: 'monitor',
                      child: Text('Caregiver'),
                    ),
                    DropdownMenuItem(value: 'child', child: Text('Child')),
                    DropdownMenuItem(value: 'elderly', child: Text('Elderly')),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRole = newValue;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  isExpanded: true,
                ),
              ),
              SizedBox(height: 30.h),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isLoading ? null : _loginWithFirebase,
                  child: _isLoading
                      ? SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 25.h),

              // Register Link
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF7F8C8D),
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: _primaryColor,
                            fontWeight: FontWeight.w600,
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
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
