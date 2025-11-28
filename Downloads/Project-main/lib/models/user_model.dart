// lib/features/auth/models/user_model.dart
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'adult', 'monitor', 'child'
  final DateTime birthDate;
  final String? monitorId;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.birthDate,
    this.monitorId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'birthDate': birthDate.toIso8601String(),
      'monitorId': monitorId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      name: map['name'],
      email: map['email'],
      role: map['role'],
      birthDate: DateTime.parse(map['birthDate']),
      monitorId: map['monitorId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
