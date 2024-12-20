import 'package:flutter/material.dart';
import 'register_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            alignment: Alignment.topCenter,
            children: [
              Image.asset(
                'assets/layout.png', 
                fit: BoxFit.fitWidth,
                width: double.infinity,
                height: 700,
              ),
             Image.asset(
                'assets/human.png', 
                width: 500,
                height: 710,
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Ухаалаг зарцуулж Илүү хэмнэе!',
            style: TextStyle(
              fontSize: 32, 
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 200, 
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text(
                'Start',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}