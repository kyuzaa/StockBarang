import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos/providers/auth_provider.dart';
import 'package:pos/screens/owner/dashboard_screen.dart';
import 'package:pos/screens/customer/dashboard_screen.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<AuthProvider>(context, listen: false).checkLoginStatus());

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.user == null) {
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          });
        } else if (authProvider.role != null) {
          Future.delayed(Duration.zero, () {
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
          });
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(), // Loading indikator
          ),
        );
      },
    );
  }
}
