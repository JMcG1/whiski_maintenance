import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseImageUploader {
  static Future<String> uploadImage(File imageFile, String path) async {
    String fileName = '$path/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await FirebaseStorage.instance.ref(fileName).putFile(imageFile);
      String imageUrl = await FirebaseStorage.instance.ref(fileName).getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw e; // Rethrow the error to handle it in the calling function
    }
  }
}
