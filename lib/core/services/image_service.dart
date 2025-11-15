// lib/core/services/image_picker_service.dart
import '/models/medicine_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  // التقاط صورة من الكاميرا
  Future<File?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (image != null) {
      return await _saveImageToLocal(File(image.path));
    }
    return null;
  }

  // اختيار صورة من المعرض
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );

    if (image != null) {
      return await _saveImageToLocal(File(image.path));
    }
    return null;
  }

  // حفظ الصورة محلياً
  Future<File> _saveImageToLocal(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName =
        'medicine_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String localPath = '${directory.path}/$fileName';

    return await imageFile.copy(localPath);
  }
}
