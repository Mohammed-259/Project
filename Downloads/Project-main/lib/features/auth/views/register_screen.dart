import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/features/auth/views/auth_service.dart';
import '/models/sqlite.dart';
import '/models/user_session.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _monitorCodeController = TextEditingController();

  bool _isLoading = false;
  String _selectedRole = 'adult';
  bool _showMonitorCodeField = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FirebaseAuthService _authService = FirebaseAuthService();

  // متغيرات لتتبع متطلبات الباسوورد
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;

  final Color _primaryColor = const Color(0xFF4A90A4);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF2C3E50);
  final Color _hintColor = const Color(0xFF7F8C8D);
  final Color _successColor = const Color(0xFF27AE60);
  final Color _errorColor = const Color(0xFFE74C3C);

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordRequirements);
  }

  void _checkPasswordRequirements() {
    final password = _passwordController.text;

    setState(() {
      _hasMinLength = password.length >= 6;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get _isPasswordValid {
    return _hasMinLength &&
        _hasUpperCase &&
        _hasLowerCase &&
        _hasNumbers &&
        _hasSpecialChar;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // تنظيف البريد الإلكتروني
    final cleanedEmail = value.trim().toLowerCase();

    // منع النقطة في النهاية
    if (cleanedEmail.endsWith('.')) {
      return 'Email should not end with a dot';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanedEmail)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // 🔐 **دالة التسجيل المحسنة**
  Future<void> _registerWithFirebase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // تنظيف البريد الإلكتروني
    final cleanedEmail = _emailController.text.trim().toLowerCase();
    _emailController.text = cleanedEmail;

    // التحقق من كود المراقب إذا مطلوب
    if (_showMonitorCodeField && _monitorCodeController.text.isEmpty) {
      _showErrorMessage('Please enter monitor code for child/elderly account');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorMessage('Passwords do not match');
      return;
    }

    if (!_isPasswordValid) {
      _showErrorMessage('Please meet all password requirements');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. التحقق من البريد الإلكتروني المكرر في SQLite أولاً
      final existingUser = await DatabaseHelper().getUserByEmail(cleanedEmail);
      if (existingUser != null) {
        _showErrorMessage(
          'This email is already registered. Please login instead.',
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2. التحقق من كود المراقب إذا مطلوب
      int? monitorId;
      if (_showMonitorCodeField && _monitorCodeController.text.isNotEmpty) {
        monitorId = await _validateMonitorCode();
        if (monitorId == null) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // 3. إنشاء حساب في Firebase
      final userData = {
        'name': _nameController.text.trim(),
        'email': cleanedEmail,
        'role': _selectedRole,
        'birthDate': _birthDateController.text.isEmpty
            ? DateTime.now().toIso8601String()
            : _birthDateController.text,
      };

      final firebaseUser = await _authService.signUpWithEmailAndPassword(
        email: cleanedEmail,
        password: _passwordController.text,
        userData: userData,
      );

      if (firebaseUser != null) {
        print('✅ Firebase account created: ${firebaseUser.uid}');

        // 4. حفظ في SQLite
        await _saveUserToDatabase(firebaseUser, monitorId);
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

  // ✅ **التحقق من صحة كود المراقب**
  Future<int?> _validateMonitorCode() async {
    final monitorCode = _monitorCodeController.text;
    final monitorId = int.tryParse(monitorCode);

    if (monitorId == null) {
      _showErrorMessage('Monitor code must be a valid number');
      return null;
    }

    // التحقق من وجود المراقب
    final monitor = await DatabaseHelper().getUserById(monitorId);
    if (monitor == null) {
      _showErrorMessage('Monitor ID not found');
      return null;
    }

    // التحقق من أن المراقب له الدور الصحيح
    if (monitor['role'] != 'monitor') {
      _showErrorMessage('Invalid monitor code - user is not a monitor');
      return null;
    }

    return monitorId;
  }

  // 💾 **حفظ المستخدم في قاعدة البيانات**
  Future<void> _saveUserToDatabase(User firebaseUser, int? monitorId) async {
    try {
      final userData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': '',
        'role': _selectedRole,
        'birthDate': _birthDateController.text.isEmpty
            ? DateTime.now().toIso8601String()
            : _birthDateController.text,
        'monitorId': monitorId,
        'relationship': _selectedRole == 'child'
            ? 'Child'
            : _selectedRole == 'elderly'
            ? 'Elderly'
            : 'Self',
        'firebaseUid': firebaseUser.uid,
        'isSynced': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      print('💾 Saving user with role: $_selectedRole');

      final userId = await DatabaseHelper().addUser(userData);
      userData['id'] = userId;

      // ✅ التحقق من الحفظ
      final savedUser = await DatabaseHelper().getUserById(userId);
      if (savedUser != null) {
        print('✅ USER SAVED VERIFICATION:');
        print('   - ID: $userId');
        print('   - Name: ${savedUser['name']}');
        print('   - Role: ${savedUser['role']}');
        print('   - Expected Role: $_selectedRole');
      }

      UserSession().setUser(userId, userData);
      _showSuccessMessage('Account created successfully as $_selectedRole!');
      _navigateToHomeScreen();
    } catch (e) {
      print('❌ Error saving user: $e');

      // معالجة خطأ البريد المكرر بشكل خاص
      if (e.toString().contains('UNIQUE constraint failed')) {
        _showErrorMessage(
          'This email is already registered. Please use a different email.',
        );
      } else {
        _showErrorMessage('Error creating account: $e');
      }

      // حذف حساب Firebase إذا فشل حفظ في SQLite
      try {
        await firebaseUser.delete();
        print('🗑️ Firebase account deleted due to SQLite error');
      } catch (deleteError) {
        print('❌ Error deleting Firebase account: $deleteError');
      }
    }
  }

  // 🚨 **معالجة أخطاء Firebase**
  void _handleFirebaseError(FirebaseAuthException e) {
    String errorMessage = 'Registration failed';

    switch (e.code) {
      case 'email-already-in-use':
        errorMessage = 'This email is already registered';
        break;
      case 'weak-password':
        errorMessage = 'Password is too weak';
        break;
      case 'invalid-email':
        errorMessage = 'Invalid email address';
        break;
      case 'operation-not-allowed':
        errorMessage = 'Email/password accounts are not enabled';
        break;
      default:
        errorMessage = e.message ?? 'Registration failed';
    }

    _showErrorMessage(errorMessage);
  }

  // 🚨 **معالجة الأخطاء العامة**
  void _handleGenericError(dynamic e) {
    print('❌ Registration error: $e');
    _showErrorMessage('An unexpected error occurred. Please try again.');
  }

  // ✅ **عرض رسالة نجاح**
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ❌ **عرض رسالة خطأ**
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _navigateToHomeScreen() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  // 📅 **اختيار تاريخ الميلاد**
  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: _textColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // 🔄 **تغيير الدور**
  void _onRoleChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedRole = newValue;
        _showMonitorCodeField = newValue == 'child' || newValue == 'elderly';
        if (!_showMonitorCodeField) {
          _monitorCodeController.clear();
        }
      });
    }
  }

  // 🧪 **ملء بيانات تجريبية للتطوير**
  void _fillDemoData() {
    setState(() {
      _nameController.text = 'Demo User';
      _emailController.text = 'demo@remedi.com';
      _birthDateController.text = '1990-01-01';
      _passwordController.text = 'Demo123!';
      _confirmPasswordController.text = 'Demo123!';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo data filled!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // 🎨 **بناء متطلبات الباسوورد**
  Widget _buildPasswordRequirement(String text, bool isMet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16.sp,
            color: isMet ? _successColor : Colors.grey,
          ),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: isMet ? _successColor : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 📊 **بناء قوة الباسوورد**
  Widget _buildPasswordStrength() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox();
    }

    int requirementsMet = 0;
    if (_hasMinLength) requirementsMet++;
    if (_hasUpperCase) requirementsMet++;
    if (_hasLowerCase) requirementsMet++;
    if (_hasNumbers) requirementsMet++;
    if (_hasSpecialChar) requirementsMet++;

    String strengthText;
    Color strengthColor;
    double strengthValue = requirementsMet / 5;

    if (requirementsMet <= 1) {
      strengthText = 'Very Weak';
      strengthColor = Colors.red;
    } else if (requirementsMet <= 2) {
      strengthText = 'Weak';
      strengthColor = Colors.orange;
    } else if (requirementsMet <= 3) {
      strengthText = 'Medium';
      strengthColor = Colors.yellow[700]!;
    } else if (requirementsMet <= 4) {
      strengthText = 'Strong';
      strengthColor = Colors.lightGreen;
    } else {
      strengthText = 'Very Strong';
      strengthColor = _successColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              'Password strength: ',
              style: TextStyle(
                fontSize: 12.sp,
                color: _textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12.sp,
                color: strengthColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        LinearProgressIndicator(
          value: strengthValue,
          backgroundColor: Colors.grey[300],
          color: strengthColor,
          minHeight: 6.h,
          borderRadius: BorderRadius.circular(3.r),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: TextStyle(fontSize: 20.sp, color: Colors.white),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 26.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس الصفحة مع اللوجو
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
                      'Join Remedi',
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Create your account to get started',
                      style: TextStyle(fontSize: 16.sp, color: _hintColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // زر البيانات التجريبية (للتطوير فقط)
              if (!_isLoading)
                Center(
                  child: TextButton(
                    onPressed: _fillDemoData,
                    child: Text(
                      'Fill Demo Data',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: _primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              SizedBox(height: 20.h),

              // اختيار الدور
              Text(
                'I am a:',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  items: [
                    DropdownMenuItem(
                      value: 'adult',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue, size: 20.sp),
                          SizedBox(width: 12.w),
                          Text('Adult User', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'monitor',
                      child: Row(
                        children: [
                          Icon(
                            Icons.supervisor_account,
                            color: Colors.green,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text('Caregiver', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'child',
                      child: Row(
                        children: [
                          Icon(
                            Icons.child_care,
                            color: Colors.orange,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text('Child', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'elderly',
                      child: Row(
                        children: [
                          Icon(
                            Icons.elderly,
                            color: Colors.purple,
                            size: 20.sp,
                          ),
                          SizedBox(width: 12.w),
                          Text('Elderly', style: TextStyle(fontSize: 14.sp)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: _onRoleChanged,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                  ),
                  isExpanded: true,
                ),
              ),
              SizedBox(height: 20.h),

              // حقل الاسم الكامل
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline, color: _primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  if (value.length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // حقل الإيميل
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, color: _primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: 16.h),

              // حقل تاريخ الميلاد
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                onTap: () => _selectBirthDate(context),
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                    color: _primaryColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // حقل كود المراقب
              if (_showMonitorCodeField) ...[
                TextFormField(
                  controller: _monitorCodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Monitor ID',
                    prefixIcon: Icon(
                      Icons.family_restroom,
                      color: _primaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    hintText: 'Enter your caregiver ID',
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // حقل الباسوورد
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
                      color: _hintColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: _validatePassword,
              ),
              SizedBox(height: 12.h),

              // متطلبات الباسوورد
              if (_passwordController.text.isNotEmpty) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _isPasswordValid
                          ? _successColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password Requirements:',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: [
                          _buildPasswordRequirement(
                            'At least 6 characters',
                            _hasMinLength,
                          ),
                          _buildPasswordRequirement(
                            'One uppercase letter (A-Z)',
                            _hasUpperCase,
                          ),
                          _buildPasswordRequirement(
                            'One lowercase letter (a-z)',
                            _hasLowerCase,
                          ),
                          _buildPasswordRequirement(
                            'One number (0-9)',
                            _hasNumbers,
                          ),
                          _buildPasswordRequirement(
                            'One special character (!@#)',
                            _hasSpecialChar,
                          ),
                        ],
                      ),
                      _buildPasswordStrength(),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              // حقل تأكيد الباسوورد
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline, color: _primaryColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: _hintColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30.h),

              // زر إنشاء الحساب
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
                  onPressed: _isLoading ? null : _registerWithFirebase,
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
                          'Create Account',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20.h),

              // رابط تسجيل الدخول
              Center(
                child: TextButton(
                  onPressed: _navigateToLogin,
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(fontSize: 16.sp, color: _hintColor),
                      children: [
                        TextSpan(
                          text: 'Sign In',
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
    _passwordController.removeListener(_checkPasswordRequirements);
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _monitorCodeController.dispose();
    super.dispose();
  }
}
