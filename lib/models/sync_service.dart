import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sqlite.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // التحقق من الاتصال بالإنترنت
  Future<bool> isConnectedToInternet() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('❌ Connectivity check error: $e');
      return false;
    }
  }

  // مزامنة جميع المستخدمين غير المتزامنين
  Future<void> syncAllPendingUsers() async {
    try {
      final isConnected = await isConnectedToInternet();
      if (!isConnected) {
        print('📵 No internet connection - delaying sync');
        return;
      }

      final unsyncedUsers = await _dbHelper.getUnsyncedUsers();

      if (unsyncedUsers.isEmpty) {
        print('✅ No users to sync');
        return;
      }

      print('🔄 Starting sync of ${unsyncedUsers.length} users');

      int successfulSyncs = 0;
      int failedSyncs = 0;

      for (final user in unsyncedUsers) {
        final success = await _syncSingleUser(user);
        if (success) {
          successfulSyncs++;
        } else {
          failedSyncs++;
        }

        // تأخير صغير لتجنب حدوث أخطاء في Firebase
        await Future.delayed(Duration(milliseconds: 500));
      }

      print(
        '✅ Sync completed: $successfulSyncs successful, $failedSyncs failed',
      );

      // طبخة إحصائيات المزامنة
      final stats = await _dbHelper.getSyncStats();
      print(
        '📊 Sync Stats: ${stats['syncedUsers']}/${stats['totalUsers']} users synced (${stats['syncPercentage']}%)',
      );
    } catch (e) {
      print('❌ Error in general sync: $e');
    }
  }

  // مزامنة مستخدم واحد
  Future<bool> _syncSingleUser(Map<String, dynamic> user) async {
    try {
      final String email = user['email'];
      final String password = user['password'] ?? '';
      final String name = user['name'];
      final int userId = user['id'];

      // التحقق من الحقول المطلوبة
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        print('❌ Invalid user data for ID: $userId');
        return false;
      }

      print('🔄 Syncing user: $email');

      // تسجيل الخروج أولاً لتجنب التعارضات
      if (_firebaseAuth.currentUser != null) {
        await _firebaseAuth.signOut();
      }

      // إنشاء حساب في Firebase
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String firebaseUid = userCredential.user!.uid;

      // تحديث البيانات في Firebase
      await userCredential.user!.updateDisplayName(name);

      // تحديث SQLite ببيانات Firebase
      await _dbHelper.updateUserFirebaseData(userId, firebaseUid, true);

      print('✅ User synced successfully: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('⚠️ Email already registered in Firebase: ${user['email']}');
        // محاولة تسجيل الدخول بالحساب الموجود
        return await _handleExistingUser(user);
      } else {
        print(
          '❌ Firebase error syncing user ${user['email']}: ${e.code} - ${e.message}',
        );
        return false;
      }
    } catch (e) {
      print('❌ Unexpected error syncing user ${user['email']}: $e');
      return false;
    }
  }

  // التعامل مع المستخدم الموجود في Firebase
  Future<bool> _handleExistingUser(Map<String, dynamic> user) async {
    try {
      final String email = user['email'];
      final String password = user['password'] ?? '';

      if (password.isEmpty) {
        print('❌ No password available for existing user: $email');
        return false;
      }

      // محاولة تسجيل الدخول بالبيانات الموجودة
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      final String firebaseUid = userCredential.user!.uid;

      // تحديث SQLite ببيانات Firebase الموجودة
      await _dbHelper.updateUserFirebaseData(user['id'], firebaseUid, true);

      print('✅ Linked existing Firebase user: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      print(
        '❌ Firebase error linking user ${user['email']}: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      print('❌ Unexpected error linking user ${user['email']}: $e');
      return false;
    }
  }

  // مزامنة عند فتح التطبيق
  Future<void> syncOnAppStart() async {
    try {
      final isConnected = await isConnectedToInternet();
      if (isConnected) {
        print('🌐 Internet connection available - starting auto sync');
        await syncAllPendingUsers();
      } else {
        print('📵 No internet - sync will happen when connection returns');
      }
    } catch (e) {
      print('❌ Error in auto sync: $e');
    }
  }

  // مزامنة يدوية
  Future<Map<String, dynamic>> manualSync() async {
    try {
      print('👤 Manual sync triggered');
      await syncAllPendingUsers();
      final stats = await _dbHelper.getSyncStats();
      return {
        'success': true,
        'message': 'Sync completed successfully',
        'stats': stats,
      };
    } catch (e) {
      print('❌ Manual sync error: $e');
      return {
        'success': false,
        'message': 'Sync failed: $e',
        'stats': await _dbHelper.getSyncStats(),
      };
    }
  }

  // الحصول على حالة المزامنة
  Future<Map<String, dynamic>> getSyncStatus() async {
    try {
      final stats = await _dbHelper.getSyncStats();
      final isConnected = await isConnectedToInternet();

      return {
        'isConnected': isConnected,
        'stats': stats,
        'lastSyncAttempt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error getting sync status: $e');
      return {
        'isConnected': false,
        'stats': {
          'totalUsers': 0,
          'syncedUsers': 0,
          'unsyncedUsers': 0,
          'syncPercentage': 0,
        },
        'lastSyncAttempt': 'Error',
      };
    }
  }
}
