// models/user_session.dart
class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  UserSession._internal();

  int? _currentUserId;
  Map<String, dynamic>? _currentUserData;

  int? get currentUserId => _currentUserId;
  Map<String, dynamic>? get currentUserData => _currentUserData;

  void setUser(int userId, Map<String, dynamic> userData) {
    _currentUserId = userId;
    _currentUserData = userData;
  }

  void clear() {
    _currentUserId = null;
    _currentUserData = null;
  }

  bool get isLoggedIn => _currentUserId != null;
}
