// إنشاء ملف lib/debug/database_debug_screen.dart
import 'package:flutter/material.dart';
import '../models/sqlite.dart';

class DatabaseDebugScreen extends StatefulWidget {
  const DatabaseDebugScreen({super.key});

  @override
  State<DatabaseDebugScreen> createState() => _DatabaseDebugScreenState();
}

class _DatabaseDebugScreenState extends State<DatabaseDebugScreen> {
  List<Map<String, dynamic>> _users = [];
  final List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final dbHelper = DatabaseHelper();
      _users = await dbHelper.getAllUsers();
      // للحصول على الأدوية، تحتاج لدالة getAllMedicines في DatabaseHelper
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Debug'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Users (${_users.length})',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ..._users.map(
                    (user) => Card(
                      child: ListTile(
                        title: Text(user['name'] ?? 'No Name'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${user['email']}'),
                            Text('Role: ${user['role']}'),
                            Text('ID: ${user['id']}'),
                            Text(
                              'Synced: ${user['isSynced'] == 1 ? 'Yes' : 'No'}',
                            ),
                            Text(
                              'Firebase UID: ${user['firebaseUid'] ?? 'None'}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
