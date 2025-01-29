import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:image_picker/image_picker.dart'; // For profile picture picking
import 'package:firebase_storage/firebase_storage.dart'; // For storing the image in Firebase Storage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _profilePicUrl = ""; // Store the profile picture URL
  bool _isEditingName = false;
  bool _isEditingPhone = false;

  @override
  void initState() {
    super.initState();
    _getUserProfile();
  }

  // Fetch user details
  void _getUserProfile() {
    final user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
      _profilePicUrl = user.photoURL ?? ''; // Get profile picture URL
    }
  }

  // Update the _updateProfilePicture method
  Future<void> _updateProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final file = File(pickedFile.path); // Convert pickedFile.path to File object

        // Show loading indicator
        showDialog(
          context: context,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_pictures/${_auth.currentUser!.uid}.jpg');
        await storageRef.putFile(file); // Upload the file to Firebase Storage

        // Get the download URL
        String downloadUrl = await storageRef.getDownloadURL();
        setState(() {
          _profilePicUrl = downloadUrl;
        });

        // Update Firebase profile picture URL
        await _auth.currentUser!.updateProfile(photoURL: downloadUrl);

        // Close the loading indicator
        Navigator.pop(context);
      } else {
        // Handle case when no image is selected
        Navigator.pop(context);
        print('No image selected');
      }
    } catch (e) {
      Navigator.pop(context); // Close the loading indicator
      print('Error updating profile picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile picture')),
      );
    }
  }

  // Save updated profile information
  Future<void> _saveProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Update the user's display name and phone number
        await user.updateProfile(displayName: _nameController.text);
        await user.reload();
        setState(() {
          _isEditingName = false;
          _isEditingPhone = false;
        });
      } catch (e) {
        print('Error saving profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.deepPurpleAccent, // Adjust color as needed
      ),
      body: user == null
          ? const Center(
              child: Text('No user logged in.'),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile picture section
                  GestureDetector(
                    onTap: _updateProfilePicture,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _profilePicUrl.isNotEmpty ? NetworkImage(_profilePicUrl) : null,
                      child: _profilePicUrl.isEmpty
                          ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Display name section
                  Row(
                    children: [
                      const Text(
                        'Name: ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      _isEditingName
                          ? Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: const InputDecoration(hintText: 'Enter your name'),
                              ),
                            )
                          : Expanded(
                              child: Text(
                                user.displayName ?? 'No name set',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                      IconButton(
                        icon: Icon(
                          _isEditingName ? Icons.save : Icons.edit,
                          color: Colors.deepPurpleAccent, 
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditingName = !_isEditingName;
                            if (!_isEditingName) {
                              _saveProfile();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Phone number section
                  Row(
                    children: [
                      const Text(
                        'Phone Number: ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      _isEditingPhone
                          ? Expanded(
                              child: TextField(
                                controller: _phoneController,
                                decoration: const InputDecoration(hintText: 'Enter phone number'),
                              ),
                            )
                          : Expanded(
                              child: Text(
                                user.phoneNumber ?? 'No phone number set',
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                      IconButton(
                        icon: Icon(
                          _isEditingPhone ? Icons.save : Icons.edit,
                          color: Colors.deepPurpleAccent, 
                        ),
                        onPressed: () {
                          setState(() {
                            _isEditingPhone = !_isEditingPhone;
                            if (!_isEditingPhone) {
                              _saveProfile();
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Toffee count section
                  Row(
                    children: [
                      const Text(
                        'Toffee Count: ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        '123', // Replace with actual Toffee count from your database
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Log Out Button (TextButton version)
                  TextButton(
                    onPressed: () async {
                      // Sign out the user when confirmed
                      await FirebaseAuth.instance.signOut();
                      // Navigate to the login page after sign out
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text('Logout', style: TextStyle(fontSize: 18)),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white, // Background color
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
