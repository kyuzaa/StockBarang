import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [
    {'name': 'Produk A', 'image': 'https://via.placeholder.com/150', 'price': 50000, 'quantity': 1},
    {'name': 'Produk B', 'image': 'https://via.placeholder.com/150', 'price': 30000, 'quantity': 1},
  ];

  List<Map<String, dynamic>> favoriteItems = [
    {'name': 'Produk C', 'image': 'https://via.placeholder.com/150', 'price': 40000},
    {'name': 'Produk D', 'image': 'https://via.placeholder.com/150', 'price': 60000},
  ];

  bool isFavoriteVisible = true;

  int getTotalPrice() {
    return cartItems.fold<int>(0, (int sum, item) => sum + ((item['price'] as num) * (item['quantity'] as num)).toInt());
  }

  void updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]['quantity'] += change;
      if (cartItems[index]['quantity'] <= 0) cartItems.removeAt(index);
    });
  }

  void addToCart(Map<String, dynamic> item) {
    setState(() {
      cartItems.add({'name': item['name'], 'image': item['image'], 'price': item['price'], 'quantity': 1});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Keranjang",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Keranjang kosong"))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(item['image'], width: 70, height: 70, fit: BoxFit.cover),
                          ),
                          title: Text(item['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          subtitle: Text("Rp ${item['price']}",
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.blue.shade700)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => updateQuantity(index, -1),
                              ),
                              Text("${item['quantity']}", style: GoogleFonts.poppins(fontSize: 18)),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () => updateQuantity(index, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Text("Total: Rp ${getTotalPrice()}",
                    style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.blue.shade700,
                  ),
                  onPressed: () {},
                  child: const Text("Checkout", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => isFavoriteVisible = !isFavoriteVisible),
            child: Container(
              color: Colors.blue.shade100,
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Produk Favorit", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(isFavoriteVisible ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isFavoriteVisible ? 150 : 0,
            child: isFavoriteVisible
                ? ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favoriteItems.length,
                    itemBuilder: (context, index) {
                      final item = favoriteItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 3,
                        child: Container(
                          width: 140,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(item['image'], height: 60, fit: BoxFit.cover),
                              ),
                              Text(item['name'], style: GoogleFonts.poppins(fontSize: 14)),
                              Text("Rp ${item['price']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () => addToCart(item),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  backgroundColor: Colors.green.shade700,
                                ),
                                child: const Text("Tambah", style: TextStyle(color: Colors.white, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : null,
          ),
        ],
      ),
    );
  }
}