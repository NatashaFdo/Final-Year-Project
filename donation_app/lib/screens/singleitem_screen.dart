import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donation_app/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'image_view_screen.dart';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class SingleItemScreen extends StatefulWidget {
  final Map<String, dynamic> itemData;

  const SingleItemScreen({super.key, required this.itemData});

  @override
  State<SingleItemScreen> createState() => _SingleItemScreenState();
}

class _SingleItemScreenState extends State<SingleItemScreen> {
  Future<void> _sendRequest(
      String itemId, String requesterId, BuildContext context) async {
    try {
      final requestsCollection = FirebaseFirestore.instance
          .collection('donation_items')
          .doc(itemId)
          .collection('requests');

      final existingRequests = await requestsCollection
          .where('requesterId', isEqualTo: requesterId)
          .get();

      if (existingRequests.docs.isNotEmpty) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already requested this item')),
        );
        return;
      }

      await requestsCollection.add({
        'requesterId': requesterId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Fetch donor's FCM token
      final itemDoc = await FirebaseFirestore.instance
          .collection('donation_items')
          .doc(itemId)
          .get();

      final donorUserId = itemDoc.data()?['user_id'];
      if (donorUserId != null) {
        final donorDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(donorUserId)
            .get();
        final fcmToken = donorDoc.data()?['fcmToken'];
        if (fcmToken != null) {
          try {
            // Send notification via custom Node.js backend
            final response = await http.post(
              Uri.parse("http://192.168.1.28:3000/send-notification"),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                "token": fcmToken,
                "title": "ReKindle",
                "body": "Push sent via custom Node.js backend 123"
              }),
            );

            // ignore: avoid_print
            print(response);
          } catch (e) {
            // Optionally handle Cloud Function error
          }
        }
      }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? images = widget.itemData['images'];
    final double? lat = widget.itemData['latitude'];
    final double? lng = widget.itemData['longitude'];
    final String? username = widget.itemData['username'];
    final String? contact = widget.itemData['contact'];
    final String? donorUserId =
        widget.itemData['user_id'] ?? widget.itemData['userId'];
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final String itemId = widget.itemData['id'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemData['title'] ?? 'Item Details'),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images != null && images.isNotEmpty)
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final imageUrl = images[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullImageViewScreen(
                              imageUrl: imageUrl,
                              tag: 'image$index',
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: 'image$index',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            imageUrl,
                            width: 220,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            if (currentUserId.isNotEmpty && itemId.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUserId)
                          .collection('saved_items')
                          .doc(itemId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        final isSaved = snapshot.data?.exists == true;
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isSaved ? Icons.star : Icons.star_border,
                                color: isSaved ? Colors.amber : Colors.grey,
                                size: 32,
                              ),
                              onPressed: () async {
                                final savedRef = FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(currentUserId)
                                    .collection('saved_items')
                                    .doc(itemId);
                                if (isSaved) {
                                  await savedRef.delete();
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Item removed from saved')),
                                  );
                                } else {
                                  await savedRef.set({
                                    'item_id': itemId,
                                    'saved_at': FieldValue.serverTimestamp(),
                                    'item_data': widget.itemData,
                                  });
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Item saved')),
                                  );
                                }
                              },
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isSaved ? 'Saved' : 'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSaved
                                    ? Colors.amber[800]
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.itemData['title'] ?? '',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (username != null)
                    Text(
                      '$username is donating',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  const SizedBox(height: 10),
                  _buildDetailRow(Icons.category, widget.itemData['category']),
                  _buildDetailRow(Icons.place, widget.itemData['location']),
                  _buildDetailRow(
                      Icons.description, widget.itemData['description']),
                  if (contact != null) _buildDetailRow(Icons.phone, contact),
                ],
              ),
            ),

            if (lat != null && lng != null) ...[
              const SizedBox(height: 24),
              const Row(
                children: [
                  Icon(Icons.map_rounded, size: 28, color: Colors.blueGrey),
                  SizedBox(width: 12),
                  Text(
                    "View on Map",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(lat, lng),
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('itemLocation'),
                        position: LatLng(lat, lng),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    liteModeEnabled: true,
                  ),
                ),
              ),
            ],

            // Request button (only show if current user is NOT the donor)
            if (currentUserId.isNotEmpty &&
                donorUserId != null &&
                currentUserId != donorUserId) ...[
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (widget.itemData['id'] != null) {
                      await _sendRequest(itemId, currentUserId, context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid item ID')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Request Item',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 24, color: Colors.green[800]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
