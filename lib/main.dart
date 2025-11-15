import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/views/login_screen.dart';
import 'features/auth/views/register_screen.dart';
import 'features/home_page/adult_users.dart';
import 'features/home_page/monitor.dart';
import 'features/home_page/child_user.dart';
import 'models/user_session.dart';
import 'models/sqlite.dart';
import 'models/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  try {
    await DatabaseHelper().recreateDatabase();
    print('✅ Database initialized successfully');
  } catch (e) {
    print('❌ Database initialization failed: $e');
  }

  // Initialize and start sync service (non-blocking)
  _initializeSyncService();

  runApp(const MyApp());
}

// 🔥 جعل تهيئة المزامنة غير متزامنة حتى لا تمنع تشغيل التطبيق
void _initializeSyncService() async {
  try {
    final syncService = SyncService();
    await syncService.syncOnAppStart();
    print('✅ Sync service initialized successfully');
  } catch (e) {
    print('❌ Sync service initialization failed: $e');
    // لا توقف التطبيق إذا فشلت المزامنة
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Medication Reminder',
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: const Color(0xFF4A90A4),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A90A4),
              primary: const Color(0xFF4A90A4),
              secondary: const Color(0xFF81C7D4),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF4A90A4),
              foregroundColor: Colors.white,
            ),
          ),
          home: const SplashScreen(),
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeWrapper(),
          },
        );
      },
    );
  }
}

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key});

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<Map<String, dynamic>?> _loadUserData() async {
    try {
      final session = UserSession();

      // 🔥 تحقق محسن من حالة تسجيل الدخول
      if (!session.isLoggedIn || session.currentUserId == null) {
        print('❌ No user logged in - redirecting to login');
        await Future.delayed(const Duration(milliseconds: 500));
        return null;
      }

      print('🔍 Loading user data for ID: ${session.currentUserId}');

      final userData = await DatabaseHelper().getUserById(
        session.currentUserId!,
      );

      if (userData != null && userData.isNotEmpty) {
        // 🔥 تحديث الجلسة بالبيانات الكاملة
        session.setUser(session.currentUserId!, userData);

        print('✅ USER DATA LOADED SUCCESSFULLY:');
        print('   - ID: ${userData['id']}');
        print('   - Name: ${userData['name']}');
        print('   - Email: ${userData['email']}');
        print('   - Role: ${userData['role']}');
        print('   - Monitor ID: ${userData['monitorId']}');
        print('   - Synced: ${userData['isSynced']}');

        return userData;
      } else {
        print('❌ User data not found for ID: ${session.currentUserId}');
        // 🔥 تنظيف الجلسة إذا لم يتم العثور على المستخدم
        session.clear();
        return null;
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      // 🔥 تنظيف الجلسة في حالة الخطأ
      UserSession().clear();
      return null;
    }
  }

  Widget _getHomeScreenByRole(Map<String, dynamic> userData) {
    final role = userData['role']?.toString().toLowerCase().trim();

    print('🎯 Navigating to home screen for role: $role');

    switch (role) {
      case 'adult':
        return AdultHomeScreen(currentUserId: userData['id']);
      case 'monitor':
        return MonitorHomeScreen(currentUserId: userData['id']);
      case 'child':
      case 'elderly':
        return ChildHomeScreen(currentUserId: userData['id']);
      default:
        print('⚠️ Unknown role: $role - defaulting to adult');
        return AdultHomeScreen(currentUserId: userData['id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        // 🔥 معالجة أفضل للحالات المختلفة
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF8F9FA),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4A90A4),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading your profile...',
                    style: TextStyle(color: Color(0xFF2C3E50), fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          print('❌ FutureBuilder error: ${snapshot.error}');
          return _buildErrorScreen(
            'Error loading user data: ${snapshot.error}',
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          print('🔁 No user data found - redirecting to login');
          // 🔥 استخدام postFrameCallback لتجنب أخطاء التحديث أثناء البناء
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!;

        // 🔥 تحقق إضافي من بيانات المستخدم
        if (userData['id'] == null || userData['role'] == null) {
          print('❌ Invalid user data: $userData');
          return _buildErrorScreen('Invalid user data');
        }

        print('🎯 Final userData in build:');
        print('   - ID: ${userData['id']}');
        print('   - Role: ${userData['role']}');
        print('   - Name: ${userData['name']}');

        return _getHomeScreenByRole(userData);
      },
    );
  }

  // 🔥 دالة مساعدة لبناء شاشة الخطأ
  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64.w, color: Color(0xFFE74C3C)),
              SizedBox(height: 24.h),
              Text(
                'Oops!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Color(0xFF7F8C8D)),
              ),
              SizedBox(height: 32.h),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A90A4),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () {
                  UserSession().clear();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text('Back to Login', style: TextStyle(fontSize: 16.sp)),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {
                  setState(() {
                    _userFuture = _loadUserData();
                  });
                },
                child: Text(
                  'Try Again',
                  style: TextStyle(fontSize: 14.sp, color: Color(0xFF4A90A4)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
