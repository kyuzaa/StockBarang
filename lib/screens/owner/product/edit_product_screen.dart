import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

class EditProductScreen extends StatefulWidget {
  final String productId;

  const EditProductScreen({super.key, required this.productId});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool _isActive = true;
  File? _image;
  String? _existingImagePath;

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    DocumentSnapshot productSnapshot = await FirebaseFirestore.instance.collection("products").doc(widget.productId).get();

    if (productSnapshot.exists) {
      Map<String, dynamic> data = productSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _nameController.text = data["name"];
        _priceController.text = data["price"].toString();
        _stockController.text = data["stock"].toString();
        _descController.text = data["description"];
        _categoryController.text = data["category"];
        _isActive = data["status"];
        _existingImagePath = data["imageUrl"];
      });
    }
  }

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

  Future<void> _updateProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap isi semua field")));
      return;
    }

    String imagePath = _image?.path ?? _existingImagePath ?? "";

    await FirebaseFirestore.instance.collection("products").doc(widget.productId).update({
      "name": _nameController.text,
      "price": int.parse(_priceController.text),
      "stock": int.parse(_stockController.text),
      "description": _descController.text,
      "category": _categoryController.text,
      "status": _isActive,
      "imageUrl": imagePath,
      "updatedAt": Timestamp.now(),
    });

    Navigator.pop(context);
  }

  Future<void> _deleteProduct() async {
    await FirebaseFirestore.instance.collection("products").doc(widget.productId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Produk")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : (_existingImagePath != null && _existingImagePath!.isNotEmpty
                        ? Image.file(File(_existingImagePath!), fit: BoxFit.cover)
                        : const Icon(Icons.add_a_photo, size: 50)),
              ),
            ),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Nama Produk")),
            TextField(controller: _priceController, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
            TextField(controller: _stockController, decoration: const InputDecoration(labelText: "Stok"), keyboardType: TextInputType.number),
            TextField(controller: _descController, decoration: const InputDecoration(labelText: "Deskripsi")),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: "Kategori")),
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
            ElevatedButton(onPressed: _updateProduct, child: const Text("Simpan Perubahan")),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _deleteProduct,
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Hapus Produk"),
            ),
          ],
        ),
      ),
    );
  }
}
