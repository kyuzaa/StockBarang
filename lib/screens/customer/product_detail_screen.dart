import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  final Map<String, dynamic> productData;
  final void Function(BuildContext, String) onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.productData,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final bool isOutOfStock = productData['stock'] == 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(productData['name'] ?? 'Detail Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Gambar
            Image.network(productData['imageUrl'], height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),

            // Nama Produk
            Text(productData['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Harga
            Text(formatCurrency.format(productData['price']), style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 8),

            // Stok
            Text(isOutOfStock ? "Stok Habis" : "Stok: ${productData['stock']}", style: TextStyle(color: isOutOfStock ? Colors.red : Colors.grey)),

            const SizedBox(height: 24),

            // Deskripsi (jika ada)
            Text(productData['description'] ?? 'Tidak ada deskripsi produk.', textAlign: TextAlign.justify),

            const Spacer(),

            // Tombol Tambah ke Keranjang
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isOutOfStock ? null : () => onAddToCart(context, productId),
                child: const Text("Tambah ke Keranjang"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
