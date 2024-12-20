import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  bool _isCardsSelected = true;
  final TextEditingController _amountController = TextEditingController();

  // Method to add data to Firebase
 Future<void> _addMoneyToFirestore() async {
    final String amountText = _amountController.text;
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    try {
      final int amount = int.parse(amountText);
     // Get current user's UID
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in')),
        );
        return;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addMoney')
          .add({
        'Amount': amount,
        'title': 'Debit Card',
        'date': FieldValue.serverTimestamp(), // Current server time
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Money added successfully!')),
      );

      // Clear the input fields after submission
      _amountController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding money: $e')),
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
            'Add Money',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              label: 'Cards',
                              isSelected: _isCardsSelected,
                              onTap: () => setState(() {
                                _isCardsSelected = true;
                              }),
                            ),
                          ),
                          Expanded(
                            child: _buildTabButton(
                              label: 'Account',
                              isSelected: !_isCardsSelected,
                              onTap: () => setState(() {
                                _isCardsSelected = false;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isCardsSelected
                        ? _buildCardsForm()
                        : _buildAccountOptions(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromARGB(255, 64, 66, 67)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildCardsForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Column(
            children: [
              Image.asset(
                'assets/Cards.png',
                height: 170,
                width: 300,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              const Text(
                'Add your card information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRoundedTextField('Card Name'),
          const SizedBox(height: 5),
          _buildRoundedTextField('Card Number'),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(child: _buildRoundedTextField('CVC')),
              const SizedBox(width: 16),
              Expanded(child: _buildRoundedTextField('Card Date')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildRoundedTextField('ZIP')),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildRoundedTextField('Amount', _amountController)),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addMoneyToFirestore,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: Colors.blue.withOpacity(0.5),
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedTextField(String label,
      [TextEditingController? controller]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildAccountOptions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildAccountTile(Icons.account_balance, 'Bank Link',
              'Connect your bank account to deposit and fund'),
          const SizedBox(height: 8),
          _buildAccountTile(Icons.monetization_on, 'Microdeposits',
              'Connect your bank using microdeposits'),
          const SizedBox(height: 8),
          _buildAccountTile(
              Icons.paypal, 'PayPal', 'Connect your PayPal account'),
        ],
      ),
    );
  }

  Widget _buildAccountTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
