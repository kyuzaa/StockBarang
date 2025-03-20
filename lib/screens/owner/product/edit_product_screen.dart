import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
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
      appBar: AppBar(
        title: const Text("Edit Produk"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : (_existingImagePath != null && _existingImagePath!.isNotEmpty
                      ? FileImage(File(_existingImagePath!))
                      : null),
                  child: _image == null && _existingImagePath == null ? const Icon(Icons.camera_alt, size: 40) : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, "Nama Produk"),
            _buildTextField(_priceController, "Harga", TextInputType.number),
            _buildTextField(_stockController, "Stok", TextInputType.number),
            _buildTextField(_descController, "Deskripsi"),
            _buildTextField(_categoryController, "Kategori"),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text("Simpan", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _deleteProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text("Hapus", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
