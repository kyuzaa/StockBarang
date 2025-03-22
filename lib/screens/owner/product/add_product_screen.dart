import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pos/screens/owner/dashboard_screen.dart';

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
  Uint8List? _imageBytes;

  final List<String> _categories = [
    'Bahan Pokok', 'Minuman', 'Alat Mandi', 'Makanan Ringan',
    'Alat Kebersihan', 'Alat Tulis', 'Obat'
  ];

  final NumberFormat currencyFormat = NumberFormat("#,###", "id_ID");

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    print(pickedFile);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  void _formatPrice(String value) {
    String newValue = value.replaceAll(RegExp(r'[^\d]'), ''); // Hanya angka
    if (newValue.isNotEmpty) {
      double parsed = double.parse(newValue);
      _priceController.value = TextEditingValue(
        text: currencyFormat.format(parsed), // Format sebagai Rupiah
        selection: TextSelection.collapsed(offset: currencyFormat.format(parsed).length),
      );
    }
  }

  Future<String?> _uploadToFlask(Uint8List imageBytes) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://174.138.31.117:5000/upload"), // atau "https://your-domain.com/upload"
    );
    
    String formattedCategory = _selectedCategory!.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '-');
    String formattedName = _nameController.text.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '-');
    String fileName = "$formattedCategory-$formattedName.jpg";
    request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: fileName));

    var response = await request.send();
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(await response.stream.bytesToString());
      return jsonResponse['image_url'];
    } else {
      return null;
    }
  }

  Future<String?> _uploadToImgBB(Uint8List imageBytes) async {
    if (_selectedCategory == null || _nameController.text.isEmpty) {
      return null;
    }

    String formattedCategory = _selectedCategory!.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '-');
    String formattedName = _nameController.text.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '-');
    String fileName = "$formattedCategory-$formattedName.jpg";
    print(fileName);

    String apiKey = "ad3ec51569161f45a269c56875f60d58"; // Ganti dengan API Key ImgBB
    Uri uri = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    var request = http.MultipartRequest('POST', uri);
    request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: fileName));

    var response = await request.send();
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(await response.stream.bytesToString());
      print(jsonResponse);
      return jsonResponse['data']['url']; // Dapatkan URL gambar
    } else {
      return null; // Jika gagal upload
    }
  }


  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua field"), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mengunggah gambar..."), backgroundColor: Colors.blue),
    );

    int priceValue = int.parse(_priceController.text.replaceAll('.', ''));
    String? imageUrl = await _uploadToFlask(_imageBytes!);
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengunggah gambar"), backgroundColor: Colors.red),
      );
      return;
    }

    await FirebaseFirestore.instance.collection("products").add({
      "name": _nameController.text,
      "price": priceValue,
      "stock": int.parse(_stockController.text),
      "description": _descController.text,
      "category": _selectedCategory,
      "status": _isActive,
      "imageUrl": imageUrl,
      "createdAt": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil ditambahkan!"), backgroundColor: Colors.green),
    );

    // Redirect ke DashboardScreen setelah berhasil tambah produk
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Tambah Produk", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        elevation: 6,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 20),
            _buildForm(),
            const SizedBox(height: 20),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey[200]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              spreadRadius: 2,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: _imageBytes == null
            ? const Center(child: Icon(Icons.camera_alt, size: 60, color: Colors.deepPurple))
            : ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.memory(_imageBytes!, fit: BoxFit.cover, width: double.infinity, height: 200),
              ),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 8,
      shadowColor: Colors.blueAccent.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField("Nama Produk", _nameController),
            _buildTextField("Harga", _priceController, isNumber: true, onChanged: _formatPrice),
            _buildTextField("Stok", _stockController, isNumber: true),
            _buildTextField("Deskripsi", _descController, maxLines: 3),
            _buildDropdown(),
            _buildSwitch(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false, int maxLines = 1, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedCategory,
        decoration: InputDecoration(
          labelText: "Kategori",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        items: _categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() => _selectedCategory = newValue);
        },
      ),
    );
  }

  Widget _buildSwitch() {
    return SwitchListTile(
      title: const Text("Status Produk (Aktif/Tidak Aktif)"),
      value: _isActive,
      activeColor: Colors.blueAccent,
      onChanged: (bool value) => setState(() => _isActive = value),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton.icon(
      onPressed: _addProduct,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
      ),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      label: const Text("Tambah Produk", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}