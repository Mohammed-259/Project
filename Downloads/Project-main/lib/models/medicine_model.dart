// models/medicine_model.dart
class Medicine {
  final int? id;
  final int userId;
  final String name;
  final String dosage;
  final int timesPerDay;
  final int durationDays;
  final String imagePath;
  final String startDate;
  final bool isActive;
  bool isTaken;
  final String? lastTaken;
  final String? nextDoseTime;
  final List<String> reminderTimes;
  final bool notificationsEnabled;
  final int? lastNotificationTime; // Unix timestamp

  Medicine({
    this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.timesPerDay,
    required this.durationDays,
    required this.imagePath,
    required this.startDate,
    required this.isActive,
    this.isTaken = false,
    this.lastTaken,
    this.nextDoseTime,
    required this.reminderTimes,
    this.notificationsEnabled = true,
    this.lastNotificationTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'timesPerDay': timesPerDay,
      'durationDays': durationDays,
      'imagePath': imagePath,
      'startDate': startDate,
      'isActive': isActive ? 1 : 0,
      'isTaken': isTaken ? 1 : 0,
      'lastTaken': lastTaken,
      'nextDoseTime': nextDoseTime,
      'reminderTimes': reminderTimes.join(','),
      'notificationsEnabled': notificationsEnabled ? 1 : 0,
      'lastNotificationTime': lastNotificationTime,
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      dosage: map['dosage'],
      timesPerDay: map['timesPerDay'],
      durationDays: map['durationDays'],
      imagePath: map['imagePath'],
      startDate: map['startDate'],
      isActive: map['isActive'] == 1,
      isTaken: map['isTaken'] == 1,
      lastTaken: map['lastTaken'],
      nextDoseTime: map['nextDoseTime'],
      reminderTimes: map['reminderTimes'].toString().split(','),
      notificationsEnabled: map['notificationsEnabled'] != 0,
      lastNotificationTime: map['lastNotificationTime'],
    );
  }
}
