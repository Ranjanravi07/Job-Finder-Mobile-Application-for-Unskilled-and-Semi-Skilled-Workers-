import 'package:image_picker/image_picker.dart';

/// Wraps `image_picker` so both profile-creation screens share one helper.
class ImagePickService {
  ImagePickService._();

  static final ImagePickService instance = ImagePickService._();

  final ImagePicker _picker = ImagePicker();

  /// Returns the local path of the picked image, or `null` on cancel/error.
  Future<String?> pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return file?.path;
    } catch (_) {
      return null;
    }
  }
}
