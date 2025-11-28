import '/models/sqlite.dart';
import '/models/medicine_model.dart';
import '/services/notification_service.dart';
import '/services/medication_scheduler.dart';

class NotificationHelper {
  static final NotificationHelper _instance = NotificationHelper._internal();
  factory NotificationHelper() => _instance;
  NotificationHelper._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final MedicationScheduler _scheduler = MedicationScheduler();

  /// Initialize notifications for a user
  Future<void> initializeUserNotifications(int userId) async {
    try {
      print('🔔 Initializing notifications for user: $userId');

      // Create default notification preferences
      await _dbHelper.addNotificationPreference(userId);

      // Schedule all medication reminders
      final medicines = await _dbHelper.getActiveMedicinesByUserId(userId);
      for (final medicine in medicines) {
        await _scheduler.rescheduleMedicineReminders(medicine);
      }

      print('✅ User notifications initialized');
    } catch (e) {
      print('❌ Error initializing user notifications: $e');
    }
  }

  /// Handle medicine added event
  Future<void> onMedicineAdded(Medicine medicine) async {
    try {
      print('🔔 Scheduling notifications for new medicine: ${medicine.name}');
      // Schedule all medication reminders
      await _scheduler.scheduleAllMedicationReminders();
    } catch (e) {
      print('❌ Error scheduling medicine notifications: $e');
    }
  }

  /// Handle medicine updated event
  Future<void> onMedicineUpdated(Medicine oldMedicine, Medicine newMedicine) async {
    try {
      print('🔄 Rescheduling notifications for updated medicine: ${newMedicine.name}');
      await _scheduler.rescheduleMedicineReminders(newMedicine);
    } catch (e) {
      print('❌ Error rescheduling medicine notifications: $e');
    }
  }

  /// Handle medicine deleted event
  Future<void> onMedicineDeleted(Medicine medicine) async {
    try {
      print('🗑️ Cancelling notifications for deleted medicine: ${medicine.name}');
      await _scheduler.cancelMedicineReminders(medicine);
    } catch (e) {
      print('❌ Error cancelling medicine notifications: $e');
    }
  }

  /// Handle medicine marked as taken
  Future<void> onMedicineTaken(
    Medicine medicine,
    int userId,
  ) async {
    try {
      // Log notification interaction
      await _dbHelper.markNotificationInteracted(medicine.id ?? 0);

      print('✅ Medicine taken logged: ${medicine.name}');
    } catch (e) {
      print('❌ Error logging medicine taken: $e');
    }
  }

  /// Get next medication reminder for user
  Future<Map<String, dynamic>?> getNextReminder(int userId) async {
    try {
      final medicines = await _dbHelper.getActiveMedicinesByUserId(userId);

      if (medicines.isEmpty) return null;

      DateTime? nextTime;
      Medicine? nextMedicine;

      for (final medicine in medicines) {
        final reminderTime = _scheduler.getNextReminderTime(medicine);
        if (reminderTime != null) {
          if (nextTime == null || reminderTime.isBefore(nextTime)) {
            nextTime = reminderTime;
            nextMedicine = medicine;
          }
        }
      }

      if (nextMedicine == null || nextTime == null) return null;

      return {
        'medicine': nextMedicine,
        'nextTime': nextTime,
        'formattedTime': _scheduler.getFormattedNextReminderTime(nextMedicine),
      };
    } catch (e) {
      print('❌ Error getting next reminder: $e');
      return null;
    }
  }

  /// Get all pending notifications
  Future<List<Map<String, dynamic>>> getPendingNotifications(int userId) async {
    try {
      final notificationService = NotificationService();
      final pending = await notificationService.getPendingNotifications();
      print('📬 Found ${pending.length} pending notifications');
      return pending.map((n) => {'id': n.id, 'title': n.title}).toList();
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Enable/disable notifications for a medicine
  Future<void> setMedicineNotificationsEnabled(
    int medicineId,
    bool enabled,
  ) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'medicines',
        {'notificationsEnabled': enabled ? 1 : 0},
        where: 'id = ?',
        whereArgs: [medicineId],
      );

      print('${enabled ? '✅' : '🔕'} Notifications ${enabled ? 'enabled' : 'disabled'} for medicine: $medicineId');
    } catch (e) {
      print('❌ Error updating medicine notification status: $e');
    }
  }

  /// Get notification statistics
  Future<Map<String, dynamic>> getNotificationStats(int userId) async {
    try {
      return await _dbHelper.getNotificationStats(userId);
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

  /// Send missed dose reminder
  Future<void> sendMissedDoseReminder(
    Medicine medicine,
    int userId,
  ) async {
    try {
      final notificationService = NotificationService();
      await notificationService.scheduleNotification(
        id: (medicine.id ?? 0) + 10000,
        title: '⏰ Missed Dose Reminder',
        body: 'You may have missed a dose of ${medicine.name}',
        scheduledTime: DateTime.now().add(const Duration(seconds: 2)),
        medicineId: '${medicine.id}_missed',
      );

      print('⏰ Missed dose reminder sent for: ${medicine.name}');
    } catch (e) {
      print('❌ Error sending missed dose reminder: $e');
    }
  }

  /// Schedule daily medication summary
  Future<void> scheduleDailySummary(int userId) async {
    try {
      // This would be implemented to send a daily summary
      print('📊 Daily summary would be sent for user: $userId');
    } catch (e) {
      print('❌ Error scheduling daily summary: $e');
    }
  }

  /// Test notification
  Future<void> sendTestNotification() async {
    try {
      final notificationService = NotificationService();
      await notificationService.sendTestNotification();
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  /// Cleanup old notification logs
  Future<void> cleanupOldNotifications(int daysOld) async {
    try {
      final deleted = await _dbHelper.deleteOldNotificationLogs(daysOld);
      print('🧹 Cleaned up $deleted old notification logs');
    } catch (e) {
      print('❌ Error cleaning up notifications: $e');
    }
  }
}
