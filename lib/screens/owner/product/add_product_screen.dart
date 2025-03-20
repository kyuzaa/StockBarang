import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedCategory;
  bool _isActive = true;
  File? _image;

  final List<String> _categories = [
    'Bahan Pokok', 'Minuman', 'Alat Mandi', 'Makanan Ringan',
    'Alat Kebersihan', 'Alat Tulis', 'Obat'
  ];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final tempDir = await getApplicationDocumentsDirectory();
      final savedImage = File('${tempDir.path}/${path.basename(pickedFile.path)}');
      await File(pickedFile.path).copy(savedImage.path);

      setState(() {
        _image = savedImage;
      });
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua field")),
      );
      return;
    }

    String? imagePath;
    if (_image != null) {
      imagePath = _image!.path;
    }

    await FirebaseFirestore.instance.collection("products").add({
      "name": _nameController.text,
      "price": int.parse(_priceController.text),
      "stock": int.parse(_stockController.text),
      "description": _descController.text,
      "category": _selectedCategory,
      "status": _isActive,
      "imageUrl": imagePath, // Simpan path gambar lokal
      "createdAt": Timestamp.now(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Upload Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: _image == null
                    ? const Center(child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey))
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_image!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Nama Produk
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nama Produk",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Harga
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Harga",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            // Stok
            TextField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: "Stok",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 15),

            // Deskripsi
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 15),

            // Dropdown Kategori
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            const SizedBox(height: 15),

            // Status Produk
            SwitchListTile(
              title: const Text("Status Produk (Aktif/Tidak Aktif)"),
              value: _isActive,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Tombol Tambah Produk
            ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Tambah Produk", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
