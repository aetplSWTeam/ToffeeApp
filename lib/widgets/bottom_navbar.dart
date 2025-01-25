import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/account_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  _BottomNavbarState createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  int _currentIndex = 1;
  bool _isUserLoggedIn = false;  // Boolean flag to track user status
  bool _isEmailVerified = false; // Flag for email verification

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Fetch current user from Firebase and update flags
  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      if (user != null) {
        _isUserLoggedIn = true;
        _isEmailVerified = user.emailVerified;
      } else {
        _isUserLoggedIn = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUserLoggedIn) {
      // Show loading state or login prompt if not logged in
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Screens list with a condition for the DashboardScreen
    final List<Widget> screens = [
       _isEmailVerified
          ? const DashboardScreen()
          : const Center(
              child: Text(
                'Please confirm your email to access the dashboard.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
      const HomeScreen(),
     
      const AccountScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1 && !_isEmailVerified) {
            // Show a pop-up message if the user tries to access the dashboard
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Email Verification Required'),
                content: const Text(
                    'Please confirm your email address to access the dashboard.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        items: const [
          
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
