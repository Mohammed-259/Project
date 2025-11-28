import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/models/sqlite.dart';
import '/models/user_session.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Color _primaryColor = const Color(0xFF4A90A4);
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _medicationReminders = true;
  bool _refillReminders = false;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System Default';

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _monitorUser;
  bool _isLoading = true;

  final List<String> _languages = ['English', 'Arabic', 'French', 'Spanish'];
  final List<String> _themes = ['System Default', 'Light', 'Dark'];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final session = UserSession();

      if (session.isLoggedIn && session.currentUserId != null) {
        // تحميل بيانات المستخدم الحالي
        _currentUser = await _dbHelper.getUserById(session.currentUserId!);

        // إذا كان المستخدم مرتبط بمراقب، تحميل بيانات المراقب
        if (_currentUser != null && _currentUser!['monitorId'] != null) {
          final monitorId = _currentUser!['monitorId'] as int;
          _monitorUser = await _dbHelper.getUserById(monitorId);
        }

        print('''
🔧 SETTINGS SCREEN USER DATA:
   - User ID: ${_currentUser?['id']}
   - Firebase UID: ${_currentUser?['firebaseUid']}
   - Role: ${_currentUser?['role']}
   - Monitor ID: ${_currentUser?['monitorId']}
''');
      }
    } catch (e) {
      print('❌ Error loading user data in settings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getUserRoleDisplay(String role) {
    switch (role.toLowerCase()) {
      case 'adult':
        return 'Adult User';
      case 'monitor':
        return 'Caregiver';
      case 'child':
        return 'Child';
      case 'elderly':
        return 'Elderly';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Settings',
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
      ),
      body: _isLoading
          ? _buildLoadingIndicator()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // User Profile Section
                  _buildUserProfileSection(),
                  SizedBox(height: 20.h),

                  // Monitor Information (if applicable)
                  if (_currentUser != null &&
                      (_currentUser!['role'] == 'child' ||
                          _currentUser!['role'] == 'elderly') &&
                      _monitorUser != null)
                    _buildMonitorSection(),

                  if (_currentUser != null &&
                      (_currentUser!['role'] == 'child' ||
                          _currentUser!['role'] == 'elderly') &&
                      _monitorUser == null)
                    _buildNoMonitorSection(),

                  // Account Information
                  _buildAccountInfoSection(),
                  SizedBox(height: 20.h),

                  // Notifications Section
                  _buildSection(
                    title: 'Notifications',
                    icon: Icons.notifications,
                    children: [
                      _buildSettingSwitch(
                        'Push Notifications',
                        'Receive push notifications',
                        _pushNotifications,
                        (value) => setState(() => _pushNotifications = value),
                      ),
                      _buildSettingSwitch(
                        'Email Notifications',
                        'Receive email updates',
                        _emailNotifications,
                        (value) => setState(() => _emailNotifications = value),
                      ),
                      _buildSettingSwitch(
                        'Medication Reminders',
                        'Remind about medications',
                        _medicationReminders,
                        (value) => setState(() => _medicationReminders = value),
                      ),
                      _buildSettingSwitch(
                        'Refill Reminders',
                        'Alert when meds are low',
                        _refillReminders,
                        (value) => setState(() => _refillReminders = value),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Alert Preferences
                  _buildSection(
                    title: 'Alert Preferences',
                    icon: Icons.alarm,
                    children: [
                      _buildSettingSwitch(
                        'Sound',
                        'Play sound for alerts',
                        _soundEnabled,
                        (value) => setState(() => _soundEnabled = value),
                      ),
                      _buildSettingSwitch(
                        'Vibration',
                        'Vibrate for alerts',
                        _vibrationEnabled,
                        (value) => setState(() => _vibrationEnabled = value),
                      ),
                      _buildSettingDropdown(
                        'Alert Tone',
                        'Default Tone',
                        Icons.music_note,
                        onTap: () {},
                      ),
                      _buildSettingDropdown(
                        'Reminder Interval',
                        '15 minutes before',
                        Icons.access_time,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Appearance
                  _buildSection(
                    title: 'Appearance',
                    icon: Icons.palette,
                    children: [
                      _buildSettingDropdown(
                        'Language',
                        _selectedLanguage,
                        Icons.language,
                        onTap: _showLanguageDialog,
                      ),
                      _buildSettingDropdown(
                        'Theme',
                        _selectedTheme,
                        Icons.brightness_6,
                        onTap: _showThemeDialog,
                      ),
                      _buildSettingItem(
                        'Font Size',
                        'Medium',
                        Icons.format_size,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Privacy & Security
                  _buildSection(
                    title: 'Privacy & Security',
                    icon: Icons.security,
                    children: [
                      _buildSettingItem(
                        'Privacy Policy',
                        'View our privacy policy',
                        Icons.privacy_tip,
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        'Terms of Service',
                        'View terms and conditions',
                        Icons.description,
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        'Data Export',
                        'Export your data',
                        Icons.backup,
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        'Clear Cache',
                        'Free up storage space',
                        Icons.delete_sweep,
                        onTap: _clearCache,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Support
                  _buildSection(
                    title: 'Support',
                    icon: Icons.help,
                    children: [
                      _buildSettingItem(
                        'Help Center',
                        'Get help and tutorials',
                        Icons.help_center,
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        'Contact Support',
                        'Reach out to our team',
                        Icons.support_agent,
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        'About App',
                        'Version 1.0.0',
                        Icons.info,
                        onTap: _showAboutDialog,
                      ),
                      _buildSettingItem(
                        'Rate App',
                        'Share your feedback',
                        Icons.star,
                        onTap: () {},
                      ),
                    ],
                  ),
                  SizedBox(height: 30.h),

                  // Reset & Danger Zone
                  _buildDangerZone(),
                ],
              ),
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
            'Loading your settings...',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection() {
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 20.sp, color: _primaryColor),
              ),
              SizedBox(width: 12.w),
              Text(
                'User Profile',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (_currentUser != null) ...[
            _buildProfileInfoRow('User ID', _currentUser!['id'].toString()),
            _buildProfileInfoRow('Name', _currentUser!['name'] ?? 'Not set'),
            _buildProfileInfoRow('Email', _currentUser!['email'] ?? 'Not set'),
            _buildProfileInfoRow(
              'Role',
              _getUserRoleDisplay(_currentUser!['role'] ?? 'Unknown'),
            ),
            _buildProfileInfoRow(
              'Birth Date',
              _currentUser!['birthDate'] ?? 'Not set',
            ),
          ] else ...[
            Center(
              child: Text(
                'User data not available',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.info, size: 20.sp, color: Colors.green),
              ),
              SizedBox(width: 12.w),
              Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          if (_currentUser != null) ...[
            _buildProfileInfoRow(
              'Firebase UID',
              _currentUser!['firebaseUid'] ?? 'Not linked',
            ),
            _buildProfileInfoRow(
              'Account Status',
              _currentUser!['isSynced'] == 1
                  ? '✅ Synced with Cloud'
                  : '📱 Local Only',
            ),
            _buildProfileInfoRow(
              'Created',
              _formatDate(_currentUser!['createdAt']),
            ),
            _buildProfileInfoRow(
              'Last Updated',
              _formatDate(_currentUser!['updatedAt']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMonitorSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.supervisor_account,
                  size: 20.sp,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Caregiver Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          _buildProfileInfoRow(
            'Monitor ID',
            _currentUser!['monitorId'].toString(),
          ),
          _buildProfileInfoRow(
            'Caregiver Name',
            _monitorUser!['name'] ?? 'Unknown',
          ),
          _buildProfileInfoRow(
            'Caregiver Email',
            _monitorUser!['email'] ?? 'Unknown',
          ),
          _buildProfileInfoRow(
            'Relationship',
            _currentUser!['relationship'] ?? 'Not set',
          ),

          SizedBox(height: 12.h),
          Text(
            'Your caregiver manages your medication schedule and receives notifications about your medication intake.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.blue.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMonitorSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, size: 20.sp, color: Colors.orange),
              SizedBox(width: 8.w),
              Text(
                'No Caregiver Assigned',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'You are registered as ${_getUserRoleDisplay(_currentUser!['role'])} '
            'but no caregiver is currently assigned to your account.',
            style: TextStyle(fontSize: 12.sp, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildProfileInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20.sp, color: _primaryColor),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
<<<<<<< HEAD
            activeThumbColor: _primaryColor,
=======
            activeColor: _primaryColor,
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
          ),
        ],
      ),
    );
  }

  Widget _buildSettingDropdown(
    String title,
    String value,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return _buildSettingItem(title, value, icon, onTap: onTap);
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 22.sp, color: _primaryColor),
      title: Text(
        title,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
      ),
      trailing: Icon(Icons.chevron_right, size: 20.sp, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildDangerZone() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Danger Zone',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'These actions are irreversible. Proceed with caution.',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetSettings,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: Icon(Icons.restore, size: 18.sp),
              label: const Text('Reset All Settings'),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _deleteAccount,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: Icon(Icons.delete_forever, size: 18.sp),
              label: const Text('Delete Account'),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final language = _languages[index];
              return RadioListTile(
                title: Text(language),
                value: language,
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() => _selectedLanguage = value!);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to $value'),
                      backgroundColor: _primaryColor,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _themes.length,
            itemBuilder: (context, index) {
              final theme = _themes[index];
              return RadioListTile(
                title: Text(theme),
                value: theme,
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() => _selectedTheme = value!);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Theme changed to $value'),
                      backgroundColor: _primaryColor,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will free up storage space. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Remedi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Remedi - Medication Manager',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            const Text('Version: 1.0.0'),
            const Text('Build: 2024.01.001'),
            SizedBox(height: 12.h),
            const Text(
              'A comprehensive medication management app for caregivers and patients.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
          'This will reset all your settings to default. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _pushNotifications = true;
                _emailNotifications = false;
                _soundEnabled = true;
                _vibrationEnabled = true;
                _medicationReminders = true;
                _refillReminders = false;
                _selectedLanguage = 'English';
                _selectedTheme = 'System Default';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All settings have been reset'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
