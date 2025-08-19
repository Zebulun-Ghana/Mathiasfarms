import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndUploadImage() async {
    try {
      print('Starting image picker...'); // Debug print

      // Try to pick image from gallery with error handling
      XFile? image;
      try {
        image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );
      } catch (pickerError) {
        print('Image picker error: $pickerError');
        // Try alternative approach
        try {
          image = await _picker.pickImage(
            source: ImageSource.gallery,
          );
        } catch (e) {
          print('Alternative picker also failed: $e');
          return null;
        }
      }

      print('Image picker result: ${image?.path}'); // Debug print

      if (image == null) {
        print('No image selected'); // Debug print
        return null;
      }

      print('Starting upload to Firebase Storage...'); // Debug print
      // Upload to Firebase Storage
      final String imageUrl = await uploadImageToStorage(image);
      print('Upload completed: $imageUrl'); // Debug print
      return imageUrl;
    } catch (e) {
      print('Error picking/uploading image: $e');
      return null;
    }
  }

  Future<String> uploadImageToStorage(XFile image) async {
    try {
      print('Creating filename...'); // Debug print
      // Create a unique filename
      final String fileName =
          'products/${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      print('Filename: $fileName'); // Debug print

      print('Creating storage reference...'); // Debug print
      // Create reference to the file location
      final Reference ref = _storage.ref().child(fileName);

      print('Starting upload task...'); // Debug print
      // Upload the file
      final UploadTask uploadTask = ref.putFile(File(image.path));

      print('Waiting for upload to complete...'); // Debug print
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      print('Getting download URL...'); // Debug print
      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Upload successful: $downloadUrl'); // Debug print
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        final Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
