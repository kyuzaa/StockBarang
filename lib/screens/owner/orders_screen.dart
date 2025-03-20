import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedStatus = '1'; // Default: Semua Pesanan
  String selectedDeliveryType = '1'; // Default: Ambil Sendiri
  List<String> selectedOrders = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Pesanan")),
      body: Column(
        children: [
          // Tab Filter Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatusTab("Semua", "1"),
                _buildStatusTab("Pesanan Baru", "2"),
                _buildStatusTab("Siap Dikirim", "3"),
                _buildStatusTab("Siap Diambil", "4"),
                _buildStatusTab("Selesai", "5"),
              ],
            ),
          ),

          // Jika status 'Selesai', munculkan sub-tab "Ambil Sendiri" & "Diantar"
          if (selectedStatus == '5')
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDeliveryTab("Ambil Sendiri", "1"),
                _buildDeliveryTab("Diantar", "2"),
              ],
            ),

          // List Pesanan
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
                  return const Center(child: Text("Belum ada pesanan"));
                }

                return Column(
                  children: [
                    // Total Harga
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Total Harga: Rp ${_calculateTotalPrice(orders)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        children: orders.map((order) {
                          var data = order.data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.all(8),
                            child: ListTile(
                              title: Text("Customer: ${data["id_cust"]}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${data["barang"].length} Produk"),
                                  Text("Total: Rp ${data["total_harga"]}"),
                                  Text("Jenis Pengiriman: ${data["jenis_pengiriman"] == "1" ? "Ambil Sendiri" : "Diantar"}"),
                                  Text("Tanggal: ${data["tanggal"]}"),
                                  Text("Status: ${_getStatusText(data["status"])}"),
                                ],
                              ),
                              trailing: _buildActionButton(order.id, data),
                            ),
                          );
                        }).toList(),
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

  // Fungsi untuk filter pesanan berdasarkan status & jenis_pengiriman
  bool _filterOrders(Map<String, dynamic> data) {
    if (selectedStatus == "1") return true; // Semua Pesanan
    if (selectedStatus == "2") return data["status"] == "2";
    if (selectedStatus == "3") return data["status"] == "3" && data["jenis_pengiriman"] == "2"; // Siap Dikirim (Diantar)
    if (selectedStatus == "4") return data["status"] == "4" && data["jenis_pengiriman"] == "1"; // Siap Diambil (Ambil Sendiri)
    if (selectedStatus == "5") return data["status"] == "5" && data["jenis_pengiriman"] == selectedDeliveryType;
    return false;
  }

  // Fungsi untuk menghitung total harga pesanan
  String _calculateTotalPrice(List<QueryDocumentSnapshot> orders) {
    int total = 0;
    for (var order in orders) {
      total += int.parse(order["total_harga"].toString());
    }
    return total.toString();
  }

  // Fungsi untuk menampilkan teks status
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

  // Fungsi untuk menampilkan tombol berdasarkan status pesanan
  Widget _buildActionButton(String orderId, Map<String, dynamic> data) {
    if (selectedStatus == "1") return const SizedBox(); // Tab "Semua" tidak ada tombol

    String buttonText = "";
    String newStatus = "";

    if (selectedStatus == "2") {
      buttonText = "Terima Pesanan";
      newStatus = data["jenis_pengiriman"] == "2" ? "3" : "4"; // Jika diantar -> 3, jika ambil sendiri -> 4
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
      onPressed: () => _updateOrderStatus(orderId, newStatus),
      child: Text(buttonText),
    );
  }

  // Fungsi untuk update status pesanan
  void _updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection("orders").doc(orderId).update({
      "status": newStatus,
    });
  }

  // Widget Status Tab
  Widget _buildStatusTab(String label, String status) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedStatus = status;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selectedStatus == status ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Widget Sub-tab Ambil Sendiri / Diantar
  Widget _buildDeliveryTab(String label, String type) {
    return TextButton(
      onPressed: () {
        setState(() {
          selectedDeliveryType = type;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          fontWeight: selectedDeliveryType == type ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
