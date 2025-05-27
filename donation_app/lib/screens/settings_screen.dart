import 'package:donation_app/screens/about_screen.dart';
import 'package:donation_app/screens/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:donation_app/themes/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Settings", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(
            height: 25,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 70,
                  child: ListTile(
                    leading: const Icon(Icons.person, color: Colors.black87),
                    title: const Text(
                        style: TextStyle(fontSize: 18), 'Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfile()));
                    },
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: 70,
                  child: ListTile(
                    leading:
                        const Icon(Icons.info_outline, color: Colors.black87),
                    title: const Text(style: TextStyle(fontSize: 18), 'About'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AboutScreen()));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SwitchListTile(
              title:
                  const Text("Notifications", style: TextStyle(fontSize: 18)),
              value: notificationsEnabled,
              activeColor: const Color.fromARGB(255, 120, 120, 115),
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
