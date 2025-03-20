import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _nameController = TextEditingController(text: authProvider.userName);
    _phoneController = TextEditingController(text: authProvider.userPhone);
    _addressController = TextEditingController(text: authProvider.userAddress);
  }

  Future<void> _logout(BuildContext context) async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
          _nameController.text, _phoneController.text, _addressController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil berhasil diperbarui")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Profil Saya")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  await authProvider.uploadProfilePhoto();
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: authProvider.userPhoto.startsWith('/')
                          ? FileImage(File(authProvider.userPhoto)) as ImageProvider
                          : AssetImage(authProvider.userPhoto),
                    ),
                    const CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.camera_alt, size: 15, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _logout(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Logout", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
