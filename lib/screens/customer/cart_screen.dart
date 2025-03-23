import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late CollectionReference cartItemsRef;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      cartItemsRef = FirebaseFirestore.instance.collection('cart').doc(user!.uid).collection('items');
    }
  }

  Future<void> updateQuantity(String docId, int change, int currentQuantity) async {
    if (currentQuantity + change <= 0) {
      await cartItemsRef.doc(docId).delete();
    } else {
      await cartItemsRef.doc(docId).update({'quantity': currentQuantity + change});
    }
  }

  int calculateTotalPrice(List<QueryDocumentSnapshot> cartItems) {
    return cartItems.fold<int>(0, (sum, item) {
      return sum + ((item['price'] as num) * (item['quantity'] as num)).toInt();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Keranjang")),
        body: const Center(child: Text("Silakan login untuk melihat keranjang")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Keranjang"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: StreamBuilder(
        stream: cartItemsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var cartItems = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text("Keranjang kosong"))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var item = cartItems[index];
                          return ListTile(
                            leading: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
                            title: Text(item['name']),
                            subtitle: Text("Rp ${item['price']} x ${item['quantity']}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () => updateQuantity(item.id, -1, item['quantity']),
                                ),
                                Text("${item['quantity']}"),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () => updateQuantity(item.id, 1, item['quantity']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: cartItems.isEmpty ? null : () {}, // Tambahkan fungsi checkout nanti
                  child: Text("Checkout - Rp ${calculateTotalPrice(cartItems)}"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
