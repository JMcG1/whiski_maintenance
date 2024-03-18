import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class AddIssueScreen extends StatefulWidget {
  const AddIssueScreen({Key? key}) : super(key: key);

  @override
  _AddIssueScreenState createState() => _AddIssueScreenState();
}

class _AddIssueScreenState extends State<AddIssueScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _uploadedFileURL;

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    String fileName = 'issues/${DateTime.now().millisecondsSinceEpoch}.jpg';
    try {
      await FirebaseStorage.instance.ref(fileName).putFile(image);
      String imageUrl = await FirebaseStorage.instance.ref(fileName).getDownloadURL();
      setState(() {
        _uploadedFileURL = imageUrl;
      });
    } catch (e) {
      // Handle errors
    }
  }

  Future<void> addIssue() async {
    if (_uploadedFileURL == null) {
      // Optionally handle the case where the user has not picked an image
    }

    await FirebaseFirestore.instance.collection('issues').add({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'location': _locationController.text,
      'isFixed': false,
      'timestamp': DateTime.now(),
      'imageURL': _uploadedFileURL ?? '', // Store the image URL
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 20),
            _imageFile == null
                ? Text('No image selected.')
                : Image.file(_imageFile!),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.camera),
              child: const Text('Take Photo'),
            ),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.gallery),
              child: const Text('Select from Gallery'),
            ),
            ElevatedButton(
              onPressed: () => uploadImageToFirebase(_imageFile!),
              child: const Text('Upload Image'),
            ),
            ElevatedButton(
              onPressed: addIssue,
              child: const Text('Add Issue'),
            ),
          ],
        ),
      ),
    );
  }
}
