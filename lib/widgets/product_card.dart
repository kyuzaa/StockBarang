import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ProductImage extends StatefulWidget {
  final String imageUrl;
  const ProductImage({super.key, required this.imageUrl});

  @override
  _ProductImageState createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  final bool _isError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
  try {
    final response = await http.get(Uri.parse(widget.imageUrl), headers: {
    "User-Agent": "Mozilla/5.0",
    "Accept": "image/*",
    'Accept-Encoding': 'gzip, deflate, br',
    "Connection": "Keep-Alive",
  },).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      setState(() {
        _imageBytes = response.bodyBytes;
        _isLoading = false;
      });
    } else {
      throw Exception("Gagal memuat gambar");
    }
  } catch (e) {
    print("Error loading image: $e");
    setState(() {
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: Container(width: double.infinity, height: 100, color: Colors.grey),
      );
    }

    if (_isError || _imageBytes == null) {
      return Image.asset(
        'assets/no_image.jpg',
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.memory(
      _imageBytes!,
      width: double.infinity,
      height: 100,
      fit: BoxFit.cover,
    );
  }
}

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap;
  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final bool isOutOfStock = product['stock'] == 0;

    return SizedBox(
      width: 150,
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Produk dengan ProductImage
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                child: ProductImage(imageUrl: product['imageUrl']),
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

              const Spacer(),

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
      ),
    );
  }
}
