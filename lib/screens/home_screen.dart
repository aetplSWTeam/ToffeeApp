import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toffee/screens/calender_page.dart';
import 'package:toffee/screens/manual_toffee_screen.dart';
import 'package:toffee/screens/toffee_screen.dart';
import '../services/purchase_service.dart'; // Import the service class

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the current user from Firebase
    User? user = FirebaseAuth.instance.currentUser;

    // Check if the user is null (not logged in)
    if (user == null) {
      return const Center(
          child:
              CircularProgressIndicator()); // Show loading or a message for logged-out users
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.deepPurple, // Elegant background color for AppBar
        leading: CircleAvatar(
          backgroundImage: user.photoURL != null
              ? NetworkImage(
                  user.photoURL!) // Use photoUrl from Firebase if available
              : const AssetImage('lib/assets/images/profile.png')
                  as ImageProvider, // Default image if photoUrl is null
          radius: 25,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder<int>(
              future: PurchaseService().fetchToffeeCount(
                  user.uid), // Pass user.uid to the service method
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                // Get toffee count from the snapshot
                int toffeeCount = snapshot.data ?? 0;

                return Center(
                  child: Text(
                    'Toffee: $toffeeCount', // Display toffee count
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(
                  8.0), // Add padding to create space around the icon
              decoration: BoxDecoration(
                color: Colors.white, // Set the background color
                shape: BoxShape.circle, // Make the background round
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                        0.2), // Slight shadow for a floating effect
                    spreadRadius: 2,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.notifications,
                  color: Colors.deepPurple), // Notification icon with color
            ),
            onPressed: () {
              // Handle notification icon tap (e.g., navigate to a notification page)
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Notifications'),
                    content: const Text('You have no new notifications.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildGreetingCard('       Back, ${user.displayName ?? 'User'}!'),
            const SizedBox(height: 20),
            _buildOptionCard('Add Payment Method', Colors.blueAccent, context),
            const SizedBox(height: 20),
            _buildOptionCard('Toffee', Colors.greenAccent, context),
            const SizedBox(height: 20),
            _buildOptionCard('Calendar', Colors.orangeAccent, context),
            const SizedBox(height: 20),
            _buildOptionCard('Add Toffee Manually', Colors.pinkAccent, context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Greeting card with user's name
  Widget _buildGreetingCard(String greetingText) {
    return Card(
      elevation: 5,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            greetingText,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ),
    );
  }

  // Option card to navigate to other pages (Toffee, Calendar, etc.)
  Widget _buildOptionCard(String title, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Toffee') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ToffeeScreen()),
          );
        } else if (title == 'Calendar') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CalendarScreen()),
          );
        } else if (title == 'Add Payment Method') {
          // Add your logic for payment method screen here
        } else if (title == 'Add Toffee Manually') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ManuallyAddToffeeScreen()));
        }
      },
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
