import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:donation_app/themes/colors.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String username = '';
  String email = '';
  String birthYear = '';
  String region = '';
  String gender = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          username = data['username'] ?? '';
          email = data['email'] ?? '';
          birthYear = data['birthYear'] ?? '';
          region = data['region'] ?? '';
          gender = data['gender'] ?? '';
        });
      }
    }
  }

  Future<void> _updateUserField(String field, String value) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update({field: value});
    }
  }

  void _editField(String field, String title, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              String newValue = controller.text.trim();
              setState(() {
                switch (field) {
                  case 'username':
                    username = newValue;
                    break;
                  case 'birthYear':
                    birthYear = newValue;
                    break;
                  case 'region':
                    region = newValue;
                    break;
                  case 'gender':
                    gender = newValue;
                    break;
                }
              });
              await _updateUserField(field, newValue);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableCard(String label, String value, String field) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(value.isEmpty ? "Not set" : value,
            style: TextStyle(color: Colors.grey.shade700)),
        trailing: Icon(Icons.edit, color: Colors.grey.shade600),
        onTap: () => _editField(field, label, value),
      ),
    );
  }

  Widget _buildDisabledCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(value.isEmpty ? "Not set" : value,
            style: TextStyle(color: Colors.grey.shade700)),
        trailing: const Icon(Icons.lock, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title:
            const Text("Edit Profile", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Profile photo section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            color: Colors.white,
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.background,
                  backgroundImage: AssetImage('assets/images/usericon.png'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildEditableCard("Username", username, 'username'),
          _buildDisabledCard("Email", email),
          _buildEditableCard("Birth Year", birthYear, 'birthYear'),
          _buildEditableCard("Region", region, 'region'),
          _buildEditableCard("Gender", gender, 'gender'),
        ],
      ),
    );
  }
}
