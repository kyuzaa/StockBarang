import 'package:flutter/material.dart';
import 'package:pos/screens/customer/dashboard_screen.dart';
import 'package:pos/screens/owner/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:pos/providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key untuk validasi
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; // Untuk menampilkan loading saat login

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (authProvider.role == 'Owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const OwnerDashboardScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomerDashboardScreen()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login gagal! Periksa email dan password Anda.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey, // Gunakan form key untuk validasi
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Login", style: Theme.of(context).textTheme.headlineMedium),

                const SizedBox(height: 20),

                // Input Email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email tidak boleh kosong!";
                    }
                    if (!RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                        .hasMatch(value)) {
                      return "Masukkan email yang valid!";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                // Input Password
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password tidak boleh kosong!";
                    }
                    if (value.length < 6) {
                      return "Password minimal 6 karakter!";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Tombol Login dengan indikator loading
                ElevatedButton(
                  onPressed: _isLoading ? null : login, // Disable saat loading
                  child: _isLoading
                      ? const CircularProgressIndicator() // Tampilkan loading saat login
                      : const Text("Login"),
                ),

                // Tombol Daftar
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                  },
                  child: const Text("Belum punya akun? Daftar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
