import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedStatus = '1';
  String selectedDeliveryType = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pesanan"),
      ),
      body: Column(
        children: [
          // Status Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 8,
                children: [
                  _buildStatusTab("Semua", "1"),
                  _buildStatusTab("Pesanan Baru", "2"),
                  _buildStatusTab("Siap Dikirim", "3"),
                  _buildStatusTab("Siap Diambil", "4"),
                  _buildStatusTab("Selesai", "5"),
                ],
              ),
            ),
          ),

          if (selectedStatus == '5')
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDeliveryTab("Ambil Sendiri", "1"),
                  _buildDeliveryTab("Diantar", "2"),
                ],
              ),
            ),

          // Orders List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("orders").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Belum ada pesanan"));
                }

                var orders = snapshot.data!.docs
                    .where((order) => _filterOrders(order.data() as Map<String, dynamic>))
                    .toList();

                if (orders.isEmpty) {
                  return const Center(child: Text("Tidak ada pesanan untuk filter ini"));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        "Total Harga: Rp ${_calculateTotalPrice(orders)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          var order = orders[index];
                          var data = order.data() as Map<String, dynamic>;

                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(data["userId"])
                                .get(),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: LinearProgressIndicator(),
                                );
                              }

                              var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                              String customerName = userData["name"] ?? "Nama Tidak Ditemukan";

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                elevation: 3,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          customerName,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        subtitle: Text("${data["items"].length} Produk"),
                                        trailing: _buildActionButton(order.id, data),
                                      ),
                                      const Divider(),
                                      Text("Total: Rp ${data["total_harga"]}"),
                                      Text("Jenis Pengiriman: ${data["metode_pengiriman"] == "1" ? "Ambil Sendiri" : "Diantar"}"),
                                      Text("Alamat: ${data["alamat"]}"),
                                      Text("Tanggal: ${_formatDate(data["createdAt"])}"),
                                      Text("Status: ${_getStatusText(data["status"])}"),
                                      const SizedBox(height: 8),
                                      ..._buildProductItems(data["items"]),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // === Utility Functions ===

  bool _filterOrders(Map<String, dynamic> data) {
    if (selectedStatus == "1") return true;
    if (selectedStatus == "2") return data["status"] == "1";
    if (selectedStatus == "3") return data["status"] == "3" && data["metode_pengiriman"] == "2";
    if (selectedStatus == "4") return data["status"] == "4" && data["metode_pengiriman"] == "1";
    if (selectedStatus == "5") return data["status"] == "5" && data["metode_pengiriman"] == selectedDeliveryType;
    return false;
  }

  String _calculateTotalPrice(List<QueryDocumentSnapshot> orders) {
    int total = 0;
    for (var order in orders) {
      total += int.parse(order["total_harga"].toString());
    }
    return total.toString();
  }

  String _getStatusText(String status) {
    switch (status) {
      case "2":
        return "Pesanan Baru";
      case "3":
        return "Siap Dikirim";
      case "4":
        return "Siap Diambil";
      case "5":
        return "Selesai";
      default:
        return "Menunggu";
    }
  }

  Widget _buildActionButton(String orderId, Map<String, dynamic> data) {
    if (selectedStatus == "1") return const SizedBox();

    String buttonText = "";
    String newStatus = "";

    if (selectedStatus == "2") {
      buttonText = "Terima Pesanan";
      newStatus = data["metode_pengiriman"] == "2" ? "3" : "4";
    } else if (selectedStatus == "3") {
      buttonText = "Kirim Pesanan";
      newStatus = "5";
    } else if (selectedStatus == "4") {
      buttonText = "Pesanan Siap Diambil";
      newStatus = "5";
    } else {
      return const SizedBox();
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () => _updateOrderStatus(orderId, newStatus),
      child: Text(buttonText, style: const TextStyle(color: Colors.white)),
    );
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection("orders").doc(orderId).update({
      "status": newStatus,
    });
  }

  Widget _buildStatusTab(String label, String status) {
    bool isSelected = selectedStatus == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      onSelected: (_) {
        setState(() {
          selectedStatus = status;
        });
      },
    );
  }

  Widget _buildDeliveryTab(String label, String type) {
    bool isSelected = selectedDeliveryType == type;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Colors.teal.shade300,
        onSelected: (_) {
          setState(() {
            selectedDeliveryType = type;
          });
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    return DateFormat('dd MMM yyyy • HH:mm').format(date);
  }

  List<Widget> _buildProductItems(List<dynamic> items) {
    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['name'] ?? 'Produk', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text("Harga: Rp ${item['price']}"),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
