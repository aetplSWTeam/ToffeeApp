import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import for FirebaseAuth
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime today = DateTime.now();
  DateTime selectedDate = DateTime.now(); // Track the selected date
  Map<String, int> toffeeData = {}; // Data for each date
  String? userId; // Variable to store the userId

  @override
  void initState() {
    super.initState();
    getUserId(); // Fetch userId on screen load
  }

  // Get the current user's ID
  Future<void> getUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid; // Set the userId
        });
        fetchToffeeData(); // Fetch toffee data after getting userId
      }
    } catch (e) {
      print("Error fetching user ID: $e");
    }
  }

  // Fetch toffee data for the user from Firestore
  Future<void> fetchToffeeData() async {
    if (userId == null) return; // Ensure userId is available

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('purchases')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final purchases = data['purchases'] as Map<String, dynamic>?;

        setState(() {
          // Convert purchases into a usable map
          toffeeData = purchases?.map((key, value) => MapEntry(key, value as int)) ?? {};
        });
      }
    } catch (e) {
      print("Error fetching toffee data: $e");
    }
  }

  // Generate 7 dates (today and the next 6 days)
  List<DateTime> getSevenDays() {
    return List.generate(7, (index) => today.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final sevenDays = getSevenDays();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Toffee Calendar"),
        backgroundColor: Colors.deepPurple,
      ),
      body: userId == null
          ? const Center(
              child: CircularProgressIndicator(), // Show loading until userId is fetched
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal calendar UI
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sevenDays.length,
                    itemBuilder: (context, index) {
                      final date = sevenDays[index];
                      final isSelected = date == selectedDate;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date; // Update selected date
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat.E().format(date), // Day (e.g., Fri)
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat.d().format(date), // Date (e.g., 24)
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Display the user's toffee count for the selected date
                Center(
                  child: Text(
                    "Toffees purchased on ${DateFormat('yyyy-MM-dd').format(selectedDate)}: ${toffeeData[DateFormat('yyyy-MM-dd').format(selectedDate)] ?? 0}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
