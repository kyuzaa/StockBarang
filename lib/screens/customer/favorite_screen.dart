import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  final List<Map<String, String>> favoriteItems = [
    {'name': 'Produk A', 'image': 'assets/banner_waroeng.jpg'},
    {'name': 'Produk B', 'image': "https://via.placeholder.com/150"},
    {'name': 'Produk C', 'image': "https://via.placeholder.com/150"},
    {'name': 'Produk D', 'image': "https://via.placeholder.com/150"},
  ];

  final List<Map<String, String>> relatedProducts = [
    {'name': 'Produk E', 'image': "https://via.placeholder.com/150"},
    {'name': 'Produk F', 'image': "https://via.placeholder.com/150"},
    {'name': 'Produk G', 'image': "https://via.placeholder.com/150"},
    {'name': 'Produk H', 'image': "https://via.placeholder.com/150"},
  ];

  FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Favorit Saya", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              width: double.infinity,
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/banner_waroeng.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Kategori Favorit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip("Elektronik"),
                  _buildCategoryChip("Pakaian"),
                  _buildCategoryChip("Makanan"),
                  _buildCategoryChip("Minuman"),
                  _buildCategoryChip("Alat Rumah"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildSectionTitle("Produk Favorit"),
            _buildGridList(favoriteItems, true),
            _buildSectionTitle("Produk Terkait"),
            _buildGridList(relatedProducts, false),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.shopping_cart, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Chip(
        label: Text(label, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildGridList(List<Map<String, String>> items, bool isFavorite) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    item['image']!,
                    width: double.infinity,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item['name']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart, color: Colors.green),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(isFavorite ? Icons.delete : Icons.favorite_border, color: isFavorite ? Colors.redAccent : Colors.blueAccent),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}