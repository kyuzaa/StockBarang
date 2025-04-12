import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  late CollectionReference cartRef;
  String selectedDelivery = "1"; // '1' untuk Ambil Sendiri, '2' untuk Diantar
  String userAddress = "Alamat belum diatur";

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      cartRef = FirebaseFirestore.instance
          .collection('cart')
          .doc(user!.uid)
          .collection('items');
      _fetchUserAddress();
    }
  }

  Future<void> _fetchUserAddress() async {
    if (user == null) return;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    setState(() {
      userAddress = userDoc.exists ? (userDoc["alamat"] ?? "Alamat belum diatur") : "Alamat belum diatur";
    });
  }

  Future<void> updateQuantity(String docId, int change, int currentQuantity) async {
    if (currentQuantity + change <= 0) {
      await cartRef.doc(docId).delete();
    } else {
      await cartRef.doc(docId).update({'quantity': currentQuantity + change});
    }
  }

  int calculateTotalPrice(List<QueryDocumentSnapshot> cartItems) {
    return cartItems.fold<int>(0, (sum, item) {
      return sum + ((item['price'] as num) * (item['quantity'] as num)).toInt();
    });
  }

  String formatRupiah(int amount) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return format.format(amount);
  }

  void _showCheckoutDialog(List<QueryDocumentSnapshot> cartItems, int totalPrice) {
    String localSelectedDelivery = selectedDelivery;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Checkout"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Alamat: $userAddress"),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: localSelectedDelivery,
                      items: const [
                        DropdownMenuItem(value: "1", child: Text("Ambil Sendiri")),
                        DropdownMenuItem(value: "2", child: Text("Diantar")),
                      ],
                      onChanged: (value) {
                        setStateDialog(() {
                          localSelectedDelivery = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ...cartItems.map((item) => ListTile(
                          leading: Image.network(item['image'], width: 40, height: 40, fit: BoxFit.cover),
                          title: Text(item['name']),
                          subtitle: Text("${item['quantity']} x ${formatRupiah(item['price'])}"),
                        )),
                    const SizedBox(height: 10),
                    Text("Total: ${formatRupiah(totalPrice)}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDelivery = localSelectedDelivery; // Update ke state utama
                    });
                    _processCheckout(cartItems, totalPrice);
                  },
                  child: const Text("Proses Checkout"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _processCheckout(List<QueryDocumentSnapshot> cartItems, int totalPrice) async {
    if (user == null) return;

    List<Map<String, dynamic>> orderItems = cartItems.map((item) {
      return {
        "name": item["name"],
        "price": item["price"],
        "quantity": item["quantity"],
        "image": item["image"],
        "productId": item["id"],
      };
    }).toList();

    await FirebaseFirestore.instance.collection("orders").add({
      "userId": user!.uid,
      "items": orderItems,
      "total_harga": totalPrice,
      "metode_pengiriman": selectedDelivery,  // Menggunakan angka '1' atau '2'
      "alamat": userAddress,
      "createdAt": FieldValue.serverTimestamp(),
      "status": '1'
    });

    // Hapus isi keranjang setelah checkout
    for (var item in cartItems) {
      String productId = item["id"];
      int quantityPurchased = item["quantity"];
      DocumentReference productRef = FirebaseFirestore.instance.collection("products").doc(productId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(productRef);
        if (snapshot.exists) {
          int currentStock = snapshot["stock"];
          int newStock = currentStock - quantityPurchased;
          transaction.update(productRef, {"stock": newStock});
        }
      });
      await cartRef.doc(item.id).delete();
    }

    Navigator.pop(context); // Tutup popup
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pesanan berhasil dibuat!")));
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
        stream: cartRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var cartItems = snapshot.data!.docs;
          int totalPrice = calculateTotalPrice(cartItems);

          return Column(
            children: [
              Expanded(
                child: cartItems.isEmpty
                    ? const Center(child: Text("Keranjang kosong"))
                    : ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          var item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
                              ),
                              title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(formatRupiah(item['price'])),
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
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Column(
                  children: [
                    Text(
                      "Total Belanja: ${formatRupiah(totalPrice)}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: cartItems.isEmpty ? null : () => _showCheckoutDialog(cartItems, totalPrice),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                      ),
                      child: const Text("Checkout", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
