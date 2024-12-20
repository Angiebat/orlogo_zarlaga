import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'payment_success_screen.dart'; 

class PaymentConfirmationScreen extends StatelessWidget {
  final String depositName;
  final double price;
  final double tax;
  final double total;
  final String selectedPaymentMethod;
  final DateTime selectedDate;
  final VoidCallback onConfirmPayment; 

  const PaymentConfirmationScreen({
    super.key,
    required this.depositName,
    required this.price,
    required this.tax,
    required this.total,
    required this.selectedPaymentMethod,
    required this.selectedDate,
    required this.onConfirmPayment,
  });

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
            'Confirm Payment',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You will pay $depositName, do you confirm?',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildSummaryRow('Deposit Name', depositName),
            const SizedBox(height: 10),
            _buildSummaryRow('Price', '\$${price.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            _buildSummaryRow('Tax (1%)', '\$${tax.toStringAsFixed(2)}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Colors.grey, thickness: 1),
            ),
            _buildSummaryRow('Total', '\$${total.toStringAsFixed(2)}', isBold: true),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                       final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    final uid = user.uid;
                    // Remove payment from the "payments" collection
                    final paymentDocs = await FirebaseFirestore.instance
                         .collection('users')
        .doc(uid)
        .collection('payments')
                        .where('depositName', isEqualTo: depositName)
                        .get();

                    for (var doc in paymentDocs.docs) {
                      await doc.reference.delete(); // Delete the document
                    }

                    // Add a new entry to the "AddMoney" collection
                    await FirebaseFirestore.instance.collection('users')
        .doc(uid)
        .collection('addMoney').add({
                      'Amount': total, // Total payment including tax
                      'title': depositName,
                      'date': FieldValue.serverTimestamp(),
                    });

                    // Call the onConfirmPayment callback
                    onConfirmPayment();

                    // Notify success
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment confirmed and updated!')),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSuccessScreen(
                          depositName: depositName,
                          selectedPaymentMethod: selectedPaymentMethod,
                          selectedDate: selectedDate,
                          price: price,
                        ),
                      ),
                    );
                  } catch (e) {
                    // Handle any errors during the payment process
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Payment failed: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}