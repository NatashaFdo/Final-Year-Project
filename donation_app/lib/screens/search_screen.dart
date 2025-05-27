import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donation_app/screens/home_screen.dart';
import 'package:donation_app/screens/post_screen.dart';
import 'package:donation_app/screens/profile_screen.dart';
import 'package:donation_app/screens/singleitem_screen.dart';
import 'package:donation_app/themes/colors.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'Clothes',
    'Books',
    'Furniture',
    'Electronics',
    'Food'
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchItems(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch all donation items from Firestore
      final snapshot =
          await FirebaseFirestore.instance.collection('donation_items').get();

      final filteredItems = snapshot.docs.where((doc) {
        final data = doc.data();
        final title = data['title']?.toLowerCase() ?? '';
        final category = data['category']?.toLowerCase() ?? '';

        return title.contains(query.toLowerCase()) ||
            category.contains(query.toLowerCase());
      }).toList();

      setState(() {
        _searchResults = filteredItems;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print("Search error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    if (value.isNotEmpty) {
      _searchItems(value);
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  Widget _buildDonationItem(QueryDocumentSnapshot item) {
    final data = item.data() as Map<String, dynamic>;
    final imageUrl = (data['images'] as List?)?.isNotEmpty == true
        ? data['images'][0]
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: imageUrl != null
            ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 50),
        title: Text(data['title'] ?? 'Untitled'),
        subtitle: Text(data['category'] ?? 'Unknown'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SingleItemScreen(itemData: data),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by title or category...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: _categories.map((cat) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: _searchController.text == cat,
                    onSelected: (_) {
                      _searchController.text = cat;
                      _searchItems(cat);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                    ? const Center(child: Text("No results found"))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildDonationItem(_searchResults[index]);
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.primary,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.black,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
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
