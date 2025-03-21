import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pos/screens/owner/product/add_product_screen.dart';
import 'product/edit_product_screen.dart';
import 'package:pos/screens/owner/dashboard_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final formatCurrency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final String defaultImageUrl =
      "https://i.ibb.co.com/qLKY7pxs/no-image.jpg"; // Gambar default dari imgbb

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isSmallScreen = screenWidth < 600; // Gunakan GridView jika layar kecil

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

          return isSmallScreen
              ? _buildGridView(products) // Gunakan GridView di layar kecil
              : _buildDataTable(products); // Gunakan DataTable di layar besar
        },
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Ambil state parent (OwnerDashboardScreen) untuk ubah selected index
            final dashboardState = context.findAncestorStateOfType<OwnerDashboardScreenState>();
            if (dashboardState != null) {
              dashboardState.onItemTapped(2); // Index 2 = AddProductScreen
            }
          },
          child: const Icon(Icons.add),
        ),

    );
  }

  // TABEL UNTUK LAYAR BESAR
  Widget _buildDataTable(List<QueryDocumentSnapshot> products) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
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
              child: Image.network(
                data["imageUrl"] ?? defaultImageUrl, // Gunakan gambar dari imgbb jika null
                fit: BoxFit.cover,
              ),
            )),

            // Nama Produk
            DataCell(Text(data["name"] ?? "Tidak ada nama")),

            // Harga
            DataCell(Text(formatCurrency.format(data["price"] ?? 0))),

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
                        builder: (context) =>
                            EditProductScreen(productId: product.id),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDeleteProduct(product.id),
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }

  // GRID VIEW UNTUK LAYAR KECIL
  Widget _buildGridView(List<QueryDocumentSnapshot> products) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 kolom untuk tampilan responsif
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemBuilder: (context, index) {
          var data = products[index].data() as Map<String, dynamic>;

          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(10)),
                    child: Image.network(
                      data["imageUrl"] ?? defaultImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.network(defaultImageUrl, fit: BoxFit.cover);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data["name"] ?? "Tidak ada nama",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    formatCurrency.format(data["price"] ?? 0),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Stok: ${data["stock"]}",
                    style: TextStyle(
                        color: data["stock"] == 0 ? Colors.red : Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductScreen(
                                  productId: products[index].id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _confirmDeleteProduct(products[index].id),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // KONFIRMASI HAPUS PRODUK
  void _confirmDeleteProduct(String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text("Apakah Anda yakin ingin menghapus produk ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              _deleteProduct(productId);
              Navigator.pop(context);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // HAPUS PRODUK DARI FIRESTORE
  void _deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection("products")
        .doc(productId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Produk berhasil dihapus")));
  }
}
