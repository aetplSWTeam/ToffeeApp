import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ToffeeScreen extends StatefulWidget {
  @override
  _ToffeeScreenState createState() => _ToffeeScreenState();
}

class _ToffeeScreenState extends State<ToffeeScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> events = [];
  final ScrollController _scrollController = ScrollController();
  bool isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (isScrolling) return;

    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      _changeDate(forward: true);
    } else if (_scrollController.offset <= _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      _changeDate(forward: false);
    }
  }

  void _changeDate({required bool forward}) {
    setState(() {
      isScrolling = true;
      selectedDate = forward
          ? selectedDate.add(const Duration(days: 1))
          : selectedDate.subtract(const Duration(days: 1));
    });

    Future.delayed(const Duration(milliseconds: 00), () {
      setState(() {
        isScrolling = false;
      });
    });

    fetchEvents();
  }

  void fetchEvents() {
    // Simulated data fetch, replace with actual Firestore query
    setState(() {
      events = [
        {
          'quantity': 5,
          'totalCost': 25.0,
          'timestamp': Timestamp.fromDate(selectedDate),
        },
        {
          'quantity': 10,
          'totalCost': 50.0,
          'timestamp': Timestamp.fromDate(selectedDate),
        },
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Toffee Records"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          SizedBox(height: 16),
          Text(
            DateFormat('yyyy-MM-dd').format(selectedDate),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      "No events for ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: events.length,
                    physics: ClampingScrollPhysics(), // Smooth scrolling
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return Card(
                        elevation: 4,
                        margin:
                            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              "${event['quantity']}",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text("Quantity: ${event['quantity']}"),
                          subtitle: Text("Total Cost: \$${event['totalCost']}"),
                          trailing: Text(
                            DateFormat('yyyy-MM-dd').format(
                              (event['timestamp'] as Timestamp).toDate(),
                            ),
                            style: TextStyle(
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
