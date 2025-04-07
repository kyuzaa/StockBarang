import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pos/screens/owner/dashboard_screen.dart';

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
  String _selectedCategory = "Makanan"; // Default category
  
  bool _isActive = true;
  Uint8List? _imageBytes;
  String? _existingImageUrl;

  final List<String> _categories = [
    'Bahan Pokok', 'Minuman', 'Alat Mandi', 'Makanan Ringan',
    'Alat Kebersihan', 'Alat Tulis', 'Obat'
  ];

  final NumberFormat currencyFormat = NumberFormat.currency(locale: "id_ID", symbol: "Rp ", decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    DocumentSnapshot productSnapshot =
        await FirebaseFirestore.instance.collection("products").doc(widget.productId).get();

    if (productSnapshot.exists) {
      Map<String, dynamic> data = productSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _nameController.text = data["name"];
        _priceController.text = currencyFormat.format(data["price"]);
        _stockController.text = data["stock"].toString();
        _descController.text = data["description"];
        _selectedCategory = data["category"] ?? "Makanan";
        _isActive = data["status"];
        _existingImageUrl = data["imageUrl"];
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
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
      Uri.parse("http://174.138.31.117:5000/upload"),
    );

    String formattedCategory = _selectedCategory.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '-');
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

  Future<void> _updateProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua field"), backgroundColor: Colors.red),
      );
      return;
    }

    int priceValue = int.parse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    String? imageUrl = _existingImageUrl; // Gunakan gambar lama jika tidak ada gambar baru

    if (_imageBytes != null) {
      imageUrl = await _uploadToFlask(_imageBytes!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mengunggah gambar"), backgroundColor: Colors.red),
        );
        return;
      }
    }

    await FirebaseFirestore.instance.collection("products").doc(widget.productId).update({
      "name": _nameController.text,
      "price": priceValue,
      "stock": int.parse(_stockController.text),
      "description": _descController.text,
      "category": _selectedCategory,
      "status": _isActive,
      "imageUrl": imageUrl,
      "updatedAt": Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Produk berhasil diubah!"), backgroundColor: Colors.green),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
      );
    });
  }

 // Hanya bagian dalam `build` yang diubah untuk keseragaman UI

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Edit Produk"),
      centerTitle: true,
      elevation: 0,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                image: _imageBytes != null
                    ? DecorationImage(image: MemoryImage(_imageBytes!), fit: BoxFit.cover)
                    : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                        ? DecorationImage(image: NetworkImage(_existingImageUrl!), fit: BoxFit.cover)
                        : null),
              ),
              child: _imageBytes == null && _existingImageUrl == null
                  ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                  : null,
            ),
          ),
          const SizedBox(height: 25),

          _buildLabel("Nama Produk"),
          _buildTextField(_nameController),

          _buildLabel("Harga Produk"),
          _buildTextField(_priceController, TextInputType.number, _formatPrice),

          _buildLabel("Jumlah Stok"),
          _buildTextField(_stockController, TextInputType.number),

          _buildLabel("Deskripsi Produk"),
          _buildTextField(_descController),

          _buildLabel("Kategori Produk"),
          _buildDropdownCategory(),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text("Status Produk (Aktif/Tidak Aktif)"),
            value: _isActive,
            onChanged: (bool value) {
              setState(() {
                _isActive = value;
              });
            },
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updateProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Simpan", style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildLabel(String text) {
  return Container(
    alignment: Alignment.centerLeft,
    margin: const EdgeInsets.only(top: 15, bottom: 5),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
  );
}

Widget _buildTextField(TextEditingController controller,
    [TextInputType keyboardType = TextInputType.text, Function(String)? onChanged]) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    onChanged: onChanged,
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

Widget _buildDropdownCategory() {
  return DropdownButtonFormField<String>(
    value: _selectedCategory,
    decoration: InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    items: _categories.map((String category) {
      return DropdownMenuItem<String>(
        value: category,
        child: Text(category),
      );
    }).toList(),
    onChanged: (value) => setState(() => _selectedCategory = value!),
  );
}

}
