import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toffee/firebase_options.dart';
import 'package:toffee/screens/login_page.dart';
import 'package:toffee/screens/signup_page.dart';
import 'package:toffee/widgets/bottom_navbar.dart';
import 'screens/splash_screen.dart';

// import "package:http/http.dart" as http;

// STRIPE

import "package:flutter_stripe/flutter_stripe.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Stripe.publishableKey =
      "pk_test_51QmqCVK1OSpV3qkYzQNGDSmQpu0a6bH3T3pnIbcqHg37ZoVHksk0Cca6mzzYqxTL5xlEg10H7sjoP53wT9e97GhE009G5i1FgW";
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Toffee App',
        theme: ThemeData(primarySwatch: Colors.purple),
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignupPage(),
          '/dashboard': (context) => const BottomNavbar()
        });
  }
}
