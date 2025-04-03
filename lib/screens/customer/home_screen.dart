import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos/widgets/product_card.dart';
import 'package:pos/widgets/category_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedCategory;
  String searchQuery = "";

  void _handleCategorySelection(String? category) {
    setState(() {
      selectedCategory = category;
      searchQuery = ""; // Reset pencarian saat kategori berubah
    });
  }

  void _handleSearch(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  void _handleAddToCart(BuildContext context, String productId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan login terlebih dahulu")),
      );
      return;
    }

    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
      .collection("products")
      .doc(productId)
      .get();

    if (!productSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk tidak ditemukan")),
      );
      return;
    }

    Map<String, dynamic> product = productSnapshot.data() as Map<String, dynamic>;

    DocumentReference cartRef = FirebaseFirestore.instance
      .collection("cart")
      .doc(user.uid)
      .collection("items")
      .doc(productId);

    DocumentSnapshot cartItem  = await cartRef.get();

    if (cartItem.exists) {
      int currentQuantity = cartItem.get("quantity") ?? 0;
      await cartRef.update({"quantity": currentQuantity + 1});
    } else {
      await cartRef.set({
        "id": productId, // Gunakan ID dari Firestore
        "name": product["name"],
        "price": product["price"],
        "image": product["imageUrl"] ?? "",
        "quantity": 1,
        "createdAt": FieldValue.serverTimestamp(),
      });
  }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product["name"]} ditambahkan ke keranjang!')),
    );
  }

  Stream<QuerySnapshot> _getProductStream() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection("products");

    if (selectedCategory != null) {
      query = query.where("category", isEqualTo: selectedCategory);
    }

    if (searchQuery.isNotEmpty) {
      query = query.where("name", isGreaterThanOrEqualTo: searchQuery)
                  .where("name", isLessThanOrEqualTo: "$searchQuery\uf8ff");
    }

    return query.snapshots();
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

                ],
              ),
            ),
            TextButton(
              onPressed: () => _handleCategorySelection(null),
              child: const Text("Reset Filter"),
            ),
            const SizedBox(height: 20),

            // Produk Terbaru (Hanya tampil jika tidak memilih kategori dan tidak mencari)
            // Produk Terbaru (Hanya tampil jika tidak memilih kategori dan tidak mencari)
          if (selectedCategory == null && searchQuery.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text("Produk Terbaru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            SizedBox(
              height: 250, // Sesuaikan tinggi agar cukup untuk satu baris produk
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("products")
                    .orderBy("createdAt", descending: true)
                    .limit(4)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  var products = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal, // Produk ditampilkan ke samping
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var productData = products[index].data();
                      String productId = products[index].id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10), // Beri sedikit jarak antar produk
                        child: SizedBox(
                          width: 150,// Atur ukuran produk agar cukup besar
                          child: ProductCard(
                            product: productData,
                            onAddToCart: () => _handleAddToCart(context, productId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],


            const SizedBox(height: 20),

            // Produk berdasarkan kategori atau pencarian
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Semua Produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            StreamBuilder(
              stream: _getProductStream(),
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
                    var productData = filteredProducts[index].data() as Map<String, dynamic>;
                    String productId = filteredProducts[index].id;
                    return ProductCard(
                      product: productData,
                      onAddToCart: () => _handleAddToCart(context, productId),
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
