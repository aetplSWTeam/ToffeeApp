import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:toffee/widgets/bottom_navbar.dart';
import '../services/payment_service.dart'; // Import Stripe Payment Service
import '../services/purchase_service.dart';
import '../utils/toast_util.dart';

class ToffeeScreen extends StatefulWidget {
  const ToffeeScreen({super.key});

  @override
  _ToffeeScreenState createState() => _ToffeeScreenState();
}

class _ToffeeScreenState extends State<ToffeeScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  int totalToffees = 0;
  int totalPrice = 0;

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
          _showBuyToffeeDialog(context);
        } else if (title == 'Return Toffee') {
          _showToffeeDialog(context, title);
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
                Navigator.pop(context);
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
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_currentUser == null) {
                  ToastUtil.failedToast("User not logged in!");
                  return;
                }

                // Convert amount to cents
                String amountInCents = (totalCost * 100).toString();

                // Initiate Stripe Payment
                bool paymentSuccess =
                    await PaymentService.makePayment(amountInCents);

                if (paymentSuccess) {
                  setState(() {
                    totalToffees += quantity;
                    totalPrice += totalCost;
                  });

                  // Save purchase details
                  try {
                    await _purchaseService.savePurchaseDetails(
                      _currentUser!.uid,
                      quantity,
                      totalCost,
                    );

                    ToastUtil.successToast("Purchase successful!");
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BottomNavbar()));
                  } catch (e) {
                    ToastUtil.failedToast("Error saving purchase details: $e");
                  }
                } else {
                  ToastUtil.failedToast("Payment failed! Try again.");
                }
              },
              child: const Text('Pay'),
            ),
          ],
        );
      },
    );
  }

  void _showToffeeDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text('You tapped on $title'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
