import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '/models/medicine_model.dart';
import '/models/sqlite.dart';
import '/core/services/image_service.dart';

class AddMedicineScreen extends StatefulWidget {
  final int userId;

  const AddMedicineScreen({super.key, required this.userId});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePickerService _imageService = ImagePickerService();

  File? _selectedImage;
  int _timesPerDay = 1;
  int _durationDays = 7;
  final List<TimeOfDay> _reminderTimes = [];

  final Color _primaryColor = const Color(0xFF4A90A4);

  int get _currentUserId => widget.userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Medicine', style: TextStyle(fontSize: 18.sp)),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildImageSection(),
              SizedBox(height: 20.h),
              _buildTextField(
                controller: _nameController,
                label: 'Medicine Name',
                hint: 'Enter medicine name',
                icon: Icons.medical_services,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                controller: _dosageController,
                label: 'Dosage',
                hint: 'e.g., 500mg, 1 tablet',
                icon: Icons.balance,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              _buildTimesPerDaySection(),
              SizedBox(height: 16.h),
              _buildDurationSection(),
              SizedBox(height: 16.h),
              _buildReminderTimesSection(),
              SizedBox(height: 30.h),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : Icon(Icons.photo_camera, size: 40.sp, color: Colors.grey),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.camera),
              icon: Icon(Icons.camera_alt, size: 16.sp),
              label: Text('Camera', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            ElevatedButton.icon(
              onPressed: () => _pickImage(ImageSource.gallery),
              icon: Icon(Icons.photo_library, size: 16.sp),
              label: Text('Gallery', style: TextStyle(fontSize: 12.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: _primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimesPerDaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Times Per Day',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              onPressed: _timesPerDay > 1
                  ? () => setState(() => _timesPerDay--)
                  : null,
              icon: Icon(
                Icons.remove,
                color: _timesPerDay > 1 ? _primaryColor : Colors.grey,
              ),
            ),
            Text(
              '$_timesPerDay time${_timesPerDay > 1 ? 's' : ''}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
            ),
            IconButton(
              onPressed: _timesPerDay < 6
                  ? () => setState(() => _timesPerDay++)
                  : null,
              icon: Icon(
                Icons.add,
                color: _timesPerDay < 6 ? _primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (Days)',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<int>(
<<<<<<< HEAD
          initialValue: _durationDays,
=======
          value: _durationDays,
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
          items: [7, 10, 14, 21, 30, 60, 90].map((days) {
            return DropdownMenuItem(value: days, child: Text('$days days'));
          }).toList(),
          onChanged: (value) => setState(() => _durationDays = value!),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTimesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reminder Times',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            IconButton(
              onPressed: _addReminderTime,
              icon: Icon(Icons.add_alarm, color: _primaryColor),
            ),
          ],
        ),
        ..._reminderTimes.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          return ListTile(
            leading: Icon(Icons.access_time, color: _primaryColor),
<<<<<<< HEAD
            title: Text(time.format(context)),
=======
            title: Text('${time.format(context)}'),
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeReminderTime(index),
            ),
          );
<<<<<<< HEAD
        }),
=======
        }).toList(),
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _saveMedicine,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'Save Medicine',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      File? imageFile;
      if (source == ImageSource.camera) {
        imageFile = await _imageService.pickImageFromCamera();
      } else {
        imageFile = await _imageService.pickImageFromGallery();
      }

      if (imageFile != null) {
        setState(() {
          _selectedImage = imageFile;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _addReminderTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _reminderTimes.add(selectedTime);
        _reminderTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  void _removeReminderTime(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  Future<void> _saveMedicine() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a medicine image')),
        );
        return;
      }

      if (_reminderTimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please add at least one reminder time')),
        );
        return;
      }

      try {
        final reminderTimeStrings = _reminderTimes.map((time) {
          return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        }).toList();

        final medicine = Medicine(
          userId: _currentUserId,
          name: _nameController.text,
          dosage: _dosageController.text,
          timesPerDay: _timesPerDay,
          durationDays: _durationDays,
          imagePath: _selectedImage!.path,
          startDate: DateTime.now().toIso8601String(),
          isActive: true,
          reminderTimes: reminderTimeStrings,
        );

        await _dbHelper.insertMedicine(medicine);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Medicine saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save medicine: $e')));
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }
}
