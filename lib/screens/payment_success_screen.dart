import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String depositName;
  final String selectedPaymentMethod;
  final DateTime selectedDate;
  final double price;

  const PaymentSuccessScreen({
    super.key,
    required this.depositName,
    required this.selectedPaymentMethod,
    required this.selectedDate,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final double tax = price * 0.01;
    final double total = price + tax;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          flexibleSpace: Image.asset(
            'assets/Rectangle9.png',
            fit: BoxFit.cover,
          ),
          title: const Text(
            'Payment Success',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Payment Success! (Centered)
              const Text(
                'Payment Success!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),

              // Deposit Name (Centered)
              Text(
                depositName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Check Mark Icon (Centered)
              const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Deposit Details
              const Text(
                'Deposit Details:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Payment Method
              _buildDetailRow('Payment Method:', selectedPaymentMethod),
              const SizedBox(height: 10),

              // State
              _buildDetailRow('State:', 'Deposited'),
              const SizedBox(height: 10),

              // Date
              _buildDetailRow('Date:', '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
              const SizedBox(height: 10),

              // Deposit ID
              _buildDetailRow('Deposit ID:', '100'),
              
              // Line between Deposit ID and Price
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.grey, thickness: 1),
              ),

              // Price
              _buildDetailRow('Price:', '\$${price.toStringAsFixed(2)}'),
              const SizedBox(height: 10),

              // Tax
              _buildDetailRow('Tax (1%):', '\$${tax.toStringAsFixed(2)}'),
              
              // Line between Tax and Total
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.grey, thickness: 1),
              ),

              // Total
              _buildDetailRow(
                'Total:',
                '\$${total.toStringAsFixed(2)}',
                isBold: true,
              ),
              const SizedBox(height: 5),

              // QR Code Title (Centered)
              const Text(
                'QR Code:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // QR Code Image (Centered)
              Center(
                child: Image.asset('assets/qr_code.png', width: 150, height: 120),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
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