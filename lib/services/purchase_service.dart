import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save or update purchase details in Firestore
Future<void> savePurchaseDetails(String userId, int quantity, int totalCost) async {
  try {
    final CollectionReference purchasesCollection = _firestore.collection('purchases');
    final DocumentReference userToffeesDoc = _firestore.collection('userAllToffeess').doc(userId);

    // Fetch the user's toffee document to check if they exist
    DocumentSnapshot userToffeeSnapshot = await userToffeesDoc.get();

    // If the document doesn't exist, create a new document with the initial quantity of toffees
    if (!userToffeeSnapshot.exists) {
      await userToffeesDoc.set({
        'userId': userId,
        'quantity': quantity,  // Set the initial quantity of toffees
      });
      print('User toffees document created with initial quantity');
    } else {
      // If the user already exists, update the quantity of toffees
      int existingQuantity = userToffeeSnapshot['quantity'];
      await userToffeesDoc.update({
        'quantity': existingQuantity + quantity,  // Add to existing quantity
      });
      print('User toffees quantity updated');
    }

    // Add a new document to the 'purchases' collection with the purchase details
    await purchasesCollection.add({
      'userId': userId,
      'quantity': quantity,
      'totalCost': totalCost,
      'timestamp': FieldValue.serverTimestamp(),
    });

    print('Purchase details saved successfully');

    // // Send a push notification using FCM
    // await _sendPushNotification(userId, quantity, totalCost);

  } catch (e) {
    print('Error saving purchase details: $e');
  }
}

// Future<void> _sendPushNotification(String userId, int quantity, int totalCost) async {
//   try {
//     // Use Firebase Messaging to send a notification (you can customize this part)
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     // Retrieve the device token for the user (you'll need to set up token generation and storage elsewhere)
//     String? token = await messaging.getToken();

//     if (token != null) {
//       // Create the message to be sent
//       Map<String, dynamic> message = {
//         'notification': {
//           'title': 'Purchase Successful!',
//           'body': 'You bought $quantity toffees for a total cost of \$${totalCost}.'
//         },
//         'to': token,
//       };

//       // Send the notification (you can use Firebase Functions or Firebase REST API to send FCM)
//       await messaging.sendMessage(
//         to: token,
//         data: message,
//       );

//       print('Push notification sent');
//     }
//   } catch (e) {
//     print('Error sending push notification: $e');
//   }
// }



// add toffee manually
Future<void> addPurchaseWithDateAndUpdateToffees( String userId, int quantity, int totalCost, DateTime purchaseDate) async {
  try {
    // Reference to the Firestore collections
    final CollectionReference purchasesCollection = FirebaseFirestore.instance.collection('purchases');
    final DocumentReference userToffeesDoc = FirebaseFirestore.instance.collection('userAllToffeess').doc(userId);

    // Format the purchase date as Firestore Timestamp
    Timestamp formattedDate = Timestamp.fromDate(purchaseDate);

    // Fetch the user's toffee document to check if they exist
    DocumentSnapshot userToffeeSnapshot = await userToffeesDoc.get();

    // If the document doesn't exist, create a new document with the initial quantity of toffees
    if (!userToffeeSnapshot.exists) {
      await userToffeesDoc.set({
        'userId': userId,
        'quantity': quantity,  // Set the initial quantity of toffees
      });
      print('User toffees document created with initial quantity');
    } else {
      // If the user already exists, update the quantity of toffees
      int existingQuantity = userToffeeSnapshot['quantity'];
      await userToffeesDoc.update({
        'quantity': existingQuantity + quantity,  // Add to existing quantity
      });
      print('User toffees quantity updated');
    }

    // Add the purchase details to the purchases collection
    await purchasesCollection.add({
      'userId': userId,
      'quantity': quantity,
      'totalCost': totalCost,
      'timestamp': formattedDate,  // Store the purchase date as the timestamp
    });

    print('Purchase with date added successfully and toffee quantity updated');
  } catch (e) {
    print('Error adding purchase with date and updating toffee quantity: $e');
  }

}



  

// fetch toffee count 
  Future<int> fetchToffeeCount(String uid) async {
    try {
      // Get the toffee count from Firestore using the user UID
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('userAllToffeess')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        return data['quantity'] ?? 0; // Default to 0 if toffeeCount is not found
      } else {
        return 0; // Return 0 if the document does not exist
      }
    } catch (e) {
      print("Error fetching toffee count: $e");
      return 0; // Return 0 in case of an error
    }
  }



  

 // Fetch purchases for the given userId and filter by current date
  Future<List<Map<String, dynamic>>> getPurchasesForDate(String userId, DateTime date) async {
    try {
      final snapshot = await _firestore
          .collection('purchases')
          .where('userId', isEqualTo: userId)
          .get();

      // Filter purchases based on the date (ignoring time)
      final filteredPurchases = snapshot.docs.where((doc) {
        final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
        return timestamp.year == date.year &&
            timestamp.month == date.month &&
            timestamp.day == date.day;
      }).map((doc) => doc.data()).toList();

      return filteredPurchases;
    } catch (e) {
      print("Error fetching purchases: $e");
      return [];
    }
  }



// Fetch purchases for the given userId
Future<List<Map<String, dynamic>>> getPurchasesForUser(String userId) async {
  try {
    final snapshot = await _firestore
        .collection('purchases')
        .where('userId', isEqualTo: userId)
        .get();

    // Map the documents to a list of maps
    final purchases = snapshot.docs.map((doc) => doc.data()).toList();

    return purchases;
  } catch (e) {
    print("Error fetching purchases: $e");
    return [];
  }
}
  

// get all purchases
  Future<List<Map<String, dynamic>>> getAllPurchases() async {
  try {
    final snapshot = await _firestore.collection('purchases').get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  } catch (e) {
    print("Error fetching purchases: $e");
    return [];
  }
}
}





























































