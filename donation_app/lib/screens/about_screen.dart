import 'package:donation_app/themes/colors.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("About"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "About This App",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "This donation app is designed to bridge the gap between donors and individuals or organizations in need. "
                    "By encouraging sustainability and reducing waste, we help create a more responsible and connected community.",
                    style:
                        TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Key Features",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                      "• Donate items like clothes, books, electronics, and food leftovers."),
                  Text("• Find NGOs and people in need near your location."),
                  Text(
                      "• Upload photos and share your donation details easily."),
                  Text("• Real-time notifications and profile management."),
                  SizedBox(height: 20),
                  Text(
                    "Vision",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "We aim to build a sustainable donation ecosystem where no reusable item goes to waste. "
                    "Together, we can reduce environmental impact and make giving easier and more efficient.",
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Version",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text("1.0.0",
                      style: TextStyle(fontSize: 16, color: Colors.black54)),
                  SizedBox(height: 20),
                  Text(
                    "Contact Us",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text("Email: support@donationapp.lk"),
                  Text("Phone: +94 77 123 4567"),
                  SizedBox(height: 20),
                  Text(
                    "Developed with ❤️ in Sri Lanka",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
