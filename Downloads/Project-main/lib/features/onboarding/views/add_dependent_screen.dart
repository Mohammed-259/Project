// ملف add_dependent_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '/models/sqlite.dart';

class AddDependentScreen extends StatefulWidget {
  final int monitorId;

  const AddDependentScreen({super.key, required this.monitorId});

  @override
  State<AddDependentScreen> createState() => _AddDependentScreenState();
}

class _AddDependentScreenState extends State<AddDependentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();

  String _selectedRole = 'child';
  String _selectedRelationship = 'Son';
  final Color _primaryColor = const Color(0xFF4A90A4);

  final List<String> _relationships = [
    'Son',
    'Daughter',
    'Father',
    'Mother',
    'Grandfather',
    'Grandmother',
    'Husband',
    'Wife',
    'Brother',
    'Sister',
    'Uncle',
    'Aunt',
    'Cousin',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Dependent', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter dependent name',
                icon: Icons.person_outline,
              ),
              SizedBox(height: 16.h),

              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16.h),

              _buildRoleSelection(),
              SizedBox(height: 16.h),

              _buildRelationshipSelection(),
              SizedBox(height: 16.h),

              _buildBirthDateField(),
              SizedBox(height: 30.h),

              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: _primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            if (label == 'Email' && !value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: RadioListTile(
                  title: Text('Child', style: TextStyle(fontSize: 14.sp)),
                  value: 'child',
                  groupValue: _selectedRole,
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
              ),
              Expanded(
                child: RadioListTile(
                  title: Text('Elderly', style: TextStyle(fontSize: 14.sp)),
                  value: 'elderly',
                  groupValue: _selectedRole,
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelationshipSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relationship',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedRelationship,
          items: _relationships.map((relationship) {
            return DropdownMenuItem(
              value: relationship,
              child: Text(relationship),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRelationship = value!;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            hintText: 'Select relationship',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select relationship';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBirthDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Date',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _birthDateController,
          readOnly: true,
          onTap: () => _selectBirthDate(context),
          decoration: InputDecoration(
            hintText: 'Select birth date',
            prefixIcon: Icon(Icons.calendar_today, color: _primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select birth date';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _saveDependent,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Save Dependent',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _saveDependent() async {
    if (_formKey.currentState!.validate()) {
      try {
        final dependentData = {
          'name': _nameController.text,
          'email': _emailController.text,
          'role': _selectedRole,
          'birthDate': _birthDateController.text,
          'monitorId': widget.monitorId,
          'relationship': _selectedRelationship,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        await DatabaseHelper().addDependent(dependentData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dependent added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add dependent: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }
}
