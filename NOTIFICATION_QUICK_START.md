# Notification System - Quick Start Guide

## What Was Done

A complete **medication reminder notification system** has been implemented for your Flutter app. This system automatically sends notifications when it's time to take medicines.

---

## 🎯 Quick Overview

### Files Created
1. **`lib/services/notification_service.dart`** - Handles all notifications
2. **`lib/services/medication_scheduler.dart`** - Schedules reminders for medicines
3. **`lib/models/notification_model.dart`** - Data models for notifications
4. **`lib/core/helper/notification_helper.dart`** - Helper functions
5. **`NOTIFICATION_SYSTEM.md`** - Complete documentation

### Files Modified
1. **`pubspec.yaml`** - Added notification dependencies
2. **`lib/main.dart`** - Initialize notifications on app startup
3. **`lib/models/sqlite.dart`** - Added notification database tables
4. **`lib/models/medicine_model.dart`** - Added notification fields

---

## 🚀 How It Works

### Simple Flow
```
1. User adds medicine with reminder times (e.g., 8:00 AM, 2:00 PM)
   ↓
2. Notification system automatically schedules reminders
   ↓
3. At scheduled time, device shows notification
   ↓
4. User taps notification to mark medicine as taken
   ↓
5. System logs the interaction in database
```

---

## 📦 What You Get

### Features
✅ **Automatic reminders** - Scheduled based on medicine times  
✅ **Push notifications** - Sound, vibration, alerts  
✅ **Tracking** - Know which reminders user interacted with  
✅ **Analytics** - See medication adherence rates  
✅ **User preferences** - Let users customize notification settings  
✅ **Multiple medicines** - Support for many medicines with different schedules  
✅ **Smart scheduling** - Automatically recalculates for today/tomorrow  
✅ **Missed dose alerts** - Remind if dose was missed  

### Platforms Supported
- ✅ **Android** - Full notifications with sound & vibration
- ✅ **iOS** - Full notifications with badges
- ✅ **Firebase Cloud Messaging** - Remote notifications ready

---

## 💻 How to Use in Your Code

### 1. Initialize When User Logs In
```dart
import '/core/helper/notification_helper.dart';

// After successful login
final notificationHelper = NotificationHelper();
await notificationHelper.initializeUserNotifications(userId);
```

### 2. Handle When Medicine is Added
```dart
import '/core/helper/notification_helper.dart';

// When user adds a new medicine
final medicine = Medicine(
  name: 'Aspirin',
  reminderTimes: ['08:00', '14:00', '20:00'],
  // ... other fields
);

await NotificationHelper().onMedicineAdded(medicine);
```

### 3. Handle When Medicine is Marked as Taken
```dart
// When user confirms they took medicine
await NotificationHelper().onMedicineTaken(medicine, userId);
```

### 4. Get Next Reminder Time for Display
```dart
// In your home screen to show "Next dose at 2:00 PM"
final nextReminder = await NotificationHelper().getNextReminder(userId);
if (nextReminder != null) {
  final medicineName = nextReminder['medicine'].name;
  final time = nextReminder['formattedTime'];
  print('$medicineName at $time');
}
```

### 5. Get Medication Adherence Stats
```dart
// Show user their adherence rate
final stats = await NotificationHelper().getNotificationStats(userId);
print('You took medicines ${stats['interactionRate']}% on time');
```

---

## 🔌 Required Dependencies (Already Added)

```yaml
flutter_local_notifications: ^17.1.2  # Local device notifications
firebase_messaging: ^16.0.4           # Cloud notifications
timezone: ^0.9.3                      # Timezone support
intl: ^0.19.0                         # Date formatting
```

**These are already added to `pubspec.yaml` - just run:**
```bash
flutter pub get
```

---

## ⚙️ Configuration

### Firebase Setup
✅ Already configured:
- Firebase options in `lib/firebase_options.dart`
- Android configuration in `android/app/google-services.json`
- iOS configuration ready

### Permissions
✅ Already configured:
- Android: Notification permissions in manifest
- iOS: Permission prompt at runtime

### Database
✅ Already configured:
- New tables: `notification_preferences`, `notification_logs`
- Automatic on first app run

---

## 🧪 Testing

### Test Immediate Notification
```dart
import '/services/notification_service.dart';

await NotificationService().sendTestNotification();
// You should see a test notification on your device
```

### View Notification History
```dart
import '/models/sqlite.dart';

final logs = await DatabaseHelper().getNotificationLogs(userId);
for (final log in logs) {
  print('${log['title']} - Interacted: ${log['isInteracted'] == 1}');
}
```

### Check Pending Notifications
```dart
import '/services/notification_service.dart';

final pending = await NotificationService().getPendingNotifications();
print('${pending.length} notifications scheduled');
```

---

## 📱 UI Integration Examples

### Show Next Reminder in Home Screen
```dart
FutureBuilder<Map<String, dynamic>?>(
  future: NotificationHelper().getNextReminder(userId),
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      final next = snapshot.data!;
      return Card(
        child: Column(
          children: [
            Text('Next Reminder'),
            Text(next['medicine'].name),
            Text(next['formattedTime']),
          ],
        ),
      );
    }
    return Text('No reminders scheduled');
  },
)
```

### Notification Preferences Screen
```dart
// Allow users to customize notifications
await DatabaseHelper().updateNotificationPreference(
  userId,
  enableSound: true,
  enableVibration: true,
  minutesBefore: 5,
);
```

### Adherence Stats Widget
```dart
FutureBuilder<Map<String, dynamic>>(
  future: NotificationHelper().getNotificationStats(userId),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      final stats = snapshot.data!;
      return Text(
        'Adherence: ${stats['interactionRate']}% '
        '(${stats['interactedCount']}/${stats['totalNotifications']})',
      );
    }
    return Text('Loading stats...');
  },
)
```

---

## 🔍 How Reminders Are Scheduled

### Time Format
Use 24-hour format: `"08:00"`, `"14:30"`, `"20:00"`

### Automatic Calculations
- If time hasn't passed today → Schedule for today
- If time already passed → Schedule for tomorrow
- For first run → Schedule all active medicines

### Example
```dart
Medicine medicine = Medicine(
  name: 'Aspirin',
  reminderTimes: ['08:00', '14:00', '20:00'],
  startDate: '2025-11-25',
  isActive: true,
);

// System will schedule 3 notifications:
// 1. Aspirin at 08:00 (if before current time, tomorrow's 08:00)
// 2. Aspirin at 14:00 (if before current time, tomorrow's 14:00)
// 3. Aspirin at 20:00 (if before current time, tomorrow's 20:00)
```

---

## 📊 Database Tables

### notification_preferences
Stores user settings:
- enableNotifications (on/off)
- enableSound (on/off)
- enableVibration (on/off)
- minutesBefore (remind 5 min early)
- dailyReminder (future feature)

### notification_logs
Tracks all notifications:
- When scheduled
- When sent
- When user interacted
- Which medicine

---

## 🛠️ Troubleshooting

### Notifications Not Showing

**Check 1:** Are permissions granted?
```dart
final settings = await FirebaseMessaging.instance.requestPermission();
print(settings.authorizationStatus); // Should be AUTHORIZED
```

**Check 2:** Are medicines scheduled?
```dart
final medicines = await DatabaseHelper().getActiveMedicinesByUserId(userId);
print(medicines.length); // Should be > 0
```

**Check 3:** Check pending notifications
```dart
final pending = await NotificationService().getPendingNotifications();
print('Pending: ${pending.length}'); // Should be > 0
```

### Time Not Correct
- Verify reminder times format: `"HH:MM"` (24-hour)
- Check device timezone settings
- Verify medicine `startDate` is today or earlier

### App Crashes
- Ensure `flutter pub get` was run after changes
- Check logcat/console for error messages
- Verify all imports are correct

---

## 📚 Documentation Files

Complete documentation available:
- **`NOTIFICATION_SYSTEM.md`** - Detailed API reference & architecture
- **`NOTIFICATION_IMPLEMENTATION.md`** - What was implemented

---

## ✅ Checklist for Integration

- [ ] Run `flutter pub get` to install dependencies
- [ ] Initialize NotificationService in `main.dart` (already done)
- [ ] Call `NotificationHelper().initializeUserNotifications()` on login
- [ ] Handle medicine add/update/delete events
- [ ] Display next reminder in UI
- [ ] Add notification preferences screen
- [ ] Test on physical device (notifications require real device)
- [ ] Setup caregiver notifications (future enhancement)

---

## 🚀 Next Steps

1. **Test the system** on Android/iOS devices
2. **Add UI for notification preferences** (sound, vibration, timing)
3. **Implement adherence dashboard** using notification logs
4. **Add caregiver notifications** for monitor role
5. **Setup remote notifications** via Firebase Console

---

## 📞 Support

For detailed information:
- See `NOTIFICATION_SYSTEM.md` for complete API reference
- See `NOTIFICATION_IMPLEMENTATION.md` for implementation details
- Check comments in code for usage examples

---

**Status**: ✅ Ready to use  
**Date**: November 25, 2025
