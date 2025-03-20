// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class FavoriteScreen extends StatelessWidget {
  final List<Map<String, String>> favoriteItems = [
    {'name': 'Produk A', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Produk B', 'image': 'https://via.placeholder.com/150'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorit Saya")),
      body: favoriteItems.isEmpty
          ? const Center(child: Text("Belum ada produk favorit"))
          : ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final item = favoriteItems[index];
                return ListTile(
                  leading: Image.network(item['image']!, width: 50),
                  title: Text(item['name']!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Tambahkan fungsi hapus favorit
                    },
                  ),
                );
              },
            ),
    );
  }
}
