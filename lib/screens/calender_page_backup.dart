import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:toffee/widgets/bottom_navbar.dart';
import '../services/purchase_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDate = DateTime.now();
  String? userId;
  List<Map<String, dynamic>> events = [];
  final PurchaseService purchaseService = PurchaseService();

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  Future<void> getUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          userId = user.uid;
        });
        fetchEventsForDate(selectedDate);
      }
    } catch (e) {
      print("Error fetching user ID: $e");
    }
  }

  Future<void> fetchEventsForDate(DateTime date) async {
    if (userId == null) return;

    final fetchedEvents = await purchaseService.getPurchasesForDate(userId!, date);
    setState(() {
      events = fetchedEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Toffee Calendar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = date.year == selectedDate.year &&
                          date.month == selectedDate.month &&
                          date.day == selectedDate.day;
                      final isToday = date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                          fetchEventsForDate(selectedDate);
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Colors.deepPurple, Colors.purpleAccent],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : isToday
                                    ? Colors.orangeAccent
                                    : Colors.grey.shade300,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                DateFormat.E().format(date),
                                style: TextStyle(
                                  color: isSelected || isToday
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                DateFormat.d().format(date),
                                style: TextStyle(
                                  color: isSelected || isToday
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
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
                Expanded(
                  child: events.isEmpty
                      ? Center(
                          child: Text(
                            "No events for ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return Card(
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.deepPurple,
                                  child: Text(
                                    "${event['quantity']}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                title: Text("Quantity: ${event['quantity']}"),
                                subtitle: Text("Total Cost: \$${event['totalCost']}"),
                                trailing: Text(
                                  DateFormat.Hm().format(
                                      (event['timestamp'] as Timestamp).toDate()),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
     
    );
  }
}
