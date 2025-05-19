import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  /// Picks an image from the source and returns it as a base64 string
  static Future<String?> pickAndEncodeImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return null;
      }

      // Get the image bytes
      final bytes = await pickedFile.readAsBytes();

      // Resize to reduce size if necessary
      final resizedBytes = await resizeImage(bytes);

      // Convert to base64
      final base64String = base64Encode(resizedBytes);
      return 'data:image/${pickedFile.name.split('.').last};base64,$base64String';
    } catch (e) {
      debugPrint('Error in pickAndEncodeImage: $e');
      rethrow;
    }
  }

  /// Resize image to reduce file size
  static Future<Uint8List> resizeImage(Uint8List bytes) async {
    try {
      // Use compute to move expensive work to a separate isolate
      return compute(_resizeImageInternal, bytes);
    } catch (e) {
      debugPrint('Error in resizeImage: $e');
      rethrow;
    }
  }

  static Uint8List _resizeImageInternal(Uint8List bytes) {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return bytes;

      // Only resize if the image is larger than desired dimensions
      if (image.width > 800 || image.height > 800) {
        image = img.copyResize(
          image,
          width: image.width > 800 ? 800 : image.width,
          height: image.height > 800 ? 800 : image.height,
        );
      }

      // Re-encode the image with reduced quality
      return Uint8List.fromList(img.encodeJpg(image, quality: 85));
    } catch (e) {
      debugPrint('Error in _resizeImageInternal: $e');
      rethrow;
    }
  }

  /// Decode base64 string to image bytes
  static Uint8List? decodeBase64Image(String? base64String) {
    try {
      if (base64String == null || base64String.isEmpty) {
        return null;
      }

      // Extract actual base64 content
      final data = base64String.split(',');
      if (data.length != 2) return null;
      
      return base64Decode(data[1]);
    } catch (e) {
      debugPrint('Error in decodeBase64Image: $e');
      return null;
    }
  }
}
