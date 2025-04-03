import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos/providers/auth_provider.dart';
import 'package:pos/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  Uint8List? _selectedImage;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.userName);
    _phoneController = TextEditingController(text: authProvider.userPhone);
    _addressController = TextEditingController(text: authProvider.userAddress);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();
      setState(() {
        _selectedImage = imageBytes;
      });
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await authProvider.uploadProfilePhotoToFlask(_selectedImage!);
      }
      print(imageUrl);

      await authProvider.updateProfile(
        _nameController.text,
        _phoneController.text,
        _addressController.text,
        imageUrl,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? MemoryImage(_selectedImage!)
                        : authProvider.userPhoto.startsWith("http")
                            ? NetworkImage(authProvider.userPhoto) as ImageProvider
                            : AssetImage(authProvider.userPhoto),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Nama"),
                        validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: "No HP"),
                        validator: (value) => value!.isEmpty ? "No HP tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: "Alamat"),
                        validator: (value) => value!.isEmpty ? "Alamat tidak boleh kosong" : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _updateProfile(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Logout", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
