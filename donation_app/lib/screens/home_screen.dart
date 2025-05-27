import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donation_app/screens/profile_screen.dart';
import 'package:donation_app/screens/search_screen.dart';
import 'package:donation_app/screens/singleitem_screen.dart';
import 'package:donation_app/screens/category_item_screen.dart';
import 'package:donation_app/themes/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:donation_app/screens/post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Set<String> savedItemIds = {};

  @override
  void initState() {
    super.initState();
    fetchSavedItems();
  }

  Future<void> fetchSavedItems() async {
    final user = _auth.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('saved_items')
          .get();

      setState(() {
        savedItemIds = snapshot.docs.map((doc) => doc.id).toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Home'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                height: 250.0,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
              ),
              items: [
                'assets/images/sofa.jpg',
                'assets/images/djack.jpg',
                'assets/images/books.jpg',
                'assets/images/carrot.jpg',
              ].map((imagePath) {
                return Container(
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 10),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    CategoryIcon(
                      label: "Clothes",
                      iconAsset: 'assets/images/clothicon.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CategoryItemsScreen(category: "Clothes"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    CategoryIcon(
                      label: "Books",
                      iconAsset: 'assets/images/bkicon.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CategoryItemsScreen(category: "Books"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    CategoryIcon(
                      label: "Furniture",
                      iconAsset: 'assets/images/furicon.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoryItemsScreen(
                                category: "Furniture"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    CategoryIcon(
                      label: "Electronics",
                      iconAsset: 'assets/images/elicon.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CategoryItemsScreen(
                                category: "Electronics"),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    CategoryIcon(
                      label: "Food",
                      iconAsset: 'assets/images/vegicon.png',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CategoryItemsScreen(category: "Food"),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Items Grid
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('donation_items')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No items found.'));
                }

                final items = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.75,
                  ),
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data();
                    final imageUrl =
                        (data['images'] as List?)?.isNotEmpty == true
                            ? data['images'][0]
                            : null;

                    final isSaved = savedItemIds.contains(item.id);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleItemScreen(
                              itemData: {
                                'id': item.id, // Pass the document ID!
                                ...data,
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)),
                                    child: imageUrl != null
                                        ? Image.network(imageUrl,
                                            fit: BoxFit.cover,
                                            width: double.infinity)
                                        : const Icon(Icons.image, size: 80),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: Icon(
                                        isSaved
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: isSaved
                                            ? Colors.white
                                            : Colors.white,
                                        size: 28,
                                      ),
                                      onPressed: () async {
                                        final user = _auth.currentUser;
                                        if (user != null) {
                                          final savedRef = FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .doc(user.uid)
                                              .collection('saved_items')
                                              .doc(item.id);

                                          if (isSaved) {
                                            await savedRef.delete();
                                            savedItemIds.remove(item.id);
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content:
                                                        Text('Item removed')));
                                          } else {
                                            await savedRef.set({
                                              'item_id': item.id,
                                              'saved_at':
                                                  FieldValue.serverTimestamp(),
                                              'item_data': data,
                                            });
                                            savedItemIds.add(item.id);
                                            // ignore: use_build_context_synchronously
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content:
                                                        Text('Item saved')));
                                          }

                                          setState(() {});
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['title'] ?? 'Untitled',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Posted by: ${data['username'] ?? 'Unknown'}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primary,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SearchScreen()),
            );
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PostScreen()),
            );
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback onTap;

  const CategoryIcon({
    required this.label,
    required this.iconAsset,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(iconAsset, width: 60, height: 60),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
