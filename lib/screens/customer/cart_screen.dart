import 'package:flutter/material.dart';

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

  int getTotalPrice() {
    return cartItems.fold<int>(0, (int sum, item) {
      int price = (item['price'] as num).toInt();  
      int quantity = (item['quantity'] as num).toInt();  
      return sum + (price * quantity);
    });
  }

  void updateQuantity(int index, int change) {
    setState(() {
      cartItems[index]['quantity'] += change;
      if (cartItems[index]['quantity'] <= 0) cartItems.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Keranjang Belanja")),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Keranjang kosong"))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        leading: Image.network(item['image'], width: 50),
                        title: Text(item['name']),
                        subtitle: Text("Rp ${item['price']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => updateQuantity(index, -1),
                            ),
                            Text("${item['quantity']}"),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => updateQuantity(index, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("Total: Rp ${getTotalPrice()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Tambahkan navigasi ke halaman checkout
                  },
                  child: const Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
