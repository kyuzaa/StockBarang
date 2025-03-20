import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product/edit_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Produk")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("products").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Belum ada produk"));
          }

          var products = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text("Gambar")),
                DataColumn(label: Text("Nama Produk")),
                DataColumn(label: Text("Harga")),
                DataColumn(label: Text("Stok")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Aksi")),
              ],
              rows: products.map((product) {
                var data = product.data() as Map<String, dynamic>;

                return DataRow(cells: [
                  // Gambar Produk
                  DataCell(SizedBox(
                    width: 50,
                    height: 50,
                    child: data["imageUrl"] != null
                        ? Image.network(data["imageUrl"], fit: BoxFit.cover)
                        : const Icon(Icons.image),
                  )),

                  // Nama Produk
                  DataCell(Text(data["name"] ?? "Tidak ada nama")),

                  // Harga
                  DataCell(Text("Rp ${data["price"]}")),

                  // Stok
                  DataCell(Text(data["stock"].toString())),

                  // Status
                  DataCell(Text(data["status"] == true ? "Aktif" : "Tidak Aktif")),

                  // Tombol Edit & Hapus
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductScreen(productId: product.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  )),
                ]);
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/add_product");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fungsi hapus produk dari Firestore
  void _deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection("products").doc(productId).delete();
  }
}
