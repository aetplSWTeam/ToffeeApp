import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is null (not logged in)
    if (user == null) {
      return const Center(child: CircularProgressIndicator()); // Show loading or a message for logged out users
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display user's display name or 'User' if no display name
            Center(
              child: Text(
                'Welcome, ${user.displayName ?? 'User'}!',
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display user's email
            Center(
              child: Text(
                'Email: ${user.email}',
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Display if email is verified or not
            Center(
              child: Text(
                'Email Verified: ${user.emailVerified ? 'Yes' : 'No'}',
                style: TextStyle(
                  fontSize: 20,
                  color: user.emailVerified ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
