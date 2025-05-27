// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donation_app/widgets/location_picker_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:donation_app/themes/colors.dart';
import 'home_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String? selectedCategory;
  String? selectedLocation;
  double? selectedLat;
  double? selectedLng;
  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController contactController = TextEditingController();

  final List<String> categories = [
    "Clothes",
    "Books",
    "Furniture",
    "Electronics",
    "Food"
  ];

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      final totalSelected = pickedFiles.length + _selectedImages.length;
      if (totalSelected > 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can select up to 5 images only.")),
        );
        return;
      }
      setState(() {
        _selectedImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    final storage = FirebaseStorage.instance;

    for (var image in _selectedImages) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = storage.ref().child("donation_images/$fileName");
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  Future<String?> _getUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      return doc.data()?['username'];
    }
    return null;
  }

  Future<void> _submitDonation() async {
    if (selectedCategory == null ||
        selectedLocation == null ||
        _selectedImages.isEmpty ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    try {
      final imageUrls = await _uploadImages();
      final user = FirebaseAuth.instance.currentUser;
      final username = await _getUsername();

      final collectionRef =
          FirebaseFirestore.instance.collection('donation_items');

      final newDocRef = await collectionRef.add({
        'category': selectedCategory,
        'location': selectedLocation,
        'latitude': selectedLat,
        'longitude': selectedLng,
        'images': imageUrls,
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'contact': contactController.text.trim(),
        'user_id': user?.uid,
        'username': username,
        'timestamp': Timestamp.now(),
      });

      await newDocRef.update({'id': newDocRef.id});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Item posted successfully!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post item: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Add Item'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImages.isEmpty
                      ? const Center(
                          child: Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.black54),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) => Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.all(5),
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                  "Photos (${_selectedImages.length}/5): Add more photos to show condition."),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                hint: const Text("Select a category"),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                      value: category, child: Text(category));
                }).toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
              ),
              const SizedBox(height: 15),
              const Text("Title"),
              const SizedBox(height: 5),
              TextFormField(
                controller: titleController,
                decoration:
                    const InputDecoration(border: UnderlineInputBorder()),
              ),
              const SizedBox(height: 15),
              const Text("Description"),
              const SizedBox(height: 5),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: "e.g 2 x bottles of shampoo, almost full",
                  border: UnderlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Text("Contact No"),
              const SizedBox(height: 5),
              TextFormField(
                controller: contactController,
                keyboardType: TextInputType.phone,
                decoration:
                    const InputDecoration(border: UnderlineInputBorder()),
              ),
              const SizedBox(height: 35),
              LocationPicker(
                onLocationSelected: (address, lat, lng) {
                  setState(() {
                    selectedLocation = address;
                    selectedLat = lat;
                    selectedLng = lng;
                  });
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBackground,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _submitDonation,
                  child: const Text(
                    "Submit",
                    style: TextStyle(color: AppColors.buttonText),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
