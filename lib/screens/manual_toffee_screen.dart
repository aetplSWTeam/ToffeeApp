import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:toffee/widgets/bottom_navbar.dart';
import '../services/purchase_service.dart'; // Import the purchase_service.dart
import '../utils/toast_util.dart';

class ManuallyAddToffeeScreen extends StatefulWidget {
  @override
  _ManuallyAddToffeeScreenState createState() =>
      _ManuallyAddToffeeScreenState();
}

class _ManuallyAddToffeeScreenState extends State<ManuallyAddToffeeScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final TextEditingController _quantityController = TextEditingController();
  DateTime? _selectedDate;

  // Function to show date picker
  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

// Function to save data to Firestore
  Future<void> _saveToFirebase() async {
    String quantity = _quantityController.text;
    if (quantity.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter quantity and select a date")),
      );
      return;
    }

    // Calculate total cost (price per toffee is 10)
    int pricePerToffee = 10;
    int totalCost = int.parse(quantity) * pricePerToffee;

    // Format the date to store it in Firestore
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

    // Reference to Firebase collection (get the user ID from Firebase Auth or other sources)
    String userId =
        _currentUser!.uid; // Ensure _currentUser is correctly initialized

    try {
      // Call the function from purchase_service.dart to update the toffee and add purchase data
      await _purchaseService.addPurchaseWithDateAndUpdateToffees(
          userId, int.parse(quantity), totalCost, _selectedDate!);

      ToastUtil.successToast("Purchase successful!");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNavbar()));
    } catch (error) {
       ToastUtil.failedToast("Error saving purchase details: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Manually Add Toffee",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Section
              Text(
                "Add Toffee Details",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),

              // Quantity Input
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Quantity",
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
              ),
              SizedBox(height: 20),

              // Date Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate == null
                        ? "No Date Chosen"
                        : "Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _pickDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Pick Date",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _saveToFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Submit",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
