import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos/widgets/product_card.dart';
import 'package:pos/widgets/category_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  String searchQuery = ""; // Menyimpan teks pencarian

  void _handleCategorySelection(String? category) {
    setState(() {
      selectedCategory = category;
      searchQuery = ""; // Reset pencarian jika memilih kategori
    });
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase(); // Simpan query dalam huruf kecil untuk pencarian case-insensitive
      selectedCategory = null; // Reset kategori saat melakukan pencarian
    });
  }

  Future<void> _handleAddToCart(BuildContext context, Map<String, dynamic> product) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userId = user.uid;
    CollectionReference cartRef = FirebaseFirestore.instance.collection('cart').doc(userId).collection('items');

    QuerySnapshot existingProduct = await cartRef.where('id', isEqualTo: product['id']).get();

    if (existingProduct.docs.isNotEmpty) {
      var docId = existingProduct.docs.first.id;
      var currentQuantity = existingProduct.docs.first['quantity'];
      await cartRef.doc(docId).update({'quantity': currentQuantity + 1});
    } else {
      await cartRef.add({
        'id': product['id'],
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'quantity': 1,
      });
    }

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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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
                  BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
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
                onChanged: _handleSearch,
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  CategoryButton(
                    icon: Icons.fastfood,
                    label: "Bahan Pokok",
                    onTap: () => _handleCategorySelection("Bahan Pokok"),
                  ),
                  CategoryButton(
                    icon: Icons.local_drink,
                    label: "Minuman",
                    onTap: () => _handleCategorySelection("Minuman"),
                  ),
                  CategoryButton(
                    icon: Icons.soap,
                    label: "Alat Mandi",
                    onTap: () => _handleCategorySelection("Alat Mandi"),
                  ),
                  CategoryButton(
                    icon: Icons.cookie,
                    label: "Makanan Ringan",
                    onTap: () => _handleCategorySelection("Makanan Ringan"),
                  ),
                  CategoryButton(
                    icon: Icons.cleaning_services,
                    label: "Alat Kebersihan",
                    onTap: () => _handleCategorySelection("Alat Kebersihan"),
                  ),
                  CategoryButton(
                    icon: Icons.create,
                    label: "Alat Tulis",
                    onTap: () => _handleCategorySelection("Alat Tulis"),
                  ),
                  CategoryButton(
                    icon: Icons.medical_services,
                    label: "Obat",
                    onTap: () => _handleCategorySelection("Obat"),
                  ),
                  TextButton(
                    onPressed: () => _handleCategorySelection(null), // Reset filter
                    child: const Text("Reset Filter"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Produk yang sesuai dengan pencarian atau kategori
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
              stream: (searchQuery.isNotEmpty)
                  ? FirebaseFirestore.instance
                      .collection("products")
                      .where("name_lowercase", isGreaterThanOrEqualTo: searchQuery)
                      .where("name_lowercase", isLessThan: '${searchQuery}z')
                      .snapshots()
                  : (selectedCategory != null)
                      ? FirebaseFirestore.instance
                          .collection("products")
                          .where("category", isEqualTo: selectedCategory)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection("products")
                          .orderBy("createdAt", descending: true)
                          .limit(6)
                          .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                var filteredProducts = snapshot.data!.docs;
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
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    var productData = filteredProducts[index].data();
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
