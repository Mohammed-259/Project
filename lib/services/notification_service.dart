import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'dart:async';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _isInitialized = false;
  StreamController<String?>? _notificationStreamController;

  Stream<String?> get notificationStream =>
      _notificationStreamController?.stream ?? Stream.empty();

  /// Initialize local and Firebase notifications
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone for scheduled notifications
      tzdata.initializeTimeZones();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize Firebase messaging
      await _initializeFirebaseMessaging();

      _notificationStreamController = StreamController<String?>.broadcast();
      _isInitialized = true;

      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Error initializing notification service: $e');
    }
  }

  /// Initialize Flutter local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings iOSInit =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iOSInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _handleBackgroundNotificationResponse,
    );

    // Request Android 13+ permissions
    try {
      final android = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
      }
    } catch (e) {
      print('⚠️ Android permission request (may not be required): $e');
    }

    print('✅ Local notifications initialized');
  }

  /// Initialize Firebase messaging
  Future<void> _initializeFirebaseMessaging() async {
    // Request notification permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      String? token = await _messaging.getToken();
      print('✅ FCM Token obtained: ${token?.substring(0, 20)}...');

      // Handle messages in foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      print('✅ Firebase messaging initialized');
    } else {
      print('⚠️ Notification permissions not granted');
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📬 Foreground message received: ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'Medication Reminder',
        body: message.notification!.body ?? '',
        payload: message.data['medicineId'] ?? '',
      );

      _notificationStreamController?.add(message.data['medicineId']);
    }
  }

  /// Handle background message (static function)
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('📬 Background message received: ${message.notification?.title}');
  }

  /// Handle notification tap when app is in background
  void _handleNotificationTap(RemoteMessage message) {
    print('👆 Notification tapped: ${message.notification?.title}');
    _notificationStreamController?.add(message.data['medicineId']);
  }

  /// Handle notification response (local notifications)
  void _handleNotificationResponse(
    NotificationResponse response,
  ) {
    print('👆 Local notification tapped: ${response.payload}');
    _notificationStreamController?.add(response.payload);
  }

  /// Static handler for background notification responses
  static void _handleBackgroundNotificationResponse(
    NotificationResponse response,
  ) {
    print('👆 Background notification tapped: ${response.payload}');
  }

  /// Show local notification immediately
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    await _showLocalNotification(id: id, title: title, body: body, payload: payload);
  }

  /// Internal method to show local notification
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'medication_reminders',
        'Medication Reminders',
        channelDescription: 'Notifications for medicine reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
      );

      const DarwinNotificationDetails iOSDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _localNotifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );

      print('✅ Local notification shown: $title');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Schedule a notification at a specific time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String medicineId,
  }) async {
    try {
      final tzScheduledTime =
          tz.TZDateTime.from(scheduledTime, tz.local);

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'medication_reminders',
        'Medication Reminders',
        channelDescription: 'Notifications for medicine reminders',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iOSDetails =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        androidAllowWhileIdle: true,
        payload: medicineId,
      );

      print('✅ Notification scheduled for $scheduledTime: $title');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      print('✅ Notification cancelled: ID $id');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Send test notification
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      id: DateTime.now().millisecond,
      title: '🧪 Test Notification',
      body: 'This is a test notification for medication reminders',
      payload: 'test_payload',
    );
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController?.close();
  }
}
