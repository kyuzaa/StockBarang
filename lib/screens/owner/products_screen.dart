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
      appBar: AppBar(
        title: const Text("Daftar Produk", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("products").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("Belum ada produk", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
            }

            var products = snapshot.data!.docs;

            return LayoutBuilder(
              builder: (context, constraints) {
                bool isMobile = constraints.maxWidth < 600;
                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: DataTable(
                        columnSpacing: isMobile ? 10 : 20,
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blueAccent),
                        headingTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        columns: const [
                          DataColumn(label: Text("Gambar")),
                          DataColumn(label: Text("Nama")),
                          DataColumn(label: Text("Harga")),
                          DataColumn(label: Text("Stok")),
                          DataColumn(label: Text("Status")),
                          DataColumn(label: Text("Aksi")),
                        ],
                        rows: products.map((product) {
                          var data = product.data() as Map<String, dynamic>;
                          return DataRow(cells: [
                            DataCell(Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 3, spreadRadius: 1),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: data["imageUrl"] != null
                                    ? Image.network(data["imageUrl"], fit: BoxFit.cover)
                                    : const Icon(Icons.image, size: 40, color: Colors.grey),
                              ),
                            )),
                            DataCell(Text(data["name"] ?? "Tidak ada nama", style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(Text("Rp ${data["price"]}", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))),
                            DataCell(Text(data["stock"].toString())),
                            DataCell(Text(
                              data["status"] == true ? "Aktif" : "Tidak Aktif",
                              style: TextStyle(
                                color: data["status"] == true ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditProductScreen(productId: product.id)),
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
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "/add_product");
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _deleteProduct(String productId) async {
    await FirebaseFirestore.instance.collection("products").doc(productId).delete();
  }
}
