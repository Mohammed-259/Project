import 'package:intl/intl.dart';
import '/models/sqlite.dart';
import '/models/medicine_model.dart';
import 'notification_service.dart';

class MedicationScheduler {
  static final MedicationScheduler _instance =
      MedicationScheduler._internal();
  factory MedicationScheduler() => _instance;
  MedicationScheduler._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  /// Schedule reminders for all active medications
  Future<void> scheduleAllMedicationReminders() async {
    try {
      print('🔔 Scheduling reminders for all active medications...');

      // Get all active medicines from database
      final medicines = await _getAllActiveMedicines();

      if (medicines.isEmpty) {
        print('⚠️ No active medicines found for scheduling');
        return;
      }

      print('📋 Found ${medicines.length} active medicines');

      // Schedule reminders for each medicine
      for (final medicine in medicines) {
        await _scheduleMedicineReminders(medicine);
      }

      print('✅ All medication reminders scheduled successfully');
    } catch (e) {
      print('❌ Error scheduling reminders: $e');
    }
  }

  /// Get all active medicines
  Future<List<Medicine>> _getAllActiveMedicines() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.query(
        'medicines',
        where: 'isActive = ?',
        whereArgs: [1],
      );

      return result
          .map((map) => Medicine.fromMap(map))
          .toList();
    } catch (e) {
      print('❌ Error fetching active medicines: $e');
      return [];
    }
  }

  /// Schedule reminders for a specific medicine
  Future<void> _scheduleMedicineReminders(Medicine medicine) async {
    try {
      print('⏰ Scheduling reminders for: ${medicine.name}');

      // Parse reminder times
      final reminderTimes = medicine.reminderTimes;

      if (reminderTimes.isEmpty) {
        print('⚠️ No reminder times set for ${medicine.name}');
        return;
      }

      // Parse start date
      final startDate = DateTime.parse(medicine.startDate);
      final today = DateTime.now();

      // Only schedule if medicine is active (start date is today or earlier)
      if (startDate.isAfter(today)) {
        print('⏭️ Skipping ${medicine.name} - not yet started');
        return;
      }

      // Schedule reminders for each time slot
      for (int i = 0; i < reminderTimes.length; i++) {
        final timeStr = reminderTimes[i].trim();
        
        try {
          final scheduledTime = _parseTimeAndSchedule(timeStr, medicine, i);
          if (scheduledTime != null) {
            // Generate unique ID for this notification
            final notificationId = _generateNotificationId(medicine.id!, i);

            await _notificationService.scheduleNotification(
              id: notificationId,
              title: '💊 Time to take ${medicine.name}',
              body: 'Dosage: ${medicine.dosage} - ${reminderTimes.length} times daily',
              scheduledTime: scheduledTime,
              medicineId: '${medicine.id}',
            );
          }
        } catch (e) {
          print('❌ Error scheduling reminder for ${medicine.name} at $timeStr: $e');
        }
      }
    } catch (e) {
      print('❌ Error scheduling medicine reminders: $e');
    }
  }

  /// Parse time string and schedule for today
  DateTime? _parseTimeAndSchedule(
    String timeStr,
    Medicine medicine,
    int index,
  ) {
    try {
      // Expected format: "HH:MM" or "HH:MM:SS"
      final parts = timeStr.split(':');
      if (parts.length < 2) {
        print('⚠️ Invalid time format: $timeStr');
        return null;
      }

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      return scheduledTime;
    } catch (e) {
      print('❌ Error parsing time $timeStr: $e');
      return null;
    }
  }

  /// Generate unique notification ID
  int _generateNotificationId(int medicineId, int timeIndex) {
    // Combine medicine ID and time index to create unique ID
    // Ensure it's within Android's 32-bit int range
    return ((medicineId * 100) + timeIndex) % 2147483647;
  }

  /// Cancel reminders for a medicine
  Future<void> cancelMedicineReminders(Medicine medicine) async {
    try {
      print('🚫 Cancelling reminders for: ${medicine.name}');

      for (int i = 0; i < medicine.reminderTimes.length; i++) {
        final notificationId = _generateNotificationId(medicine.id!, i);
        await _notificationService.cancelNotification(notificationId);
      }

      print('✅ Reminders cancelled for ${medicine.name}');
    } catch (e) {
      print('❌ Error cancelling medicine reminders: $e');
    }
  }

  /// Reschedule reminders (e.g., when medicine is edited)
  Future<void> rescheduleMedicineReminders(Medicine medicine) async {
    try {
      await cancelMedicineReminders(medicine);
      await _scheduleMedicineReminders(medicine);
      print('✅ Reminders rescheduled for ${medicine.name}');
    } catch (e) {
      print('❌ Error rescheduling reminders: $e');
    }
  }

  /// Cancel all medication reminders
  Future<void> cancelAllReminders() async {
    try {
      print('🚫 Cancelling all medication reminders...');
      await _notificationService.cancelAllNotifications();
      print('✅ All reminders cancelled');
    } catch (e) {
      print('❌ Error cancelling all reminders: $e');
    }
  }

  /// Get next reminder time for a medicine
  DateTime? getNextReminderTime(Medicine medicine) {
    try {
      final reminderTimes = medicine.reminderTimes;
      if (reminderTimes.isEmpty) return null;

      final now = DateTime.now();
      DateTime? nextTime;

      for (final timeStr in reminderTimes) {
        final parts = timeStr.split(':');
        if (parts.length < 2) continue;

        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        var scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        if (scheduledTime.isAfter(now)) {
          if (nextTime == null || scheduledTime.isBefore(nextTime)) {
            nextTime = scheduledTime;
          }
        }
      }

      // If no time found today, return first time tomorrow
      if (nextTime == null && reminderTimes.isNotEmpty) {
        final parts = reminderTimes.first.split(':');
        if (parts.length >= 2) {
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          nextTime = DateTime(
            now.year,
            now.month,
            now.day + 1,
            hour,
            minute,
          );
        }
      }

      return nextTime;
    } catch (e) {
      print('❌ Error getting next reminder time: $e');
      return null;
    }
  }

  /// Get formatted next reminder time
  String? getFormattedNextReminderTime(Medicine medicine) {
    final nextTime = getNextReminderTime(medicine);
    if (nextTime == null) return null;

    try {
      final formatter = DateFormat('hh:mm a');
      return formatter.format(nextTime);
    } catch (e) {
      print('❌ Error formatting next reminder time: $e');
      return null;
    }
  }

  /// Check if medicine is due for today
  bool isMedicineDueToday(Medicine medicine) {
    try {
      final startDate = DateTime.parse(medicine.startDate);
      final today = DateTime.now();

      // Medicine is due if start date is today or earlier, and it's active
      return !startDate.isAfter(today) && medicine.isActive;
    } catch (e) {
      print('❌ Error checking if medicine is due: $e');
      return false;
    }
  }

  /// Get medicines due today for a specific user
  Future<List<Medicine>> getMedicinesDueToday(int userId) async {
    try {
      final medicines = await _dbHelper.getActiveMedicinesByUserId(userId);
      return medicines.where((m) => isMedicineDueToday(m)).toList();
    } catch (e) {
      print('❌ Error getting medicines due today: $e');
      return [];
    }
  }

  /// Send immediate notification for medicine
  Future<void> sendImmediateMedicineNotification(Medicine medicine) async {
    try {
      await _notificationService.showLocalNotification(
        id: medicine.id ?? DateTime.now().millisecond,
        title: '💊 ${medicine.name}',
        body: 'Time to take your medicine!\nDosage: ${medicine.dosage}',
        payload: '${medicine.id}',
      );
    } catch (e) {
      print('❌ Error sending immediate notification: $e');
    }
  }

  // Make showLocalNotification accessible for this class
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    // Implementation is in NotificationService
    throw UnimplementedError(
      'Use NotificationService.showLocalNotification directly',
    );
  }
}
