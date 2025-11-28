import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'medicine_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'medication_reminder.db');
    return await openDatabase(
      path,
<<<<<<< HEAD
      version: 8, // 🔥 تحديث الرقم لإضافة جداول الإشعارات
=======
      version: 6, // 🔥 تحديث الرقم
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT,
        role TEXT NOT NULL,
        birthDate TEXT NOT NULL,
        monitorId INTEGER,
        relationship TEXT,
        firebaseUid TEXT,
        isSynced INTEGER DEFAULT 0, -- 🔥 حقل جديد للمزامنة
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE medicines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        timesPerDay INTEGER NOT NULL,
        durationDays INTEGER NOT NULL,
        imagePath TEXT,
        startDate TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        isTaken INTEGER DEFAULT 0,
        lastTaken TEXT,
        nextDoseTime TEXT,
        reminderTimes TEXT NOT NULL,
        firebaseId TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // تحسين الأداء باستخدام الفهارس
    await db.execute('CREATE INDEX idx_user_id ON medicines(userId)');
    await db.execute('CREATE INDEX idx_user_role ON users(role)');
    await db.execute('CREATE INDEX idx_user_monitor ON users(monitorId)');
    await db.execute('CREATE INDEX idx_user_firebase ON users(firebaseUid)');
    await db.execute(
      'CREATE INDEX idx_user_synced ON users(isSynced)',
    ); // 🔥 فهرس جديد
<<<<<<< HEAD

    // 🔔 جداول الإشعارات
    await db.execute('''
      CREATE TABLE notification_preferences(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL UNIQUE,
        enableNotifications INTEGER DEFAULT 1,
        enableSound INTEGER DEFAULT 1,
        enableVibration INTEGER DEFAULT 1,
        minutesBefore INTEGER DEFAULT 5,
        dailyReminder INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE notification_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        sentTime TEXT,
        isDelivered INTEGER DEFAULT 0,
        isInteracted INTEGER DEFAULT 0,
        interactedAt TEXT,
        payload TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (medicineId) REFERENCES medicines (id) ON DELETE CASCADE,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Indexes for notification tables
    await db.execute('CREATE INDEX idx_notif_user ON notification_logs(userId)');
    await db.execute('CREATE INDEX idx_notif_medicine ON notification_logs(medicineId)');
    await db.execute('CREATE INDEX idx_notif_scheduled ON notification_logs(scheduledTime)');
    await db.execute('CREATE INDEX idx_notif_pref_user ON notification_preferences(userId)');
=======
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
<<<<<<< HEAD
    if (oldVersion < 8) {
      try {
        // Create notification preference table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notification_preferences(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL UNIQUE,
            enableNotifications INTEGER DEFAULT 1,
            enableSound INTEGER DEFAULT 1,
            enableVibration INTEGER DEFAULT 1,
            minutesBefore INTEGER DEFAULT 5,
            dailyReminder INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        print('✅ Created notification_preferences table');
      } catch (e) {
        print('⚠️ notification_preferences table may already exist: $e');
      }

      try {
        // Create notification logs table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS notification_logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            medicineId INTEGER NOT NULL,
            userId INTEGER NOT NULL,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            scheduledTime TEXT NOT NULL,
            sentTime TEXT,
            isDelivered INTEGER DEFAULT 0,
            isInteracted INTEGER DEFAULT 0,
            interactedAt TEXT,
            payload TEXT,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (medicineId) REFERENCES medicines (id) ON DELETE CASCADE,
            FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        print('✅ Created notification_logs table');

        // Create indexes
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notif_user ON notification_logs(userId)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notif_medicine ON notification_logs(medicineId)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notif_scheduled ON notification_logs(scheduledTime)');
        await db.execute('CREATE INDEX IF NOT EXISTS idx_notif_pref_user ON notification_preferences(userId)');
        print('✅ Created notification indexes');
      } catch (e) {
        print('⚠️ notification_logs table may already exist: $e');
      }
    }

=======
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
    if (oldVersion < 6) {
      try {
        await db.execute(
          'ALTER TABLE users ADD COLUMN isSynced INTEGER DEFAULT 0',
        );
        print('✅ Added isSynced column to users table');
      } catch (e) {
        print('⚠️ isSynced column may already exist: $e');
      }
    }

    if (oldVersion < 5) {
      try {
        await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
        await db.execute('ALTER TABLE users ADD COLUMN firebaseUid TEXT');
        await db.execute('ALTER TABLE medicines ADD COLUMN firebaseId TEXT');
        await db.execute('ALTER TABLE medicines ADD COLUMN createdAt TEXT');
        await db.execute('ALTER TABLE medicines ADD COLUMN updatedAt TEXT');
        await db.execute('ALTER TABLE medicines ADD COLUMN imagePath TEXT');
      } catch (e) {
        print('⚠️ Upgrade error (columns may already exist): $e');
      }
    }
  }

  // ================= دوال المستخدمين =================

  Future<int> addUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      user['createdAt'] = DateTime.now().toIso8601String();
      user['updatedAt'] = DateTime.now().toIso8601String();

      if (user['role'] == null || user['role'].toString().isEmpty) {
        user['role'] = 'adult';
        print('⚠️ Setting default role for user: ${user['name']}');
      }

      // 🔥 التأكد من وجود حقل isSynced
      user['isSynced'] = user['isSynced'] ?? false;

      print(
        '💾 Saving user with role: ${user['role']}, Synced: ${user['isSynced']}',
      );
      final userId = await db.insert('users', user);
      print('✅ User saved successfully - ID: $userId, Role: ${user['role']}');
      return userId;
    } catch (e) {
      print('❌ Error adding user: $e');
      rethrow;
    }
  }

  Future<int> addDependent(Map<String, dynamic> dependent) async =>
      await addUser(dependent);

  Future<List<Map<String, dynamic>>> getDependentsByMonitorId(
    int monitorId,
  ) async {
    final db = await database;
    try {
      final maps = await db.query(
        'users',
        where: 'monitorId = ? AND role IN (?, ?)',
        whereArgs: [monitorId, 'child', 'elderly'],
        orderBy: 'name ASC',
      );
      return maps;
    } catch (e) {
      print('❌ Error getting dependents: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    try {
      final maps = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return maps.isNotEmpty ? maps.first : null;
    } catch (e) {
      print('❌ Error getting user by email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'id = ?',
        whereArgs: [userId],
      );

      if (maps.isNotEmpty) {
        print('User found: ${maps.first}');
        return maps.first;
      } else {
        print('User not found with id: $userId');
        return null;
      }
    } catch (e) {
      print('Error in getUserById: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByFirebaseUid(String uid) async {
    final db = await database;
    try {
      final maps = await db.query(
        'users',
        where: 'firebaseUid = ?',
        whereArgs: [uid],
      );
      return maps.isNotEmpty ? maps.first : null;
    } catch (e) {
      print('❌ Error getting user by Firebase UID: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    try {
      return await db.query('users');
    } catch (e) {
      print('❌ Error getting all users: $e');
      return [];
    }
  }

  Future<int> deleteDependent(int id) async {
    final db = await database;
    try {
      await db.delete('medicines', where: 'userId = ?', whereArgs: [id]);
      return await db.delete('users', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Error deleting dependent: $e');
      rethrow;
    }
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      user['updatedAt'] = DateTime.now().toIso8601String();
      return await db.update(
        'users',
        user,
        where: 'id = ?',
        whereArgs: [user['id']],
      );
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }

  Future<int> updateUserProfile(
    int userId,
    Map<String, dynamic> updates,
  ) async {
    final db = await database;
    try {
      updates['updatedAt'] = DateTime.now().toIso8601String();
      return await db.update(
        'users',
        updates,
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('❌ Error updating user profile: $e');
      rethrow;
    }
  }

  // ================= دوال الأدوية =================

  Future<int> insertMedicine(Medicine medicine) async {
    final db = await database;
    try {
      final map = medicine.toMap();
      map['createdAt'] = DateTime.now().toIso8601String();
      map['updatedAt'] = DateTime.now().toIso8601String();
      return await db.insert('medicines', map);
    } catch (e) {
      print('❌ Error inserting medicine: $e');
      rethrow;
    }
  }

  Future<List<Medicine>> getMedicinesByUserId(int userId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'medicines',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'name ASC',
      );
      return maps.map((m) => Medicine.fromMap(m)).toList();
    } catch (e) {
      print('❌ Error getting medicines by user ID: $e');
      return [];
    }
  }

  // في ملف DatabaseHelper
  Future<List<Medicine>> getActiveMedicinesByUserId(int userId) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'medicines',
        where: 'userId = ? AND isActive = ?',
        whereArgs: [userId, 1],
      );

      // تحقق من وجود البيانات
      print('Found ${maps.length} medicines for user $userId');

      return List.generate(maps.length, (i) {
        return Medicine.fromMap(maps[i]);
      });
    } catch (e) {
      print('Error in getActiveMedicinesByUserId: $e');
      return [];
    }
  }

  Future<List<Medicine>> getMedicinesForReminder() async {
    final db = await database;
    try {
      final now = DateTime.now().toIso8601String();
      final maps = await db.query(
        'medicines',
        where: 'isActive = ? AND nextDoseTime <= ?',
        whereArgs: [1, now],
      );
      return maps.map((m) => Medicine.fromMap(m)).toList();
    } catch (e) {
      print('❌ Error getting medicines for reminder: $e');
      return [];
    }
  }

  Future<int> updateMedicine(Medicine medicine) async {
    final db = await database;
    try {
      final map = medicine.toMap();
      map['updatedAt'] = DateTime.now().toIso8601String();
      return await db.update(
        'medicines',
        map,
        where: 'id = ?',
        whereArgs: [medicine.id],
      );
    } catch (e) {
      print('❌ Error updating medicine: $e');
      rethrow;
    }
  }

  Future<int> markMedicineAsTaken(int medicineId) async {
    final db = await database;
    try {
      final now = DateTime.now().toIso8601String();
      return await db.update(
        'medicines',
        {'isTaken': 1, 'lastTaken': now, 'updatedAt': now},
        where: 'id = ?',
        whereArgs: [medicineId],
      );
    } catch (e) {
      print('❌ Error marking medicine as taken: $e');
      rethrow;
    }
  }

  Future<int> resetTakenMedicines(int userId) async {
    final db = await database;
    try {
      return await db.update(
        'medicines',
        {'isTaken': 0, 'updatedAt': DateTime.now().toIso8601String()},
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('❌ Error resetting taken medicines: $e');
      rethrow;
    }
  }

  Future<int> deleteMedicine(int id) async {
    final db = await database;
    try {
      return await db.delete('medicines', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('❌ Error deleting medicine: $e');
      rethrow;
    }
  }

  Future<int> getTakenMedicinesCount(int userId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'medicines',
        where: 'userId = ? AND isTaken = ?',
        whereArgs: [userId, 1],
      );
      return maps.length;
    } catch (e) {
      print('❌ Error getting taken medicines count: $e');
      return 0;
    }
  }

  Future<int> getTotalMedicinesCount(int userId) async {
    final db = await database;
    try {
      final maps = await db.query(
        'medicines',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      return maps.length;
    } catch (e) {
      print('❌ Error getting total medicines count: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getAllMonitors() async {
    final db = await database;
    try {
      return await db.query('users', where: 'role = ?', whereArgs: ['monitor']);
    } catch (e) {
      print('❌ Error getting all monitors: $e');
      return [];
    }
  }

  Future<void> logoutUser(int userId) async {
    try {
      print('✅ User $userId logged out - data remains local');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  // ================= دوال إضافية =================

  Future<void> linkFirebaseUser(String email, String firebaseUid) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {
          'firebaseUid': firebaseUid,
          'isSynced': 1, // 🔥 تحديث حالة المزامنة
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'email = ?',
        whereArgs: [email],
      );
      print('✅ Firebase user linked successfully');
    } catch (e) {
      print('❌ Error linking Firebase user: $e');
      rethrow;
    }
  }

  Future<void> initializeUserAfterSignup(Map<String, dynamic> userData) async {
    try {
      final existingUser = await getUserByEmail(userData['email']);
      if (existingUser == null) {
        await addUser({
          'name': userData['name'],
          'email': userData['email'],
          'password': userData['password'] ?? '',
          'role': userData['role'],
          'birthDate': userData['birthDate'],
          'monitorId': userData['monitorId'],
          'relationship': userData['relationship'],
          'firebaseUid': userData['firebaseUid'],
          'isSynced': userData['isSynced'] ?? false, // 🔥 إضافة حالة المزامنة
        });
        print('✅ New user initialized after signup');
      } else {
        await linkFirebaseUser(userData['email'], userData['firebaseUid']);
        print('✅ Existing user linked with Firebase');
      }
    } catch (e) {
      print('❌ Error initializing user after signup: $e');
      rethrow;
    }
  }

  Future<void> recreateDatabase() async {
    String path = join(await getDatabasesPath(), 'medication_reminder.db');
    try {
      await deleteDatabase(path);
      print('✅ Database deleted successfully');
    } catch (e) {
      print('❌ Error deleting database: $e');
    }
    _database = null;
    _database = await _initDatabase();
    print('✅ Database recreated successfully');
  }

  Future<bool> validateDatabase() async {
    try {
      final db = await database;
      await db.query('users', limit: 1);
      await db.query('medicines', limit: 1);
      print('✅ Database validation successful');
      return true;
    } catch (e) {
      print('❌ Database validation failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserStats(int userId) async {
    try {
      final totalMeds = await getTotalMedicinesCount(userId);
      final takenMeds = await getTakenMedicinesCount(userId);
      final activeMeds = (await getActiveMedicinesByUserId(userId)).length;

      return {
        'totalMedicines': totalMeds,
        'takenMedicines': takenMeds,
        'activeMedicines': activeMeds,
        'complianceRate': totalMeds > 0 ? (takenMeds / totalMeds * 100) : 0,
      };
    } catch (e) {
      print('❌ Error getting user stats: $e');
      return {
        'totalMedicines': 0,
        'takenMedicines': 0,
        'activeMedicines': 0,
        'complianceRate': 0,
      };
    }
  }

  Future<void> cleanupExpiredMedicines() async {
    final db = await database;
    try {
      final thirtyDaysAgo = DateTime.now()
          .subtract(Duration(days: 30))
          .toIso8601String();
      await db.delete(
        'medicines',
        where: 'isActive = ? AND updatedAt < ?',
        whereArgs: [0, thirtyDaysAgo],
      );
      print('✅ Expired medicines cleaned up');
    } catch (e) {
      print('❌ Error cleaning up expired medicines: $e');
    }
  }

  Future<List<Map<String, dynamic>>> exportUserData(int userId) async {
    try {
      final user = await getUserById(userId);
      final medicines = await getMedicinesByUserId(userId);
      return [
        {'user': user},
        {'medicines': medicines.map((m) => m.toMap()).toList()},
      ];
    } catch (e) {
      print('❌ Error exporting user data: $e');
      return [];
    }
  }

  Future<void> validateAndFixUserRoles() async {
    final db = await database;
    try {
      final users = await getAllUsers();
      for (final user in users) {
        final role = user['role'] as String?;
        if (role == null || role.isEmpty) {
          print('⚠️ Fixing user role for user: ${user['id']}');
          await db.update(
            'users',
            {'role': 'adult', 'updatedAt': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [user['id']],
          );
        }
      }
      print('✅ User roles validated and fixed');
    } catch (e) {
      print('❌ Error validating user roles: $e');
    }
  }

  Future<void> debugAllUsers() async {
    final db = await database;
    try {
      final users = await db.query('users');
      print('👥 ALL USERS IN DATABASE:');
      for (final user in users) {
        print(
          '   - ID: ${user['id']}, Name: ${user['name']}, Email: ${user['email']}, Role: ${user['role']}, Synced: ${user['isSynced']}, Firebase UID: ${user['firebaseUid']}',
        );
      }
    } catch (e) {
      print('❌ Error debugging users: $e');
    }
  }

  Future<void> debugUserData(int userId) async {
    try {
      final user = await getUserById(userId);
      if (user != null) {
        print(
          '🔍 DEBUG USER DATA: ID: ${user['id']}, Name: ${user['name']}, Email: ${user['email']}, Role: ${user['role']}, Synced: ${user['isSynced']}, Firebase UID: ${user['firebaseUid']}',
        );
      } else {
        print('❌ User not found with ID: $userId');
      }
    } catch (e) {
      print('❌ Error debugging user data: $e');
    }
  }

  // 🔥 دوال المزامنة الجديدة
  Future<void> updateUserFirebaseData(
    int userId,
    String firebaseUid,
    bool isSynced,
  ) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {
          'firebaseUid': firebaseUid,
          'isSynced': isSynced ? 1 : 0,
          'updatedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [userId],
      );
      print('✅ Updated Firebase data for user: $userId');
    } catch (e) {
      print('❌ Error updating Firebase data: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getUnsyncedUsers() async {
    final db = await database;
    try {
      return await db.query(
        'users',
        where: 'isSynced = ? OR isSynced IS NULL',
        whereArgs: [0],
      );
    } catch (e) {
      print('❌ Error getting unsynced users: $e');
      return [];
    }
  }

  // 🔥 دالة جديدة للحصول على إحصائيات المزامنة
  Future<Map<String, dynamic>> getSyncStats() async {
    try {
      final allUsers = await getAllUsers();
      final unsyncedUsers = await getUnsyncedUsers();

      return {
        'totalUsers': allUsers.length,
        'syncedUsers': allUsers.length - unsyncedUsers.length,
        'unsyncedUsers': unsyncedUsers.length,
        'syncPercentage': allUsers.isNotEmpty
            ? ((allUsers.length - unsyncedUsers.length) / allUsers.length * 100)
                  .round()
            : 0,
      };
    } catch (e) {
      print('❌ Error getting sync stats: $e');
      return {
        'totalUsers': 0,
        'syncedUsers': 0,
        'unsyncedUsers': 0,
        'syncPercentage': 0,
      };
    }
  }

  Future<bool> verifyUserObserverRelationship(
    int childId,
    int observerId,
  ) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> maps = await db.query(
        'users', // أو اسم الجدول اللي بيخزن العلاقات
        where: 'id = ? AND observerId = ?',
        whereArgs: [childId, observerId],
      );

      return maps.isNotEmpty;
    } catch (e) {
      print('Error verifying relationship: $e');
      return false;
    }
  }

  // في DatabaseHelper
  Future<void> checkDatabaseIntegrity() async {
    final db = await database;

    try {
      // فحص جدول المستخدمين
      final users = await db.query('users');
      print('Total users in database: ${users.length}');

      // فحص جدول الأدوية
      final medicines = await db.query('medicines');
      print('Total medicines in database: ${medicines.length}');

      // طباعة جميع المستخدمين
      for (var user in users) {
        print('User: ${user['id']} - ${user['name']} - ${user['role']}');
      }
    } catch (e) {
      print('Database integrity check failed: $e');
    }
  }
<<<<<<< HEAD

  // ================= 🔔 دوال الإشعارات =================

  /// إضافة تفضيلات الإشعارات للمستخدم
  Future<int> addNotificationPreference(
    int userId, {
    bool enableNotifications = true,
    bool enableSound = true,
    bool enableVibration = true,
    int minutesBefore = 5,
    bool dailyReminder = false,
  }) async {
    final db = await database;
    try {
      final existing = await db.query(
        'notification_preferences',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (existing.isNotEmpty) {
        return existing.first['id'] as int;
      }

      final id = await db.insert(
        'notification_preferences',
        {
          'userId': userId,
          'enableNotifications': enableNotifications ? 1 : 0,
          'enableSound': enableSound ? 1 : 0,
          'enableVibration': enableVibration ? 1 : 0,
          'minutesBefore': minutesBefore,
          'dailyReminder': dailyReminder ? 1 : 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );

      print('✅ Notification preference added for user: $userId');
      return id;
    } catch (e) {
      print('❌ Error adding notification preference: $e');
      return -1;
    }
  }

  /// الحصول على تفضيلات الإشعارات
  Future<Map<String, dynamic>?> getNotificationPreference(int userId) async {
    final db = await database;
    try {
      final result = await db.query(
        'notification_preferences',
        where: 'userId = ?',
        whereArgs: [userId],
      );

      if (result.isNotEmpty) {
        return result.first;
      }

      // إنشاء تفضيلات افتراضية إذا لم تكن موجودة
      await addNotificationPreference(userId);
      return await db.query(
        'notification_preferences',
        where: 'userId = ?',
        whereArgs: [userId],
      ).then((r) => r.isNotEmpty ? r.first : null);
    } catch (e) {
      print('❌ Error getting notification preference: $e');
      return null;
    }
  }

  /// تحديث تفضيلات الإشعارات
  Future<void> updateNotificationPreference(
    int userId, {
    bool? enableNotifications,
    bool? enableSound,
    bool? enableVibration,
    int? minutesBefore,
    bool? dailyReminder,
  }) async {
    final db = await database;
    try {
      final updates = <String, dynamic>{
        'updatedAt': DateTime.now().toIso8601String(),
      };

      if (enableNotifications != null) {
        updates['enableNotifications'] = enableNotifications ? 1 : 0;
      }
      if (enableSound != null) {
        updates['enableSound'] = enableSound ? 1 : 0;
      }
      if (enableVibration != null) {
        updates['enableVibration'] = enableVibration ? 1 : 0;
      }
      if (minutesBefore != null) {
        updates['minutesBefore'] = minutesBefore;
      }
      if (dailyReminder != null) {
        updates['dailyReminder'] = dailyReminder ? 1 : 0;
      }

      await db.update(
        'notification_preferences',
        updates,
        where: 'userId = ?',
        whereArgs: [userId],
      );

      print('✅ Notification preference updated for user: $userId');
    } catch (e) {
      print('❌ Error updating notification preference: $e');
    }
  }

  /// إضافة سجل الإشعارات
  Future<int> logNotification({
    required int medicineId,
    required int userId,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final db = await database;
    try {
      final id = await db.insert(
        'notification_logs',
        {
          'medicineId': medicineId,
          'userId': userId,
          'title': title,
          'body': body,
          'scheduledTime': scheduledTime.toIso8601String(),
          'isDelivered': 0,
          'isInteracted': 0,
          'payload': payload,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      return id;
    } catch (e) {
      print('❌ Error logging notification: $e');
      return -1;
    }
  }

  /// تحديث حالة الإشعار (تم إرساله)
  Future<void> markNotificationSent(int notificationLogId) async {
    final db = await database;
    try {
      await db.update(
        'notification_logs',
        {
          'isDelivered': 1,
          'sentTime': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [notificationLogId],
      );
    } catch (e) {
      print('❌ Error marking notification as sent: $e');
    }
  }

  /// تحديث حالة التفاعل مع الإشعار
  Future<void> markNotificationInteracted(int notificationLogId) async {
    final db = await database;
    try {
      await db.update(
        'notification_logs',
        {
          'isInteracted': 1,
          'interactedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [notificationLogId],
      );
    } catch (e) {
      print('❌ Error marking notification as interacted: $e');
    }
  }

  /// الحصول على سجل الإشعارات للمستخدم
  Future<List<Map<String, dynamic>>> getNotificationLogs(
    int userId, {
    int limit = 50,
  }) async {
    final db = await database;
    try {
      return await db.query(
        'notification_logs',
        where: 'userId = ?',
        whereArgs: [userId],
        orderBy: 'scheduledTime DESC',
        limit: limit,
      );
    } catch (e) {
      print('❌ Error getting notification logs: $e');
      return [];
    }
  }

  /// الحصول على الإشعارات المتفاعل معها
  Future<List<Map<String, dynamic>>> getInteractedNotifications(
    int userId,
  ) async {
    final db = await database;
    try {
      return await db.query(
        'notification_logs',
        where: 'userId = ? AND isInteracted = ?',
        whereArgs: [userId, 1],
        orderBy: 'interactedAt DESC',
      );
    } catch (e) {
      print('❌ Error getting interacted notifications: $e');
      return [];
    }
  }

  /// حذف سجلات الإشعارات القديمة (مثلاً أقدم من 30 يوم)
  Future<int> deleteOldNotificationLogs(int daysOld) async {
    final db = await database;
    try {
      final cutoffDate =
          DateTime.now().subtract(Duration(days: daysOld)).toIso8601String();

      final result = await db.delete(
        'notification_logs',
        where: 'createdAt < ?',
        whereArgs: [cutoffDate],
      );

      print('✅ Deleted $result old notification logs');
      return result;
    } catch (e) {
      print('❌ Error deleting old notification logs: $e');
      return -1;
    }
  }

  /// إحصائيات الإشعارات
  Future<Map<String, dynamic>> getNotificationStats(int userId) async {
    try {
      final db = await database;

      // إجمالي الإشعارات المرسلة
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notification_logs WHERE userId = ?',
        [userId],
      );
      final total = totalResult.first['count'] as int? ?? 0;

      // الإشعارات المتفاعل معها
      final interactedResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notification_logs WHERE userId = ? AND isInteracted = 1',
        [userId],
      );
      final interacted = interactedResult.first['count'] as int? ?? 0;

      // الإشعارات التي لم يتم التفاعل معها
      final ignoredResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notification_logs WHERE userId = ? AND isInteracted = 0',
        [userId],
      );
      final ignored = ignoredResult.first['count'] as int? ?? 0;

      return {
        'totalNotifications': total,
        'interactedCount': interacted,
        'ignoredCount': ignored,
        'interactionRate': total > 0 ? (interacted / total * 100).toStringAsFixed(2) : '0',
      };
    } catch (e) {
      print('❌ Error getting notification stats: $e');
      return {
        'totalNotifications': 0,
        'interactedCount': 0,
        'ignoredCount': 0,
        'interactionRate': '0',
      };
    }
  }
}

=======
}
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
