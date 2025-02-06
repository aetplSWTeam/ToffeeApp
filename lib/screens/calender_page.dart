import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
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
  final ScrollController _scrollController = ScrollController();
  bool _isNavbarVisible = true;

  @override
  void initState() {
    super.initState();
    getUserId();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      setState(() => _isNavbarVisible = false);
    } else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      setState(() => _isNavbarVisible = true);
    }
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
    final fetchedEvents = await purchaseService.getPurchasesForUser(userId!);
    fetchedEvents.sort((a, b) =>
        (a['timestamp'] as Timestamp).toDate().compareTo((b['timestamp'] as Timestamp).toDate()));
    setState(() {
      events = fetchedEvents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Toffee Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.deepPurple),
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
                    setState(() => selectedDate = date);
                    fetchEventsForDate(selectedDate);
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isSelected ? const LinearGradient(colors: [Colors.deepPurple, Colors.purpleAccent]) : null,
                      color: isSelected ? null : isToday ? Colors.orangeAccent : Colors.grey.shade300,
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.deepPurple.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        Text(DateFormat.E().format(date),
                            style: TextStyle(color: isSelected || isToday ? Colors.white : Colors.black54, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        Text(DateFormat.d().format(date),
                            style: TextStyle(color: isSelected || isToday ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: events.isEmpty ? 1 : events.length,
              itemBuilder: (context, index) {
                if (events.isEmpty) {
                  return Center(
                    child: Text("No events for ${DateFormat('yyyy-MM-dd').format(selectedDate)}", style: const TextStyle(fontSize: 16)),
                  );
                }
                final event = events[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple,
                      child: Text("${event['quantity']}", style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text("Quantity: ${event['quantity']}"),
                    subtitle: Text("Total Cost: \$${event['totalCost']}"),
                    trailing: Text(
                      DateFormat('yyyy-MM-dd').format((event['timestamp'] as Timestamp).toDate()),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isNavbarVisible ? kBottomNavigationBarHeight : 0,
        child: Wrap(
          children: [
            BottomNavigationBar(
              currentIndex: 1,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendar'),
                BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Account'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
