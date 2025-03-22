import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAddToCart;

  const ProductCard({super.key, required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final bool isOutOfStock = product['stock'] == 0;

    return SizedBox(
      width: 150, // Atur lebar agar tidak terlalu kecil
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk dengan Placeholder Shimmer
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                product['imageUrl'] ?? '',
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.white,
                    child: Container(width: double.infinity, height: 100, color: Colors.grey),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/no_image.jpg', height: 100, width: double.infinity, fit: BoxFit.cover);
                },
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
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
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

            const Spacer(), // Pastikan ini ada untuk mencegah overflow

            // Tombol Tambah ke Keranjang
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isOutOfStock ? null : onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOutOfStock ? Colors.grey : Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Tambah ke Keranjang",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
