// lib/core/services/image_picker_service.dart
<<<<<<< HEAD
=======
import '/models/medicine_model.dart';
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
<<<<<<< HEAD
=======

  // التقاط صورة من الكاميرا
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
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
<<<<<<< HEAD
=======

  // اختيار صورة من المعرض
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
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

<<<<<<< HEAD
=======
  // حفظ الصورة محلياً
>>>>>>> 2ed123706f65e33f098538d7ddb89a1b0d12b127
  Future<File> _saveImageToLocal(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final String fileName =
        'medicine_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String localPath = '${directory.path}/$fileName';

    return await imageFile.copy(localPath);
  }
}
