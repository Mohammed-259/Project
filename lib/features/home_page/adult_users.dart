import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/models/sqlite.dart';
import '/models/medicine_model.dart';
import '/models/user_session.dart';
import '/features/onboarding/views/add_medicine.dart';
import '/features/onboarding/views/profile_screen.dart';
import '/features/onboarding/views/settings_screen.dart';

class AdultHomeScreen extends StatefulWidget {
  final int currentUserId;

  const AdultHomeScreen({super.key, required this.currentUserId});

  @override
  State<AdultHomeScreen> createState() => _AdultHomeScreenState();
}

class _AdultHomeScreenState extends State<AdultHomeScreen> {
  final Color _primaryColor = const Color(0xFF4A90A4);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = Colors.white;
  final Color _textColor = const Color(0xFF2C3E50);
  final Color _hintColor = const Color(0xFF7F8C8D);

  List<Medicine> _medicines = [];
  List<Medicine> _filteredMedicines = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;
  String _searchQuery = '';

  int get _currentUserId => widget.currentUserId;

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
        UserSession().setUser(_currentUserId, _currentUser!);
      }
      setState(() {});
    } catch (e) {
      print('❌ Error loading current user: $e');
    }
  }

  Future<void> _loadMedicines() async {
    try {
      final medicines = await DatabaseHelper().getActiveMedicinesByUserId(
        _currentUserId,
      );
      setState(() {
        _medicines = medicines;
        _filteredMedicines = medicines;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading medicines: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterMedicines(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMedicines = _medicines;
      } else {
        _filteredMedicines = _medicines
            .where(
              (medicine) =>
                  medicine.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<void> _markAsTaken(Medicine medicine) async {
    try {
      await DatabaseHelper().markMedicineAsTaken(medicine.id!);

      // تحديث القائمة محلياً بدون إعادة تحميل كامل
      setState(() {
        medicine.isTaken = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Marked ${medicine.name} as taken'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // إعادة تحميل البيانات للحصول على التحديثات الكاملة
      _loadMedicines();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Error marking medicine as taken'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _navigateToAddMedicine() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicineScreen(userId: _currentUserId),
      ),
    );

    if (result == true) {
      await _loadMedicines();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Medication added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📚 History feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToReports() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📊 Reports feature coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    ).then((_) {
      _loadCurrentUser();
    });
  }

  void _navigateToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }

  Future<void> _showSearchDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Medications',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter medication name...',
            prefixIcon: Icon(Icons.search, color: _primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onChanged: _filterMedicines,
        ),
        actions: [
          TextButton(
            onPressed: () {
              _filterMedicines('');
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await DatabaseHelper().logoutUser(_currentUserId);
                UserSession().clear();

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              } catch (e) {
                print('❌ Error during logout: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ Error during logout'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Medications',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (_currentUser != null)
              Text(
                'Hello, ${_currentUser!['name']}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 22.sp),
            onPressed: _showSearchDialog,
            color: Colors.white,
            tooltip: 'Search medications',
          ),
          IconButton(
            icon: Icon(Icons.person, size: 22.sp),
            onPressed: _navigateToProfile,
            color: Colors.white,
            tooltip: 'Profile',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 22.sp),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  _navigateToSettings();
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : RefreshIndicator(
              onRefresh: _loadMedicines,
              color: _primaryColor,
              child: _buildBody(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMedicine,
        backgroundColor: _primaryColor,
        tooltip: 'Add Medication',
        child: Icon(Icons.add, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          SizedBox(height: 16.h),
          Text(
            'Loading your medications...',
            style: TextStyle(fontSize: 16.sp, color: _hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            SizedBox(height: 20.h),
            if (_searchQuery.isNotEmpty) _buildSearchHeader(),
            _buildTodaysMedications(),
            SizedBox(height: 20.h),
            _buildQuickActions(),
            SizedBox(height: 20.h),
            _buildSyncStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final userName = _currentUser?['name'] ?? 'User';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, const Color(0xFF81C7D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, $userName! 👋',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _filteredMedicines.isEmpty
                ? 'No medications scheduled for today'
                : 'You have ${_filteredMedicines.length} medications scheduled',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          SizedBox(height: 12.h),
          if (_filteredMedicines.isNotEmpty)
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildStatChip('${_getTakenCount()} taken', Icons.check_circle),
                _buildStatChip('${_getDueCount()} due', Icons.access_time),
                if (_searchQuery.isNotEmpty)
                  _buildStatChip(
                    '${_filteredMedicines.length} results',
                    Icons.search,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18.sp, color: Colors.blue.shade600),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Search results for "$_searchQuery"',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _filterMedicines(''),
            child: Icon(Icons.close, size: 18.sp, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysMedications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _searchQuery.isEmpty ? 'Today\'s Schedule' : 'Search Results',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: _textColor,
              ),
            ),
            if (_filteredMedicines.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_getTakenCount()}/${_filteredMedicines.length} Taken',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        _filteredMedicines.isEmpty ? _buildEmptyState() : _buildMedicinesList(),
      ],
    );
  }

  Widget _buildMedicinesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredMedicines.length,
      itemBuilder: (context, index) {
        return _medicationItem(_filteredMedicines[index]);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 60.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            _searchQuery.isEmpty ? 'No Medications' : 'No Results Found',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _searchQuery.isEmpty
                ? 'Add your first medication to get started'
                : 'No medications found for "$_searchQuery"',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: _searchQuery.isEmpty
                ? _navigateToAddMedicine
                : () => _filterMedicines(''),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            ),
            child: Text(
              _searchQuery.isEmpty ? 'Add First Medication' : 'Clear Search',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _medicationItem(Medicine medicine) {
    final nextReminder = _getNextReminder(medicine);
    final status = _getMedicationStatus(medicine);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(status),
            color: _getStatusColor(status),
            size: 20.sp,
          ),
        ),
        title: Text(
          medicine.name,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4.h),
            Text(
              '${medicine.dosage} • ${medicine.timesPerDay}x daily',
              style: TextStyle(fontSize: 13.sp, color: _hintColor),
            ),
            if (nextReminder != null) ...[
              SizedBox(height: 2.h),
              Text(
                'Next: $nextReminder',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        trailing: (status == 'upcoming' || status == 'due')
            ? ElevatedButton(
                onPressed: () => _markAsTaken(medicine),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                ),
                child: Text(
                  'Take',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(status),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _quickActionButton(
              icon: Icons.history,
              label: 'History',
              onTap: _navigateToHistory,
            ),
            SizedBox(width: 12.w),
            _quickActionButton(
              icon: Icons.bar_chart,
              label: 'Reports',
              onTap: _navigateToReports,
            ),
            SizedBox(width: 12.w),
            _quickActionButton(
              icon: Icons.settings,
              label: 'Settings',
              onTap: _navigateToSettings,
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: _primaryColor, size: 20.sp),
              SizedBox(height: 6.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: _textColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    return FutureBuilder<Map<String, dynamic>>(
      future: DatabaseHelper().getSyncStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        final stats = snapshot.data!;
        final syncPercentage = stats['syncPercentage'] ?? 0;

        if (syncPercentage == 100) return const SizedBox();

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.sync, size: 16.sp, color: Colors.orange.shade600),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  '${stats['unsyncedUsers']} users pending sync',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              Text(
                '$syncPercentage%',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  int _getTakenCount() {
    return _filteredMedicines.where((medicine) => medicine.isTaken).length;
  }

  int _getDueCount() {
    return _filteredMedicines
        .where((medicine) => _getMedicationStatus(medicine) == 'due')
        .length;
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

  String _getMedicationStatus(Medicine medicine) {
    if (medicine.isTaken) {
      return 'taken';
    }

    final nextReminder = _getNextReminder(medicine);
    if (nextReminder != null) {
      try {
        final timeParts = nextReminder.split(':');
        final hour = int.tryParse(timeParts[0]);
        final minute = int.tryParse(timeParts[1]);

        if (hour != null && minute != null) {
          final now = DateTime.now();
          final reminderTime = TimeOfDay(hour: hour, minute: minute);
          final nowTime = TimeOfDay.fromDateTime(now);

          final timeDiff =
              (reminderTime.hour * 60 + reminderTime.minute) -
              (nowTime.hour * 60 + nowTime.minute);

          if (timeDiff <= 0) {
            return 'due';
          } else if (timeDiff <= 30) {
            return 'upcoming';
          }
        }
      } catch (e) {
        return 'scheduled';
      }
    }

    return 'scheduled';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'taken':
        return Colors.green;
      case 'due':
        return Colors.orange;
      case 'upcoming':
        return Colors.blue;
      case 'scheduled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'taken':
        return Icons.check_circle;
      case 'due':
        return Icons.warning;
      case 'upcoming':
        return Icons.access_time;
      case 'scheduled':
        return Icons.schedule;
      default:
        return Icons.medical_services;
    }
  }
}
