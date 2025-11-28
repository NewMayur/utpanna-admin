import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FirebaseStorageService {
  // Use the specific Firebase Storage bucket
  static FirebaseStorage get instance =>
      FirebaseStorage.instanceFor(bucket: 'utpanna-dev.firebasestorage.app');

  /// Upload image file to Firebase Storage
  static Future<String?> uploadImage({
    required String path,
    required String fileName,
    XFile? imageFile,
    File? file,
  }) async {
    try {
      final Reference ref = instance.ref().child(path).child(fileName);

      UploadTask uploadTask;

      if (kIsWeb) {
        // Web platform - use Uint8List
        if (imageFile != null) {
          final bytes = await imageFile.readAsBytes();
          uploadTask = ref.putData(
            bytes,
            SettableMetadata(
                contentType: 'image/${imageFile.path.split('.').last}'),
          );
        } else {
          throw Exception('Image file required for web upload');
        }
      } else {
        // Mobile platforms - use file path
        if (file != null) {
          uploadTask = ref.putFile(
            file,
            SettableMetadata(contentType: 'image/${file.path.split('.').last}'),
          );
        } else if (imageFile != null) {
          final bytes = await imageFile.readAsBytes();
          uploadTask = ref.putData(
            bytes,
            SettableMetadata(
                contentType: 'image/${imageFile.path.split('.').last}'),
          );
        } else {
          throw Exception('File or image file required for upload');
        }
      }

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Image upload error: $e');
      return null;
    }
  }

  /// Upload multiple images and return list of URLs
  static Future<List<String>> uploadMultipleImages({
    required String path,
    required List<XFile> imageFiles,
    String prefix = 'image',
  }) async {
    final List<String> downloadUrls = [];

    for (var i = 0; i < imageFiles.length; i++) {
      final fileName =
          '${prefix}_${DateTime.now().millisecondsSinceEpoch}_$i.${imageFiles[i].path.split('.').last}';
      final url = await uploadImage(
        path: path,
        fileName: fileName,
        imageFile: imageFiles[i],
      );

      if (url != null) {
        downloadUrls.add(url);
      }
    }

    return downloadUrls;
  }

  /// Delete image from Firebase Storage
  static Future<void> deleteImage(String url) async {
    try {
      final Reference ref = instance.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Image delete error: $e');
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Generate unique file name
  static String generateFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_${timestamp}.$extension';
  }

  /// Get file size limit (5MB for images)
  static const int maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB

  /// Validate image file
  static Future<bool> validateImageFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.length > maxFileSizeInBytes) {
        print('File size too large: ${bytes.length} bytes');
        return false;
      }

      final extension = file.path.split('.').last.toLowerCase();
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

      if (!allowedExtensions.contains(extension)) {
        print('Invalid file type: .$extension');
        return false;
      }

      return true;
    } catch (e) {
      print('File validation error: $e');
      return false;
    }
  }
}
