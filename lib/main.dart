import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'screens/add_money_screen.dart';
import 'screens/all_transaction_screen.dart';
import 'screens/bank_home_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/wallet_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Activate Firebase App Check
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug, // Use the Debug provider for testing
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income and Expenses',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home_screen': (context) => const HomeScreen(),
        '/register_screen': (context) => const RegisterScreen(),
        '/login_screen': (context) => const LoginScreen(),
        '/bank_home_screen': (context) => const BankHomeScreen(),
        '/all_transaction_screen': (context) => const AllTransactionsScreen(),
        '/wallet_screen': (context) => const WalletScreen(),
        '/add_money_screen': (context) => const AddMoneyScreen(),
        '/payment_screen': (context) => const PaymentScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
