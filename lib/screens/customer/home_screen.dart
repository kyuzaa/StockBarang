import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos/widgets/product_card.dart';
import 'package:pos/widgets/category_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleAddToCart(BuildContext context, Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product["name"]} ditambahkan ke keranjang!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        title: const Text(
          "Waroeng Barokan",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Promo
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/banner_waroeng.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Cari produk...",
                  prefixIcon: const Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Kategori Produk
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Kategori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryButton(icon: Icons.fastfood, label: "Bahan Pokok"),
                  CategoryButton(icon: Icons.local_drink, label: "Minuman"),
                  CategoryButton(icon: Icons.soap, label: "Alat Mandi"),
                  CategoryButton(icon: Icons.cookie, label: "Makanan Ringan"),
                  CategoryButton(icon: Icons.cleaning_services, label: "Alat Kebersihan"),
                  CategoryButton(icon: Icons.create, label: "Alat Tulis"),
                  CategoryButton(icon: Icons.medical_services, label: "Obat"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Produk Terbaru
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Produk Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("products").orderBy("createdAt", descending: true).limit(4).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var products = snapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var productData = products[index].data();
                    return ProductCard(
                      product: productData,
                      onAddToCart: () => _handleAddToCart(context, productData),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Semua Produk
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Semua Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance.collection("products").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var allProducts = snapshot.data!.docs;
                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: allProducts.length,
                  itemBuilder: (context, index) {
                    var productData = allProducts[index].data();
                    return ProductCard(
                      product: productData,
                      onAddToCart: () => _handleAddToCart(context, productData),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}