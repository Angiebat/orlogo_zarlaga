import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? selectedDeposit;
  final List<Map<String, String>> deposits = [
    {'name': 'Netflix', 'icon': 'assets/netflix_icon.png'},
    {'name': 'Car Insurance', 'icon': 'assets/car_icon.png'},
    {'name': 'Electricity Bill', 'icon': 'assets/electricity_icon.png'},
  ];
  final TextEditingController priceController = TextEditingController();
  DateTime? selectedDate;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addPayment() async {
    if (selectedDeposit == null || selectedDate == null || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all the fields')),
      );
      return;
    }

    try {
       final User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is logged in')),
      );
      return;
    }
      await _firestore.collection('users')
        .doc(user.uid)
        .collection('payments')
        .add({
      'depositName': selectedDeposit!,
      'price': int.parse(priceController.text),
      'dueDate': selectedDate!.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment added successfully!')),
      );

      // Reset the form
      setState(() {
        selectedDeposit = null;
        priceController.clear();
        selectedDate = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding payment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          flexibleSpace: Image.asset(
            'assets/Rectangle9.png',
            fit: BoxFit.cover,
          ),
          title: const Text(
            'Payment',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deposit Name:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: deposits.map((deposit) {
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(deposit['icon']!, width: 24, height: 24),
                        const SizedBox(width: 8),
                        Text(deposit['name']!),
                      ],
                    ),
                    selected: selectedDeposit == deposit['name'],
                    onSelected: (selected) {
                      setState(() {
                        selectedDeposit = selected ? deposit['name'] : null;
                      });
                    },
                    selectedColor: Colors.blue.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selectedDeposit == deposit['name']
                          ? Colors.blue
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text(
                'Total Price:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Enter amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Date:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedDate == null
                        ? 'Select a date'
                        : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: _addPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Add To Payment',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}
