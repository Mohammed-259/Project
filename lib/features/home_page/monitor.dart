// features/monitor/views/monitor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/models/sqlite.dart';
import '/models/medicine_model.dart';
import '/models/user_session.dart';
import '/features/onboarding/views/add_medicine.dart';
import '/features/onboarding/views/add_dependent_screen.dart';
import '/features/onboarding/views/reports_screen.dart';
import '/features/onboarding/views/profile_screen.dart';
import '/features/onboarding/views/settings_screen.dart';

class MonitorHomeScreen extends StatefulWidget {
  final int currentUserId;

  const MonitorHomeScreen({super.key, required this.currentUserId});

  @override
  State<MonitorHomeScreen> createState() => _MonitorHomeScreenState();
}

class _MonitorHomeScreenState extends State<MonitorHomeScreen> {
  final Color _primaryColor = const Color(0xFF4A90A4);
  final Color _accentColor = const Color(0xFF6AC2B0);
  String _selectedDependent = '';
  List<Medicine> _medicines = [];
  bool _isLoading = true;
  int _currentTab = 0;

  int get _currentMonitorId => widget.currentUserId;

  List<Map<String, dynamic>> _dependents = [];
  final Map<String, int> _dependentUserIds = {};
  List<Medicine> _myMedicines = [];
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _initializeUserSession();
    _loadData();
  }

  void _initializeUserSession() {
    UserSession().setUser(_currentMonitorId, _currentUser ?? {});
  }

  Future<void> _loadData() async {
    await _loadCurrentUser();
    await _loadDependents();
    await _loadMyMedicines();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await DatabaseHelper().getUserById(_currentMonitorId);
      if (_currentUser != null) {
        UserSession().setUser(_currentMonitorId, _currentUser!);
      }
      setState(() {});
    } catch (e) {
      print('Error loading current user: $e');
    }
  }

  Future<void> _loadDependents() async {
    try {
      _dependents = await DatabaseHelper().getDependentsByMonitorId(
        _currentMonitorId,
      );

      _dependentUserIds.clear();
      for (final dependent in _dependents) {
        _dependentUserIds[dependent['name']] = dependent['id'];
      }

      if (_dependents.isNotEmpty) {
        _selectedDependent = _dependents.first['name'];
        _loadMedicines();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading dependents: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMedicines() async {
    try {
      if (_selectedDependent.isEmpty) return;

      final int? dependentUserId = _dependentUserIds[_selectedDependent];

      if (dependentUserId == null) {
        setState(() {
          _medicines = [];
          _isLoading = false;
        });
        return;
      }

      final medicines = await DatabaseHelper().getMedicinesByUserId(
        dependentUserId,
      );

      setState(() {
        _medicines = medicines.where((medicine) => medicine.isActive).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading medicines: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMyMedicines() async {
    try {
      final medicines = await DatabaseHelper().getActiveMedicinesByUserId(
        _currentMonitorId,
      );
      setState(() {
        _myMedicines = medicines;
      });
    } catch (e) {
      print('Error loading my medicines: $e');
    }
  }

  Future<void> _markAsTaken(
    Medicine medicine, {
    bool isMyMedicine = false,
  }) async {
    try {
      await DatabaseHelper().markMedicineAsTaken(medicine.id!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMyMedicine
                ? 'Marked ${medicine.name} as taken for yourself'
                : 'Marked ${medicine.name} as taken for $_selectedDependent',
          ),
          backgroundColor: Colors.green,
        ),
      );

      if (isMyMedicine) {
        _loadMyMedicines();
      } else {
        _loadMedicines();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error marking medicine as taken'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _navigateToAddDependent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddDependentScreen(monitorId: _currentMonitorId),
      ),
    );

    if (result == true) {
      _loadDependents();
    }
  }

  Future<void> _navigateToAddMedicine({bool forMyself = false}) async {
    int? userId;

    if (forMyself) {
      userId = _currentMonitorId;
    } else {
      if (_selectedDependent.isEmpty) return;
      userId = _dependentUserIds[_selectedDependent];
      if (userId == null) return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicineScreen(userId: userId!),
      ),
    );

    if (result == true) {
      if (forMyself) {
        _loadMyMedicines();
      } else {
        _loadMedicines();
      }
    }
  }

  void _editMedicine(Medicine medicine, {bool isMyMedicine = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit medicine: ${medicine.name}'),
        backgroundColor: _primaryColor,
      ),
    );
  }

  Future<void> _deleteMedicine(
    Medicine medicine, {
    bool isMyMedicine = false,
  }) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper().deleteMedicine(medicine.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medicine deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        if (isMyMedicine) {
          _loadMyMedicines();
        } else {
          _loadMedicines();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error deleting medicine'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToReports() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportsScreen(
          dependents: _dependents,
          monitorId: _currentMonitorId,
        ),
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

  Future<void> _logout() async {
    try {
      await DatabaseHelper().logoutUser(_currentMonitorId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(child: _buildCurrentTab()),
        ],
      ),
      floatingActionButton: _currentTab == 1
          ? _buildFloatingActionButton()
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monitor Dashboard',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Manage your dependents & medications',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.person, size: 24.sp),
                      onPressed: _navigateToProfile,
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: Icon(Icons.settings, size: 24.sp),
                      onPressed: _navigateToSettings,
                      color: Colors.white,
                    ),
                    IconButton(
                      icon: Icon(Icons.logout, size: 24.sp),
                      onPressed: _logout,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.group,
          value: _dependents.length.toString(),
          label: 'Dependents',
        ),
        _buildStatItem(
          icon: Icons.medical_services,
          value: '${_medicines.length + _myMedicines.length}',
          label: 'Total Meds',
        ),
        _buildStatItem(
          icon: Icons.check_circle,
          value: '${_getTotalTakenCount()}',
          label: 'Taken Today',
        ),
        _buildStatItem(
          icon: Icons.notifications,
          value: '${_getDueMedicationsCount()}',
          label: 'Due Now',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: Colors.white),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTab(0, Icons.group, 'Dependents'),
          _buildTab(1, Icons.medical_services, 'Medications'),
          _buildTab(2, Icons.bar_chart, 'Reports'),
        ],
      ),
    );
  }

  Widget _buildTab(int tabIndex, IconData icon, String label) {
    final isSelected = _currentTab == tabIndex;
    return Expanded(
      child: Material(
        color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _currentTab = tabIndex),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: isSelected ? _primaryColor : Colors.grey,
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? _primaryColor : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTab() {
    switch (_currentTab) {
      case 0:
        return _buildDependentsTab();
      case 1:
        return _buildMedicationsTab();
      case 2:
        return _buildReportsTab();
      default:
        return _buildDependentsTab();
    }
  }

  Widget _buildDependentsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Dependents',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _navigateToAddDependent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                icon: Icon(Icons.person_add, size: 16.sp),
                label: const Text('Add Dependent'),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _dependents.isEmpty
              ? _buildEmptyDependentsState()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: _dependents.length,
                  itemBuilder: (context, index) {
                    return _buildDependentCard(_dependents[index]);
                  },
                ),
          SizedBox(height: 20.h),
          _buildMyMedicinesSection(),
        ],
      ),
    );
  }

  Widget _buildDependentCard(Map<String, dynamic> dependent) {
    final role = dependent['role'] ?? 'child';
    final relationship = dependent['relationship'] ?? 'Dependent';
    final dependentUserId = _dependentUserIds[dependent['name']];
    final medicineCount = dependentUserId != null ? _medicines.length : 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    role == 'child' ? Icons.child_care : Icons.elderly,
                    color: _primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dependent['name'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        relationship,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.medical_services, size: 14.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  '$medicineCount medications',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDependent = dependent['name'];
                          _currentTab = 1;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                      ),
                      child: Text(
                        'View Meds',
                        style: TextStyle(fontSize: 10.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(Icons.more_vert, size: 16.sp),
                    onPressed: () {
                      _showDependentOptions(dependent);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyMedicinesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Personal Medications',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12.h),
        _myMedicines.isEmpty
            ? _buildEmptyMyMedicinesState()
            : Column(
                children: _myMedicines.take(3).map((medicine) {
                  return _buildMedicineItem(medicine, isMyMedicine: true);
                }).toList(),
              ),
        if (_myMedicines.length > 3)
          TextButton(
            onPressed: () {
              setState(() => _currentTab = 1);
            },
            child: const Text('View All My Medications'),
          ),
      ],
    );
  }

  Widget _buildMedicationsTab() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedDependent.isEmpty
                      ? 'My Medications'
                      : '$_selectedDependent\'s Medications',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (_dependents.isNotEmpty)
                DropdownButton<String>(
                  value: _selectedDependent.isEmpty
                      ? 'My Medications'
                      : _selectedDependent,
                  items: [
                    const DropdownMenuItem<String>(
                      value: 'My Medications',
                      child: Text('My Medications'),
                    ),
                    ..._dependents.map((dependent) {
                      return DropdownMenuItem<String>(
                        value: dependent['name'] as String,
                        child: Text(dependent['name'] as String),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      if (value == 'My Medications') {
                        _selectedDependent = '';
                      } else {
                        _selectedDependent = value!;
                        _loadMedicines();
                      }
                    });
                  },
                ),
            ],
          ),
        ),
        Expanded(
          child: _selectedDependent.isEmpty
              ? _buildMyMedicinesList()
              : _buildDependentMedicinesList(),
        ),
      ],
    );
  }

  Widget _buildMyMedicinesList() {
    return _myMedicines.isEmpty
        ? _buildEmptyMyMedicinesState()
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _myMedicines.length,
            itemBuilder: (context, index) {
              return _buildMedicineItem(
                _myMedicines[index],
                isMyMedicine: true,
              );
            },
          );
  }

  Widget _buildDependentMedicinesList() {
    return _medicines.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _medicines.length,
            itemBuilder: (context, index) {
              return _buildMedicineItem(_medicines[index], isMyMedicine: false);
            },
          );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reports & Analytics',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          _buildReportCard(
            title: 'Medication Adherence',
            subtitle: 'View compliance reports',
            icon: Icons.analytics,
            onTap: _navigateToReports,
          ),
          SizedBox(height: 12.h),
          _buildReportCard(
            title: 'Dependent Summary',
            subtitle: 'Individual performance',
            icon: Icons.summarize,
            onTap: () {},
          ),
          SizedBox(height: 12.h),
          _buildReportCard(
            title: 'Health Trends',
            subtitle: 'Long-term analytics',
            icon: Icons.trending_up,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: _primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.sp),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMedicineItem(Medicine medicine, {required bool isMyMedicine}) {
    final isTaken = medicine.isTaken;
    final nextReminder = _getNextReminder(medicine);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: isTaken
                        ? Colors.green.withOpacity(0.15)
                        : _primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isTaken ? Icons.check_circle : Icons.medical_services,
                    color: isTaken ? Colors.green : _primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${medicine.dosage} • ${medicine.timesPerDay}x daily',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 18.sp),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editMedicine(medicine, isMyMedicine: isMyMedicine);
                    } else if (value == 'delete') {
                      _deleteMedicine(medicine, isMyMedicine: isMyMedicine);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (nextReminder != null) ...[
              Row(
                children: [
                  Icon(Icons.access_time, size: 14.sp, color: Colors.blue),
                  SizedBox(width: 4.w),
                  Text(
                    'Next: $nextReminder',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _markAsTaken(medicine, isMyMedicine: isMyMedicine),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTaken ? Colors.grey : _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      isTaken ? 'Already Taken' : 'Mark as Taken',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () =>
          _navigateToAddMedicine(forMyself: _selectedDependent.isEmpty),
      backgroundColor: _primaryColor,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // Helper Methods
  Widget _buildEmptyDependentsState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_add, size: 80.sp, color: Colors.grey.shade400),
          SizedBox(height: 20.h),
          Text(
            'No Dependents Added',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first dependent to start managing their medications',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: _navigateToAddDependent,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: const Text('Add First Dependent'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMyMedicinesState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 20.h),
          Text(
            'No Personal Medications',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add medications for yourself to get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => _navigateToAddMedicine(forMyself: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: const Text('Add My First Medication'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_liquid,
            size: 80.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 20.h),
          Text(
            'No Medications Added',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _selectedDependent.isEmpty
                ? 'Add medications for yourself to get started'
                : 'Add medications for $_selectedDependent to get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () =>
                _navigateToAddMedicine(forMyself: _selectedDependent.isEmpty),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: const Text('Add First Medication'),
          ),
        ],
      ),
    );
  }

  void _showDependentOptions(Map<String, dynamic> dependent) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: _primaryColor),
                title: const Text('Edit Dependent'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement edit dependent functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Edit ${dependent['name']}'),
                      backgroundColor: _primaryColor,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.medical_services, color: _primaryColor),
                title: const Text('Manage Medications'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedDependent = dependent['name'];
                    _currentTab = 1;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.bar_chart, color: _primaryColor),
                title: const Text('View Reports'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToReports();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Remove Dependent',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDependentDialog(dependent);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDependentDialog(Map<String, dynamic> dependent) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Dependent'),
        content: Text(
          'Are you sure you want to remove ${dependent['name']}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseHelper().deleteDependent(dependent['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dependent removed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadDependents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error removing dependent'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? _getNextReminder(Medicine medicine) {
    try {
      final now = DateTime.now();
      final times = medicine.reminderTimes;

      if (times != null && times.isNotEmpty) {
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
              print('Error parsing time: $time, error: $e');
              continue;
            }
          }
        }

        try {
          final firstTime = times.first;
          final timeParts = firstTime.split(':');
          if (timeParts.length == 2) {
            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);

            if (hour != null && minute != null) {
              return 'Tomorrow ${hour}:${minute.toString().padLeft(2, '0')}';
            }
          }
        } catch (e) {
          print('Error parsing first time: ${times.first}, error: $e');
        }
      }
      return null;
    } catch (e) {
      print('Error in _getNextReminder: $e');
      return null;
    }
  }

  int _getTotalTakenCount() {
    int count = 0;
    for (final medicine in _medicines) {
      if (medicine.isTaken) count++;
    }
    for (final medicine in _myMedicines) {
      if (medicine.isTaken) count++;
    }
    return count;
  }

  int _getDueMedicationsCount() {
    final now = DateTime.now();
    int count = 0;

    for (final medicine in _medicines) {
      if (!medicine.isTaken && _isMedicineDue(medicine, now)) {
        count++;
      }
    }

    for (final medicine in _myMedicines) {
      if (!medicine.isTaken && _isMedicineDue(medicine, now)) {
        count++;
      }
    }

    return count;
  }

  bool _isMedicineDue(Medicine medicine, DateTime now) {
    final times = medicine.reminderTimes;
    if (times != null && times.isNotEmpty) {
      for (final time in times) {
        try {
          final timeParts = time.split(':');
          if (timeParts.length == 2) {
            final hour = int.tryParse(timeParts[0]);
            final minute = int.tryParse(timeParts[1]);

            if (hour != null && minute != null) {
              final reminderTime = TimeOfDay(hour: hour, minute: minute);
              final nowTime = TimeOfDay.fromDateTime(now);
              final timeDiff =
                  (reminderTime.hour * 60 + reminderTime.minute) -
                  (nowTime.hour * 60 + nowTime.minute);
              if (timeDiff >= 0 && timeDiff <= 30) {
                return true;
              }
            }
          }
        } catch (e) {
          continue;
        }
      }
    }
    return false;
  }
}
