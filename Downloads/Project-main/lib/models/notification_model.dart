/// Model for tracking notification details
class NotificationLog {
  final int? id;
  final int medicineId;
  final int userId;
  final String title;
  final String body;
  final DateTime scheduledTime;
  final DateTime? sentTime;
  final bool isDelivered;
  final bool isInteracted;
  final DateTime? interactedAt;
  final String? payload;

  NotificationLog({
    this.id,
    required this.medicineId,
    required this.userId,
    required this.title,
    required this.body,
    required this.scheduledTime,
    this.sentTime,
    this.isDelivered = false,
    this.isInteracted = false,
    this.interactedAt,
    this.payload,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'userId': userId,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime.toIso8601String(),
      'sentTime': sentTime?.toIso8601String(),
      'isDelivered': isDelivered ? 1 : 0,
      'isInteracted': isInteracted ? 1 : 0,
      'interactedAt': interactedAt?.toIso8601String(),
      'payload': payload,
    };
  }

  factory NotificationLog.fromMap(Map<String, dynamic> map) {
    return NotificationLog(
      id: map['id'],
      medicineId: map['medicineId'],
      userId: map['userId'],
      title: map['title'],
      body: map['body'],
      scheduledTime: DateTime.parse(map['scheduledTime']),
      sentTime: map['sentTime'] != null ? DateTime.parse(map['sentTime']) : null,
      isDelivered: map['isDelivered'] == 1,
      isInteracted: map['isInteracted'] == 1,
      interactedAt:
          map['interactedAt'] != null ? DateTime.parse(map['interactedAt']) : null,
      payload: map['payload'],
    );
  }
}

/// Model for medicine notification preferences
class NotificationPreference {
  final int? id;
  final int userId;
  final bool enableNotifications;
  final bool enableSound;
  final bool enableVibration;
  final int minutesBefore; // Minutes to notify before scheduled time
  final bool dailyReminder; // Send daily summary

  NotificationPreference({
    this.id,
    required this.userId,
    this.enableNotifications = true,
    this.enableSound = true,
    this.enableVibration = true,
    this.minutesBefore = 5,
    this.dailyReminder = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'enableNotifications': enableNotifications ? 1 : 0,
      'enableSound': enableSound ? 1 : 0,
      'enableVibration': enableVibration ? 1 : 0,
      'minutesBefore': minutesBefore,
      'dailyReminder': dailyReminder ? 1 : 0,
    };
  }

  factory NotificationPreference.fromMap(Map<String, dynamic> map) {
    return NotificationPreference(
      id: map['id'],
      userId: map['userId'],
      enableNotifications: map['enableNotifications'] == 1,
      enableSound: map['enableSound'] == 1,
      enableVibration: map['enableVibration'] == 1,
      minutesBefore: map['minutesBefore'] ?? 5,
      dailyReminder: map['dailyReminder'] == 1,
    );
  }

  NotificationPreference copyWith({
    int? id,
    int? userId,
    bool? enableNotifications,
    bool? enableSound,
    bool? enableVibration,
    int? minutesBefore,
    bool? dailyReminder,
  }) {
    return NotificationPreference(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      enableSound: enableSound ?? this.enableSound,
      enableVibration: enableVibration ?? this.enableVibration,
      minutesBefore: minutesBefore ?? this.minutesBefore,
      dailyReminder: dailyReminder ?? this.dailyReminder,
    );
  }
}
