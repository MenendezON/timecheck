import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timecheck/service/showSnackBar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';

class NewEmployeeForm extends StatefulWidget {
  @override
  _NewEmployeeFormState createState() => _NewEmployeeFormState();
}

class _NewEmployeeFormState extends State<NewEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _status = 'admin'; // Default value
  File? _avatarImage;
  File? _imageFile;
  String? _imageUrl;
  final picker = ImagePicker();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, save the employee data to Firestore
      // Assuming 'employees' is the collection name
      _uploadImage();

    }
  }

  /*void _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _avatarImage = File(pickedImage.path);
      });
    }
  }*/
  Future<void> _pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) {
      return;
    }
    try {
      // Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + UniqueKey().toString();
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child(fileName);
      await ref.putFile(_imageFile!);

      // Get download URL
      _imageUrl = await ref.getDownloadURL();

      /*// Save download URL to Firestore
      await FirebaseFirestore.instance.collection('images').add({
        'url': _imageUrl,
        // You can add more fields as needed
      });*/
      await FirebaseFirestore.instance.collection('employees').add({
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'status': _status,
        'avatar': _imageUrl,
        // Add other fields as needed
      }).then((value) {
        // Handle successful submission
        // You can navigate to a different screen or show a success message
        showNotification(context, 'Employee added successfully');
      }).catchError((error) {
        // Handle errors
        showNotification(context, 'Failed to add employee: $error');
      });

      // Show success message or perform other actions
      print('Image uploaded successfully!');
    } catch (e) {
      // Handle errors
      print('Failed to upload image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_avatarImage != null)
                  Image.file(_avatarImage!, height: 100),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Avatar Image'),
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: 'First Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter first name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter last name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    // You can add email validation logic here
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(labelText: 'Status'),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                  items: ['admin', 'particular']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}