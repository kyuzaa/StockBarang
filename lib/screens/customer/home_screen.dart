import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos/widgets/product_card.dart';
import 'package:pos/widgets/category_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Fungsi untuk menangani saat produk ditambahkan ke keranjang
  void _handleAddToCart(BuildContext context, Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product["name"]} ditambahkan ke keranjang!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: InputDecoration(
            hintText: "Cari produk...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Promo
            Container(
              margin: const EdgeInsets.all(16),
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/banner.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

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

            const SizedBox(height: 10),

            // Image Slider
            SizedBox(
              height: 150,
              child: PageView(
                children: [
                  Image.asset('assets/slider1.jpg', fit: BoxFit.cover),
                  Image.asset('assets/slider2.jpg', fit: BoxFit.cover),
                  Image.asset('assets/slider3.jpg', fit: BoxFit.cover),
                ],
              ),
            ),

            // Produk Terbaru
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text("Produk Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("products")
                  .orderBy("createdAt", descending: true)
                  .limit(4)
                  .snapshots(),
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

            // Semua Produk
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
