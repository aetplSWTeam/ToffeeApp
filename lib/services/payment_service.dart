import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentService {
  // Set your Stripe Publishable Key here
  static const String _secretKey = "sk_test_51QmqCVK1OSpV3qkYRGocl3gD7eIvQ4Bhs3loupbMBpWyIR8dWoFHN5Nv1ULJvNZW5CcFsrsQtKGnB4V1unWqirwp00luXKpaNk";



 static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in.");

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount,
          'currency': currency,
          'payment_method_types[]': 'card',
          'metadata[userId]': user.uid,
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('Error creating payment intent: $e');
      return {};
    }
  }

  static Future<bool> makePayment(String amount) async {
    try {
      final paymentIntent = await createPaymentIntent(amount, 'usd');
      if (paymentIntent.isEmpty) return false;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: "Toffee Store",
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      print("Payment successful!");
      return true;
    } catch (e) {
      print("Payment failed: $e");
      return false;
    }
  }
}



