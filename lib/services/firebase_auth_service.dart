import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Logs in a user with email and password.
  Future<User?> login(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
     
      return userCredential.user;
    } catch (e) {
      throw _mapFirebaseAuthError(e);
    }
  }

  /// Registers a new user with email, password, and an optional display name.
  Future<User?> register(String email, String password, String name) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? userObj = userCredential.user;

      // Update the user's display name if provided
      if (userObj != null && name.isNotEmpty) {
        await userObj.updateDisplayName(name);
      // Reload user data to ensure we have the latest info
        await userObj.reload();
      }

      // Send email verification
      await userObj?.sendEmailVerification();

      return userObj;
    } catch (e) {
      print('Error during registration: $e');
      throw _mapFirebaseAuthError(e);
    }
  }

// Reset and forgot Password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      // Handle any errors that occur during the password reset process
      return false;
    }
  }



  // Signin with Google

    Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();


      print(googleUser);

      if (googleUser == null) {
        return null; // User canceled the Google sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Maps Firebase authentication errors to user-friendly messages.
  String _mapFirebaseAuthError(dynamic error) {
    if (error.toString().contains('email-already-in-use')) {
      return 'This email is already in use.';
    } else if (error.toString().contains('user-not-found')) {
      return 'No user found for this email.';
    } else if (error.toString().contains('wrong-password')) {
      return 'Incorrect password.';
    } else if (error.toString().contains('invalid-email')) {
      return 'Invalid email format.';
    } else if (error.toString().contains('weak-password')) {
      return 'The password is too weak.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }
}



