import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class IssueDetailsPage extends StatefulWidget {
  final DocumentSnapshot? issueDocument;

  const IssueDetailsPage({required this.issueDocument});

  @override
  _IssueDetailsPageState createState() => _IssueDetailsPageState();
}

class _IssueDetailsPageState extends State<IssueDetailsPage> {
  final TextEditingController _actionsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  List<File> _imageFiles = [];
  bool isFixed = false;
  DateTime issueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.issueDocument != null) {
      // Populate form fields with existing data
      Map<String, dynamic> data = widget.issueDocument!.data() as Map<String, dynamic>;
      _actionsController.text = data['actions'] ?? '';
      _notesController.text = data['notes'] ?? '';
      isFixed = data['isFixed'] ?? false;
      issueDate = (data['timestamp'] as Timestamp).toDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data =
        widget.issueDocument?.data() as Map<String, dynamic> ?? {};
    String title = data['title'] ?? 'No Title';
    String description = data['description'] ?? 'No Description';
    String location = data['location'] ?? 'No Location';
    issueDate = (data['timestamp'] as Timestamp).toDate();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(issueDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Description: $description', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Location: $location', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Date: $formattedDate', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Status: ${isFixed ? 'Fixed' : 'Not Fixed'}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.camera),
              child: const Text('Take Photo'),
            ),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.gallery),
              child: const Text('Select from Gallery'),
            ),
            buildImagesList(),
            SizedBox(height: 20),
            TextField(
              controller: _actionsController,
              decoration: const InputDecoration(labelText: 'Actions'),
              maxLines: null,
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveIssue,
              child: const Text('Update Issue'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFiles.add(File(pickedFile.path));
      });
    }
  }

  Widget buildImagesList() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _imageFiles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageDialog(index),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Image.file(
                _imageFiles[index],
                width: 100,
                height: 100,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showImageDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: Image.file(
              _imageFiles[index],
              fit: BoxFit.contain,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final storageReference = FirebaseStorage.instance.ref().child(
          'issue_images/${DateTime.now().millisecondsSinceEpoch}.png');
      final UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() => null);
      final imageUrl = await storageReference.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return ""; // Return an empty string or handle the error as needed
    }
  }

  void saveIssue() async {
    String actions = _actionsController.text;
    String notes = _notesController.text;

    // Upload images and get their URLs
    List<String> imageUrls = [];
    for (final imageFile in _imageFiles) {
      String imageUrl = await uploadImage(imageFile);
      if (imageUrl.isNotEmpty) {
        imageUrls.add(imageUrl);
      }
    }

    // Save the issue data to Firestore
    FirebaseFirestore.instance.collection('issues').add({
      'actions': actions,
      'notes': notes,
      'images': imageUrls,
      'isFixed': isFixed,
      'timestamp': Timestamp.fromDate(DateTime.now()),
    });

    Navigator.of(context).pop();
  }
}
