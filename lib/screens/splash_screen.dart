import 'package:flutter/material.dart';
import '../screens/login_page.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a Future to navigate after 3 seconds
    Future.delayed(const Duration(seconds: 1), () {
      // Checking if the widget is still mounted before using context
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
      
    });

    return Scaffold(
      backgroundColor: Colors.purple,
      body: Center(
        child: Text(
          'Toffee App',
          style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
