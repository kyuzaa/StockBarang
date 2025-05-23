import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  String get userPhoto => _photoPath ?? 'assets/default_avatar.jpg';

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
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
        _photoPath = data['photoPath'] ?? 'assets/default_avatar.jpg';
        notifyListeners();
      }
    }
  }

  // Update Profile
  Future<String?> uploadProfilePhotoToFlask(Uint8List imageBytes) async {
    if (_user == null) return null;

    String formattedName = _user!.displayName!.replaceAll(RegExp(r'[^\w\s]'), '').replaceAll(' ', '-');
    String fileName = "$formattedName.jpg";

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://174.138.31.117:5000/upload"),
    );

    request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: fileName));

    var response = await request.send();
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(await response.stream.bytesToString());
      return jsonResponse['image_url'];
    } else {
      return null;
    }
  }

  Future<void> updateProfile(String name, String phone, String address, String? imageUrl) async {
    if (_user != null) {
      await _user!.updateDisplayName(name);
      await _firestore.collection('users').doc(_user!.uid).update({
        'name': name,
        'phone': phone,
        'alamat': address,
        if (imageUrl != null) 'photoPath': imageUrl,
      });

      _name = name;
      _phone = phone;
      _address = address;
      if (imageUrl != null) _photoPath = imageUrl;
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
