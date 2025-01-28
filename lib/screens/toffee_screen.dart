import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:toffee/widgets/bottom_navbar.dart';
import '../services/purchase_service.dart'; // Updated import for the renamed service
import '../utils/toast_util.dart'; // Import the ToastUtil class

class ToffeeScreen extends StatefulWidget {
  const ToffeeScreen({super.key});

  @override
  _ToffeeScreenState createState() => _ToffeeScreenState();
}

class _ToffeeScreenState extends State<ToffeeScreen> {
  final PurchaseService _purchaseService =
      PurchaseService(); // Updated class instance
  final User? _currentUser =
      FirebaseAuth.instance.currentUser; // Get the current user

  int totalToffees = 0; // Total number of toffees
  int totalPrice = 0; // Total price (price per toffee = 10)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: const Text('Toffee Options'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildToffeeOptions('Buy Toffee', Colors.blueAccent, context),
            const SizedBox(height: 20),
            _buildToffeeOptions('Return Toffee', Colors.redAccent, context),
          ],
        ),
      ),
    );
  }

  Widget _buildToffeeOptions(String title, Color color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (title == 'Buy Toffee') {
          _showBuyToffeeDialog(context); // Show dialog to enter quantity
        } else if (title == 'Return Toffee') {
          _showReturnToffeeDialog(context); // Show dialog to return toffee
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
              style: const TextStyle(
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

  void _showBuyToffeeDialog(BuildContext context) {
    final TextEditingController quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Buy Toffee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the quantity of toffees you want to buy:'),
              const SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Quantity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final int? quantity = int.tryParse(quantityController.text);
                if (quantity != null && quantity > 0) {
                  _showPaymentDialog(context, quantity);
                }
              },
              child: const Text('Buy'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(BuildContext context, int quantity) {
    final int pricePerToffee = 10;
    final int totalCost = quantity * pricePerToffee;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Payment Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Quantity: $quantity'),
              const SizedBox(height: 10),
              Text('Price per Toffee: ₹$pricePerToffee'),
              const SizedBox(height: 10),
              Text('Total Cost: ₹$totalCost'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  totalToffees += quantity;
                  totalPrice += totalCost;
                });

                // Save to Firestore
                if (_currentUser != null) {
                  try {
                    await _purchaseService.savePurchaseDetails(
                      _currentUser!.uid, // Pass the user's UID
                      quantity,
                      totalCost,
                    );
                    // Show success toast if the save is successful
                    ToastUtil.successToast("Purchase successful!");

                    // Navigate to BottomNavbar before popping dialogs
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomNavbar()));
                  } catch (e) {
                    // Show failure toast if an error occurs
                    ToastUtil.failedToast("Error saving purchase details: $e");
                  }
                }
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
  }

  // New method for returning toffee
  void _showReturnToffeeDialog(BuildContext context) {
    final TextEditingController returnQuantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return Toffee'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the quantity of toffees you want to return:'),
              const SizedBox(height: 10),
              TextField(
                controller: returnQuantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Quantity',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final int? quantityToReturn = int.tryParse(returnQuantityController.text);
                if (quantityToReturn != null && quantityToReturn > 0) {
                  // Call the return toffee function
                  if (_currentUser != null) {
                    try {
                      await _purchaseService.returnToffee(  
                        _currentUser!.uid, // Pass the user's UID
                        quantityToReturn,
                      );
                      ToastUtil.successToast("Toffee returned successfully!");
                      // Navigate to BottomNavbar before popping dialogs
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomNavbar()));
                    } catch (e) {
                      ToastUtil.failedToast("Error returning toffee: $e");
                    }
                  }

                  
                }
              },
              child: const Text('Return'),
            ),
          ],
        );
      },
    );
  }
}
