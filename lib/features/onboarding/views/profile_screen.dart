// features/profile/views/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color _primaryColor = const Color(0xFF4A90A4);
  final Color _accentColor = const Color(0xFF6AC2B0);

  // بيانات المستخدم الافتراضية
  Map<String, dynamic> _userData = {
    'name': 'Ahmed Mohamed',
    'email': 'ahmed.monitor@remedi.com',
    'phone': '+201234567890',
    'role': 'Caregiver',
    'joinDate': '2024-01-15',
    'dependentsCount': 3,
    'totalManagedMeds': 12,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, size: 22.sp),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),
            SizedBox(height: 24.h),

            // Statistics Cards
            _buildStatisticsSection(),
            SizedBox(height: 24.h),

            // Personal Information
            _buildPersonalInfoSection(),
            SizedBox(height: 24.h),

            // Account Settings
            _buildAccountSection(),
            SizedBox(height: 24.h),

            // Actions
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryColor, _accentColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3.w),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(Icons.person, size: 40.sp, color: Colors.white),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData['name'],
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _userData['email'],
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _userData['role'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.group,
            value: _userData['dependentsCount'].toString(),
            label: 'Dependents',
            color: Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.medical_services,
            value: _userData['totalManagedMeds'].toString(),
            label: 'Medications',
            color: Colors.green,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today,
            value: '6',
            label: 'Months',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(Icons.person, 'Full Name', _userData['name']),
          _buildInfoRow(Icons.email, 'Email Address', _userData['email']),
          _buildInfoRow(Icons.phone, 'Phone Number', _userData['phone']),
          _buildInfoRow(
            Icons.calendar_today,
            'Member Since',
            _userData['joinDate'],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18.sp, color: _primaryColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Account Settings',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSettingItem(
            Icons.notifications,
            'Push Notifications',
            'Manage your alerts',
            Icons.toggle_on,
            true,
            onTap: () {},
          ),
          _buildSettingItem(
            Icons.language,
            'Language',
            'English',
            Icons.chevron_right,
            null,
            onTap: () {},
          ),
          _buildSettingItem(
            Icons.security,
            'Privacy & Security',
            'Manage your data',
            Icons.chevron_right,
            null,
            onTap: () {},
          ),
          _buildSettingItem(
            Icons.help,
            'Help & Support',
            'Get help and contact support',
            Icons.chevron_right,
            null,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle,
    IconData trailingIcon,
    bool? isActive, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: _primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.sp, color: _primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
      ),
      trailing: isActive != null
          ? Icon(
              isActive ? Icons.toggle_on : Icons.toggle_off,
              size: 30.sp,
              color: isActive ? _primaryColor : Colors.grey,
            )
          : Icon(trailingIcon, size: 20.sp, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            icon: Icon(Icons.lock, size: 18.sp),
            label: Text(
              'Change Password',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
            ),
            icon: Icon(Icons.logout, size: 18.sp),
            label: Text(
              'Log Out',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Text('Profile editing feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    // TODO: Implement change password
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password change feature coming soon!'),
        backgroundColor: _primaryColor,
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log Out'),
        content: Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
