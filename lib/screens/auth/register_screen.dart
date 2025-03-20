import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _currentStep = 0;

  final _personalFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void register() async {
    if (_accountFormKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.register(
        emailController.text,
        passwordController.text,
        usernameController.text,
        phoneController.text,
        addressController.text,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi berhasil! Silakan login")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registrasi gagal! Email / Username telah digunakan")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.blue.shade700,
        elevation: 5,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep == 0) {
                if (_personalFormKey.currentState!.validate()) {
                  setState(() => _currentStep++);
                }
              } else {
                register();
              }
            },
            onStepCancel: () {
              if (_currentStep == 0) {
                Navigator.pop(context);
              } else {
                setState(() => _currentStep--);
              }
            },
            steps: [
              Step(
                title: const Text("Informasi Personal"),
                content: Form(
                  key: _personalFormKey,
                  child: Column(
                    children: [
                      _buildTextField(nameController, "Nama", Icons.person),
                      _buildTextField(emailController, "Email", Icons.email, isEmail: true),
                      _buildTextField(phoneController, "No HP", Icons.phone),
                      _buildTextField(addressController, "Alamat", Icons.home),
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text("Akun"),
                content: Form(
                  key: _accountFormKey,
                  child: Column(
                    children: [
                      _buildTextField(usernameController, "Username", Icons.account_circle),
                      _buildPasswordField(passwordController, "Password"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        validator: (value) {
          if (value == null || value.isEmpty) return "$hint tidak boleh kosong";
          if (isEmail && !RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$').hasMatch(value)) {
            return "Masukkan email yang valid";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: hint,
          prefixIcon: Icon(Icons.lock, color: Colors.blue.shade700),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value == null || value.isEmpty ? "Password tidak boleh kosong" : null,
      ),
    );
  }
}