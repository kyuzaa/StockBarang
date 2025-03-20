import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAddToCart;

  const ProductCard({super.key, required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final bool isOutOfStock = product['stock'] == 0;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Produk
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                product['imageUrl'] ?? 'https://via.placeholder.com/150',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/product.jpg', fit: BoxFit.cover);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Nama Produk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              product['name'] ?? 'Nama Produk',
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Harga Produk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              formatCurrency.format(product['price'] ?? 0),
              style: const TextStyle(color: Colors.green),
            ),
          ),

          // Stok Produk
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              isOutOfStock ? "Stok Habis" : "Stok: ${product['stock']}",
              style: TextStyle(color: isOutOfStock ? Colors.red : Colors.grey),
            ),
          ),

          const SizedBox(height: 8),

          // Tombol Tambah ke Keranjang
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ElevatedButton(
              onPressed: isOutOfStock ? null : onAddToCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOutOfStock ? Colors.grey : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Tambah ke Keranjang"),
            ),
          ),
        ],
      ),
    );
  }
}
