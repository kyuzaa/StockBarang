import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos/providers/auth_provider.dart';
import 'package:pos/screens/auth/login_screen.dart'; // Import halaman login
import 'orders_screen.dart';
import 'products_screen.dart';
import 'product/add_product_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  int _selectedIndex = 0;
  bool _isSidebarVisible = true; // State untuk menampilkan/menyembunyikan sidebar

  final List<Widget> _pages = [
    const OrdersScreen(),
    const ProductsScreen(),
    const AddProductScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible; // Toggle visibilitas sidebar
    });
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog

              try {
                // Panggil logout dari AuthProvider
                await Provider.of<AuthProvider>(context, listen: false).logout();

                // Arahkan user ke halaman login & hapus history navigasi
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gagal logout: ${e.toString()}")),
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Owner"),
        leading: IconButton(
          icon: Icon(_isSidebarVisible ? Icons.menu_open : Icons.menu),
          onPressed: _toggleSidebar,
        ),
      ),
      body: Row(
        children: [
          if (_isSidebarVisible)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.list),
                  selectedIcon: Icon(Icons.list, color: Colors.blue),
                  label: Text("Daftar Pesanan"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.shopping_bag),
                  selectedIcon: Icon(Icons.shopping_bag, color: Colors.blue),
                  label: Text("Daftar Produk"),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.add),
                  selectedIcon: Icon(Icons.add, color: Colors.blue),
                  label: Text("Tambah Produk"),
                ),
              ],
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: _logout,
                  ),
                  const Text("Logout", style: TextStyle(color: Colors.red)),
                ],
              ),
            ),

          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }
}
