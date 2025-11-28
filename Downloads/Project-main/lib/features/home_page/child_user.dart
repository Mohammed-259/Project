import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/models/sqlite.dart';
import '/models/medicine_model.dart';
import '/models/user_session.dart';

class ChildHomeScreen extends StatefulWidget {
  final int currentUserId;

  const ChildHomeScreen({super.key, required this.currentUserId});

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  List<Medicine> _medicines = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;
  String _userRole = 'child';

  int get _currentUserId => widget.currentUserId;

  // ألوان متنوعة تناسب الأطفال وكبار السن
  final List<Color> _medicineColors = [
    const Color(0xFF4A90A4), // أزرق هادئ
    const Color(0xFF6AC2B0), // أخضر مريح
    const Color(0xFFFFB74D), // برتقالي دافئ
    const Color(0xFF9575CD), // بنفسجي ناعم
    const Color(0xFF4FC3F7), // أزرق فاتح
    const Color(0xFF81C784), // أخضر ناعم
    const Color(0xFFF48FB1), // وردي فاتح
    const Color(0xFF90CAF9), // أزرق سماوي
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMedicines();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await DatabaseHelper().getUserById(_currentUserId);
      if (_currentUser != null) {
        _userRole = _currentUser!['role']?.toString().toLowerCase() ?? 'child';
        UserSession().setUser(_currentUserId, _currentUser!);
      }
      setState(() {});
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadMedicines() async {
    try {
      final medicines = await DatabaseHelper().getActiveMedicinesByUserId(
        _currentUserId,
      );
      setState(() {
        _medicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medicines: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsTaken(Medicine medicine) async {
    try {
      await DatabaseHelper().markMedicineAsTaken(medicine.id!);

      // تأثير تفاعلي عند أخذ الدواء
      setState(() {
        medicine.isTaken = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getSuccessMessage(medicine.name)),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error marking medicine as taken'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await DatabaseHelper().logoutUser(_currentUserId);
      UserSession().clear();

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error during logout'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة الإعدادات الجديدة
  void _openSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildSettingsSheet(),
    );
  }

  // دالة تحديث البيانات
  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadMedicines();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data updated successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // دالة عرض معلومات المستخدم
  void _showUserInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${_currentUser?['name'] ?? 'N/A'}'),
            Text('Role: ${_userRole.toUpperCase()}'),
            Text('User ID: $_currentUserId'),
            SizedBox(height: 10),
            Text('Medicines Today: ${_medicines.length}'),
            Text('Taken: ${_getTakenCount()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getSuccessMessage(String medicineName) {
    if (_userRole == 'child') {
      return 'Great job! You took $medicineName 🎉';
    } else {
      return 'Well done! You took $medicineName ✅';
    }
  }

  Color _getMedicineColor(int index) {
    return _medicineColors[index % _medicineColors.length];
  }

  String _getMedicineEmoji(String medicineName) {
    if (medicineName.toLowerCase().contains('vitamin')) return '💊';
    if (medicineName.toLowerCase().contains('syrup')) return '🍯';
    if (medicineName.toLowerCase().contains('drop')) return '💧';
    if (medicineName.toLowerCase().contains('spray')) return '🌬️';
    if (medicineName.toLowerCase().contains('cream')) return '🧴';
    if (medicineName.toLowerCase().contains('pill')) return '💊';
    if (medicineName.toLowerCase().contains('tablet')) return '💊';
    if (medicineName.toLowerCase().contains('capsule')) return '💊';
    return '💊';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getUserTitle() {
    final userName = _currentUser?['name'] ?? '';
    if (_userRole == 'child') {
      return userName.isNotEmpty ? userName : 'Super Kid';
    } else {
      return userName.isNotEmpty ? userName : 'Valued User';
    }
  }

  String _getMotivationalMessage() {
    if (_userRole == 'child') {
      return 'Time to be healthy! 💪';
    } else {
      return 'Take care of your health 🌟';
    }
  }

  Color _getPrimaryColor() {
    return _userRole == 'child' ? Colors.blue.shade400 : Colors.purple.shade400;
  }

  Color _getBackgroundColor() {
    return _userRole == 'child' ? Colors.blue.shade50 : Colors.purple.shade50;
  }

  // بناء واجهة الإعدادات
  Widget _buildSettingsSheet() {
    final primaryColor = _getPrimaryColor();

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.white, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // User Info Section
                _settingsItem(
                  icon: Icons.person,
                  title: 'User Information',
                  subtitle: 'View your profile details',
                  onTap: _showUserInfo,
                ),

                // Refresh Data
                _settingsItem(
                  icon: Icons.refresh,
                  title: 'Refresh Data',
                  subtitle: 'Update medicines list',
                  onTap: _refreshData,
                ),

                // Notifications
                _settingsItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage reminders',
                  onTap: () {
                    // يمكن إضافة شاشة الإشعارات لاحقاً
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Notifications settings coming soon!'),
                      ),
                    );
                  },
                ),

                // About
                _settingsItem(
                  icon: Icons.info,
                  title: 'About',
                  subtitle: 'App information',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Medicine Reminder',
                      applicationVersion: '1.0.0',
                      children: [
                        Text('Take your medicines on time with ease!'),
                      ],
                    );
                  },
                ),

                // Logout
                _settingsItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out from your account',
                  onTap: _logout,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // عنصر الإعدادات
  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final primaryColor = _getPrimaryColor();

    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : primaryColor,
          size: 24.sp,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDestructive ? Colors.red : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: isDestructive ? Colors.red : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserTitle();
    final greeting = _getGreeting();
    final motivationalMessage = _getMotivationalMessage();
    final primaryColor = _getPrimaryColor();
    final backgroundColor = _getBackgroundColor();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, $userName!',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              motivationalMessage,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          // زر تحديث البيانات
          IconButton(
            icon: Icon(Icons.refresh, size: 20.sp),
            onPressed: _refreshData,
            color: Colors.white,
            tooltip: 'Refresh',
          ),
          // زر الإعدادات
          IconButton(
            icon: Icon(Icons.settings, size: 20.sp),
            onPressed: _openSettings,
            color: Colors.white,
            tooltip: 'Settings',
          ),
          // زر الخروج
          IconButton(
            icon: Icon(Icons.logout, size: 20.sp),
            onPressed: _logout,
            color: Colors.white,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              // Progress Section
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _medicines.isNotEmpty &&
                                _getTakenCount() == _medicines.length
                            ? Icons.celebration
                            : _userRole == 'child'
                            ? Icons.face
                            : Icons.health_and_safety,
                        color: Colors.white,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _medicines.isEmpty
                                ? 'No medicines today! 🎉'
                                : _userRole == 'child'
                                ? 'Medicine Time!'
                                : 'Medication Schedule',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          if (_medicines.isNotEmpty)
                            Text(
                              '${_getTakenCount()} of ${_medicines.length} taken',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14.sp,
                              ),
                            ),
                          if (_medicines.isNotEmpty) SizedBox(height: 8.h),
                          if (_medicines.isNotEmpty)
                            LinearProgressIndicator(
                              value: _medicines.isEmpty
                                  ? 0
                                  : _getTakenCount() / _medicines.length,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Today's Medications Title
              if (_medicines.isNotEmpty) ...[
                Text(
                  _userRole == 'child'
                      ? 'Your Medicines for Today'
                      : 'Your Medications for Today',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _userRole == 'child'
                      ? 'Tap when you take your medicine'
                      : 'Tap to mark medication as taken',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: primaryColor.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 20.h),
              ],

              // Big Colorful Medicine Cards
              _isLoading
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryColor,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Loading your medicines...',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _medicines.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.celebration,
                              size: 80.sp,
                              color: primaryColor.withOpacity(0.5),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No Medicines Today!',
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              _userRole == 'child'
                                  ? 'Enjoy your day! 🎉'
                                  : 'Have a healthy day! 🌟',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: primaryColor.withOpacity(0.8),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              _userRole == 'child'
                                  ? 'Your parent will add\nmedicines when needed'
                                  : 'Your caregiver will add\nmedications when needed',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: primaryColor.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshData,
                        backgroundColor: primaryColor,
                        color: Colors.white,
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: _medicines.length,
                          itemBuilder: (context, index) {
                            return _medicineCard(_medicines[index], index);
                          },
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _medicineCard(Medicine medicine, int index) {
    final color = _getMedicineColor(index);
    final emoji = _getMedicineEmoji(medicine.name);
    final isTaken = medicine.isTaken;
    final nextReminder = _getNextReminder(medicine);
    final primaryColor = _getPrimaryColor();

    return GestureDetector(
      onTap: isTaken ? null : () => _markAsTaken(medicine),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isTaken
              ? Colors.green.withOpacity(0.1)
              : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isTaken ? Colors.green : color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isTaken ? Colors.green : color).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Pattern
            if (!isTaken)
              Positioned(
                top: 10.h,
                right: 10.w,
                child: Opacity(
                  opacity: 0.1,
                  child: Text(emoji, style: TextStyle(fontSize: 40.sp)),
                ),
              ),

            // Content
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Medicine Icon/Emoji
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: (isTaken ? Colors.green : color).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(emoji, style: TextStyle(fontSize: 24.sp)),
                  ),
                  SizedBox(height: 12.h),

                  // Medicine Name
                  Text(
                    medicine.name.length > 12
                        ? '${medicine.name.substring(0, 12)}...'
                        : medicine.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isTaken ? Colors.green : color,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),

                  // Dosage
                  Text(
                    medicine.dosage,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: (isTaken ? Colors.green : color).withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Frequency
                  Text(
                    '${medicine.timesPerDay}x daily',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: (isTaken ? Colors.green : color).withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Next Reminder (if not taken)
                  if (!isTaken && nextReminder != null)
                    Text(
                      'Next: $nextReminder',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: color.withOpacity(0.7),
                      ),
                    )
                  else if (isTaken)
                    Text(
                      _userRole == 'child' ? 'Completed! 🎉' : 'Taken ✅',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.green.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: 8.h),

                  // Status Button - تم تعديل هذا الجزء
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 80.w, // تحديد أقصى عرض للزر
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w, // تقليل الـ padding الأفقي
                      vertical: 4.h, // تقليل الـ padding الرأسي
                    ),
                    decoration: BoxDecoration(
                      color: isTaken ? Colors.green : color,
                      borderRadius: BorderRadius.circular(
                        8.r,
                      ), // تقليل نصف القطر
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isTaken ? Icons.check : Icons.touch_app,
                          color: Colors.white,
                          size: 10.sp, // تقليل حجم الأيقونة
                        ),
                        SizedBox(width: 2.w), // تقليل المسافة
                        Flexible(
                          child: Text(
                            isTaken
                                ? (_userRole == 'child'
                                      ? 'DONE'
                                      : 'TAKEN') // إزالة الرموز لتقليل العرض
                                : 'TAP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp, // تقليل حجم الخط
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Taken Overlay
            if (isTaken)
              Container(
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _userRole == 'child' ? 'GREAT JOB!' : 'WELL DONE!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _userRole == 'child' ? '👍' : '🌟',
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _getTakenCount() {
    return _medicines.where((medicine) => medicine.isTaken).length;
  }

  String? _getNextReminder(Medicine medicine) {
    try {
      final now = DateTime.now();
      final times = medicine.reminderTimes;

      if (times.isNotEmpty) {
        for (final time in times) {
          if (time.isNotEmpty) {
            try {
              final timeParts = time.split(':');
              if (timeParts.length == 2) {
                final hour = int.tryParse(timeParts[0]);
                final minute = int.tryParse(timeParts[1]);

                if (hour != null && minute != null) {
                  final reminderTime = TimeOfDay(hour: hour, minute: minute);
                  final nowTime = TimeOfDay.fromDateTime(now);

                  if (reminderTime.hour > nowTime.hour ||
                      (reminderTime.hour == nowTime.hour &&
                          reminderTime.minute > nowTime.minute)) {
                    return '${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}';
                  }
                }
              }
            } catch (e) {
              continue;
            }
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
