# Medication Reminder Notification System

## Overview

A comprehensive notification system for the Medication Reminder app that provides:
- **Local Notifications**: Device-level reminders for medication schedules
- **Firebase Cloud Messaging (FCM)**: Remote push notifications
- **Smart Scheduling**: Automatic reminder scheduling based on medication timings
- **Notification Tracking**: Database logging of all notifications sent and interactions
- **User Preferences**: Customizable notification settings

---

## Architecture

### Core Components

#### 1. **NotificationService** (`lib/services/notification_service.dart`)
Handles all notification operations - both local and Firebase messaging.

**Key Features:**
- Initialize local and Firebase notifications
- Schedule notifications at specific times
- Handle foreground, background, and tap interactions
- Get FCM tokens for remote notifications
- Manage notification permissions

**Usage Example:**
```dart
final notificationService = NotificationService();
await notificationService.initialize();

// Send immediate notification
await notificationService.showLocalNotification(
  id: 1,
  title: 'Time for Aspirin',
  body: 'Dosage: 500mg',
  payload: 'medicine_1',
);

// Schedule for later
await notificationService.scheduleNotification(
  id: 2,
  title: 'Medication Reminder',
  body: 'Take your medicine at 2:00 PM',
  scheduledTime: DateTime.now().add(Duration(hours: 2)),
  medicineId: '1',
);
```

#### 2. **MedicationScheduler** (`lib/services/medication_scheduler.dart`)
Automatically schedules reminders based on medicine schedules.

**Key Features:**
- Schedule all medication reminders on app startup
- Parse reminder times from medicine schedules
- Handle recurring daily reminders
- Reschedule when medicine is updated
- Cancel reminders when medicine is deleted
- Get next reminder time for UI display

**Usage Example:**
```dart
final scheduler = MedicationScheduler();

// Schedule all reminders
await scheduler.scheduleAllMedicationReminders();

// Get next reminder
final nextTime = scheduler.getNextReminderTime(medicine);
final formatted = scheduler.getFormattedNextReminderTime(medicine);
print('Next dose at: $formatted');

// Reschedule after edit
await scheduler.rescheduleMedicineReminders(updatedMedicine);
```

#### 3. **NotificationHelper** (`lib/core/helper/notification_helper.dart`)
High-level utility for notification operations.

**Key Features:**
- Initialize user notifications
- Handle medicine lifecycle events
- Get next medication reminder
- Manage notification statistics
- Send missed dose reminders

**Usage Example:**
```dart
final helper = NotificationHelper();

// Initialize when user logs in
await helper.initializeUserNotifications(userId);

// Handle medicine events
await helper.onMedicineAdded(medicine);
await helper.onMedicineTaken(medicine, userId);

// Get statistics
final stats = await helper.getNotificationStats(userId);
print('Interaction rate: ${stats['interactionRate']}%');
```

#### 4. **NotificationModel** (`lib/models/notification_model.dart`)
Data models for notification management.

**Classes:**
- `NotificationLog`: Tracks sent notifications and interactions
- `NotificationPreference`: User notification preferences

---

## Database Schema

### notification_preferences Table
Stores user notification settings:
```sql
CREATE TABLE notification_preferences(
  id INTEGER PRIMARY KEY,
  userId INTEGER UNIQUE,
  enableNotifications INTEGER DEFAULT 1,
  enableSound INTEGER DEFAULT 1,
  enableVibration INTEGER DEFAULT 1,
  minutesBefore INTEGER DEFAULT 5,  -- Minutes to remind before dose
  dailyReminder INTEGER DEFAULT 0,
  createdAt TEXT,
  updatedAt TEXT,
  FOREIGN KEY (userId) REFERENCES users(id)
)
```

### notification_logs Table
Logs all notifications sent:
```sql
CREATE TABLE notification_logs(
  id INTEGER PRIMARY KEY,
  medicineId INTEGER,
  userId INTEGER,
  title TEXT,
  body TEXT,
  scheduledTime TEXT,
  sentTime TEXT,
  isDelivered INTEGER,
  isInteracted INTEGER,
  interactedAt TEXT,
  payload TEXT,
  createdAt TEXT,
  FOREIGN KEY (medicineId) REFERENCES medicines(id),
  FOREIGN KEY (userId) REFERENCES users(id)
)
```

---

## Integration Points

### 1. **App Startup** (main.dart)
```dart
void main() async {
  // ... existing initialization ...
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Schedule medication reminders
  MedicationScheduler().scheduleAllMedicationReminders();
  
  runApp(const MyApp());
}
```

### 2. **User Registration/Login**
```dart
// After successful login
await NotificationHelper().initializeUserNotifications(userId);
```

### 3. **Medicine Management**
```dart
// When medicine is added
await NotificationHelper().onMedicineAdded(medicine);

// When medicine is marked as taken
await NotificationHelper().onMedicineTaken(medicine, userId);

// When medicine is updated
await NotificationHelper().onMedicineUpdated(oldMedicine, newMedicine);

// When medicine is deleted
await NotificationHelper().onMedicineDeleted(medicine);
```

---

## Notification Flow

### Medicine Reminder Flow
```
1. Medicine added with reminder times (e.g., 08:00, 14:00, 20:00)
   ↓
2. MedicationScheduler parses times and creates notifications
   ↓
3. NotificationService schedules local notifications using timezone
   ↓
4. System triggers notification at scheduled time
   ↓
5. User sees notification in status bar
   ↓
6. User taps notification or marks medicine as taken
   ↓
7. NotificationHelper logs interaction in database
   ↓
8. UI updates with confirmation
```

### Daily Scheduling Flow
```
App Starts
   ↓
Initialize NotificationService (requests permissions)
   ↓
Call MedicationScheduler.scheduleAllMedicationReminders()
   ↓
For each active medicine:
  - Parse reminder times
  - Calculate next occurrence
  - Schedule local notification
  - Log to notification_logs table
   ↓
User receives reminders at scheduled times
```

---

## Features

### 1. **Smart Time Scheduling**
- Parses reminder times from medicine schedule
- Automatically calculates next occurrence
- Reschedules for tomorrow if all today's reminders passed
- Handles medication starting in the future

### 2. **Notification Preferences**
Users can customize:
- Enable/disable notifications globally
- Toggle sound alerts
- Toggle vibration
- Minutes before dose to notify (e.g., 5 minutes early)
- Daily summary reminders

### 3. **Notification Tracking**
Track for each notification:
- When scheduled
- When sent/delivered
- If user interacted with it
- Time of interaction
- Medicine associated with reminder

### 4. **Missed Dose Alerts**
- Remind user of missed doses
- Log missed dose attempts
- Analytics on adherence

### 5. **Multi-Platform Support**
- **Android**: Full support with vibration, sound, and priority levels
- **iOS**: Notification requests with custom sounds
- **Web**: FCM-based notifications (if configured)

---

## Configuration

### Required Dependencies (pubspec.yaml)
```yaml
dependencies:
  flutter_local_notifications: ^17.1.2
  firebase_messaging: ^16.0.4
  timezone: ^0.9.3
  intl: ^0.19.0
```

### Android Configuration (android/app/build.gradle.kts)
```kotlin
// Firebase already configured
// Notifications are supported on Android 5.0+
```

### iOS Configuration
- Add permissions in `ios/Runner/Info.plist`:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>Medication reminders require notification permissions</string>
```

### FCM Setup
1. Firebase project already configured in `lib/firebase_options.dart`
2. Android: `google-services.json` already present
3. iOS: GoogleService-Info.plist configured
4. FCM tokens automatically obtained and can be used for remote notifications

---

## API Reference

### NotificationService

```dart
// Initialize
Future<void> initialize()

// Show notification immediately
Future<void> showLocalNotification({
  required int id,
  required String title,
  required String body,
  required String payload,
})

// Schedule for specific time
Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledTime,
  required String medicineId,
})

// Manage notifications
Future<void> cancelNotification(int id)
Future<void> cancelAllNotifications()
Future<List<PendingNotificationRequest>> getPendingNotifications()
Future<String?> getFCMToken()
```

### MedicationScheduler

```dart
// Schedule reminders
Future<void> scheduleAllMedicationReminders()
Future<void> rescheduleMedicineReminders(Medicine medicine)
Future<void> cancelMedicineReminders(Medicine medicine)

// Query
DateTime? getNextReminderTime(Medicine medicine)
String? getFormattedNextReminderTime(Medicine medicine)
bool isMedicineDueToday(Medicine medicine)
Future<List<Medicine>> getMedicinesDueToday(int userId)
```

### DatabaseHelper

```dart
// Preferences
Future<int> addNotificationPreference(int userId, {...})
Future<Map?> getNotificationPreference(int userId)
Future<void> updateNotificationPreference(int userId, {...})

// Logging
Future<int> logNotification({...})
Future<void> markNotificationSent(int notificationLogId)
Future<void> markNotificationInteracted(int notificationLogId)

// Query
Future<List<Map>> getNotificationLogs(int userId, {int limit = 50})
Future<List<Map>> getInteractedNotifications(int userId)
Future<Map<String, dynamic>> getNotificationStats(int userId)

// Cleanup
Future<int> deleteOldNotificationLogs(int daysOld)
```

---

## Usage Examples

### Example 1: Send Medicine Reminder
```dart
final scheduler = MedicationScheduler();
final medicine = Medicine(
  id: 1,
  name: 'Aspirin',
  dosage: '500mg',
  reminderTimes: ['08:00', '14:00', '20:00'],
  // ... other fields
);

await scheduler.scheduleAllMedicationReminders();
```

### Example 2: Handle User Interaction
```dart
final notificationService = NotificationService();

// Listen to notification interactions
notificationService.notificationStream.listen((medicineId) {
  if (medicineId != null) {
    print('User tapped notification for medicine: $medicineId');
    // Update UI, navigate to medicine details, etc.
  }
});
```

### Example 3: Get Next Reminder
```dart
final helper = NotificationHelper();

final nextReminder = await helper.getNextReminder(userId);
if (nextReminder != null) {
  final medicine = nextReminder['medicine'] as Medicine;
  final time = nextReminder['formattedTime'] as String;
  print('Next dose: ${medicine.name} at $time');
}
```

### Example 4: User Notification Preferences
```dart
final dbHelper = DatabaseHelper();

// Get preferences
final prefs = await dbHelper.getNotificationPreference(userId);
print('Sound enabled: ${prefs?['enableSound'] == 1}');

// Update preferences
await dbHelper.updateNotificationPreference(
  userId,
  enableSound: false,
  minutesBefore: 10,
);
```

---

## Testing

### Test Notification
```dart
final notificationService = NotificationService();
await notificationService.sendTestNotification();
```

### Check Pending Notifications
```dart
final pending = await notificationService.getPendingNotifications();
print('Pending notifications: ${pending.length}');
for (final notif in pending) {
  print('- ${notif.title}: ${notif.body}');
}
```

### View Notification Logs
```dart
final logs = await dbHelper.getNotificationLogs(userId);
for (final log in logs) {
  print('Scheduled: ${log['scheduledTime']}');
  print('Interacted: ${log['isInteracted'] == 1}');
}
```

---

## Troubleshooting

### Notifications Not Showing
1. Check permissions are granted:
   ```dart
   final settings = await FirebaseMessaging.instance.requestPermission();
   print(settings.authorizationStatus);
   ```

2. Verify notifications are scheduled:
   ```dart
   final pending = await notificationService.getPendingNotifications();
   ```

3. Check database has active medicines:
   ```dart
   final medicines = await dbHelper.getActiveMedicinesByUserId(userId);
   ```

### Notification Permissions Issues

**Android:**
- Check `AndroidManifest.xml` has notification permissions
- Android 12+ requires runtime permissions in app

**iOS:**
- User must grant notification permission in Settings
- App must request permission at runtime

### Timezone Issues
- Ensure `timezone` package is properly initialized
- Use device timezone for scheduling (already handled)

---

## Future Enhancements

1. **Intelligent Reminders**
   - Machine learning for optimal reminder times
   - Skip reminders if user already took medicine

2. **Advanced Analytics**
   - Medication adherence reports
   - Reminder effectiveness analysis
   - Patterns in missed doses

3. **Social Features**
   - Caregiver notifications for monitor role
   - Shared medication calendars

4. **Extended Notifications**
   - Rich notifications with action buttons
   - Notification grouping by medicine

5. **Multi-Language Support**
   - Localized notification messages
   - User-preferred language for reminders

---

## Notes

- All times are stored in ISO 8601 format for consistency
- Notifications use unique IDs based on medicine ID + time index
- Database includes indexes for optimized notification queries
- Old notification logs can be cleaned up monthly to maintain performance
- FCM tokens are automatically managed by Firebase

---

**Last Updated:** November 25, 2025
