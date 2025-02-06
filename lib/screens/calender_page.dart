import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  int currentDayIndex = 0;
  List<DateTime> eventDates = [];

  @override
  void initState() {
    super.initState();
    getUserId();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      fetchEventsForDate(selectedDate);
    }
  }

  Future<void> fetchEventsForDate(DateTime date) async {
    if (userId == null) return;

    final fetchedEvents = await purchaseService.getPurchasesForUser(userId!);
    fetchedEvents.sort((a, b) {
      final dateA = (a['timestamp'] as Timestamp).toDate();
      final dateB = (b['timestamp'] as Timestamp).toDate();
      return dateA.compareTo(dateB);
    });

    // Grouping events by date
    Set<DateTime> uniqueDates = {};
    for (var event in fetchedEvents) {
      DateTime eventDate = (event['timestamp'] as Timestamp).toDate();
      uniqueDates.add(DateTime(eventDate.year, eventDate.month, eventDate.day));
    }

    setState(() {
      events = fetchedEvents;
      eventDates = uniqueDates.toList();
      selectedDate = eventDates.isNotEmpty ? eventDates.first : selectedDate;
    });
  }

  void _onScroll() {
    // Detect when the user has scrolled halfway through the list
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent * 0.5) {
      if (currentDayIndex + 1 < eventDates.length) {
        setState(() {
          currentDayIndex++;
          selectedDate = eventDates[currentDayIndex];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredEvents = events
        .where((event) =>
            DateFormat('yyyy-MM-dd').format((event['timestamp'] as Timestamp).toDate()) ==
            DateFormat('yyyy-MM-dd').format(selectedDate))
        .toList();

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
                    itemCount: eventDates.length,
                    itemBuilder: (context, index) {
                      final date = eventDates[index];
                      final isSelected = date == selectedDate;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                            currentDayIndex = index;
                          });
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      Colors.deepPurple,
                                      Colors.purpleAccent
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : Colors.grey.shade300,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                DateFormat.E().format(date),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                DateFormat.d().format(date),
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
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
                  child: filteredEvents.isEmpty
                      ? Center(
                          child: Text(
                            "No more events to show",
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            final event = filteredEvents[index];
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
                                subtitle:
                                    Text("Total Cost: \$${event['totalCost']}"),
                                trailing: Text(
                                  DateFormat('yyyy-MM-dd').format(
                                    (event['timestamp'] as Timestamp).toDate(),
                                  ),
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
