import 'dart:io';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user = FirebaseAuth.instance.currentUser;
  String? _role;
  String? _name;
  String? _email;
  String? _phone;
  String? _address;
  String? _photoPath;

  User? get user => _user;
  String? get role => _role;
  String get userName => _name ?? 'Nama Kosong';
  String get userEmail => _email ?? 'Email Kosong';
  String get userPhone => _phone ?? 'Belum Ada No HP';
  String get userAddress => _address ?? 'Belum Ada Alamat';
  String get userPhoto => _photoPath ?? 'assets/default_avatar.png';

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    _user = _auth.currentUser;
    if (_user != null) {
      await _fetchUserData();
    }
    notifyListeners();
  }

  Future<void> _fetchUserData() async {
    if (_user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _role = data['role'];
        _name = data['name'] ?? 'Nama Kosong';
        _email = data['email'] ?? 'Email Kosong';
        _phone = data['no_telp'] ?? 'Belum Ada No HP';
        _address = data['alamat'] ?? 'Belum Ada Alamat';
        _photoPath = data['photoPath'] ?? 'assets/default_avatar.png';
        notifyListeners();
      }
    }
  }

  // Update Profile
  Future<void> updateProfile(String name, String phone, String text) async {
    if (_user != null) {
      await _user!.updateDisplayName(name);
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        'phone': phone,
      });

      _user = _auth.currentUser;
      notifyListeners();
    }
  }

  // Upload Foto Profile ke Local Storage
  Future<void> uploadProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/profile_${_user!.uid}.jpg';
      final File localFile = File(pickedFile.path);

      await localFile.copy(filePath); // Simpan gambar di storage lokal

      _photoPath = filePath;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name, String notelp, String alamat) async {
    _user = await _authService.register(email, password, name, notelp, alamat, 'Customer');
    if (_user != null) {
      _role = role;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Login
  Future<bool> login(String email, String password) async {
    final result = await _authService.login(email, password);
    _user = result['user'];
    _role = result['role'];
    
    notifyListeners();
    return _user != null;
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
    _user = null;
    _name = null;
    _email = null;
    _phone = null;
    _address = null;
    _photoPath = null;
    notifyListeners();
  }
}
