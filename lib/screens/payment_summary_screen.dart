import 'package:flutter/material.dart';
import 'payment_confirmation_screen.dart';

class PaymentSummaryScreen extends StatefulWidget {
  final String depositName;
  final String depositIcon;
  final DateTime selectedDate;
  final double price;

  const PaymentSummaryScreen({
    super.key,
    required this.depositName,
    required this.depositIcon,
    required this.selectedDate,
    required this.price,
  });

  @override
  State<PaymentSummaryScreen> createState() => _PaymentSummaryScreenState();
}

class _PaymentSummaryScreenState extends State<PaymentSummaryScreen> {
  String? selectedPaymentMethod;

  final List<Map<String, String>> paymentMethods = [
    {'name': 'Debit Card', 'icon': 'assets/debit_card_icon.png'},
    {'name': 'Paypal', 'icon': 'assets/paypal_icon.png'},
  ];

  @override
  Widget build(BuildContext context) {
    final double tax = widget.price * 0.01;
    final double total = widget.price + tax;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          flexibleSpace: Image.asset(
            'assets/Rectangle9.png',
            fit: BoxFit.cover,
          ),
          title: const Text(
            'Payment Summary',
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
              // Deposit Name and Date
              Row(
                children: [
                  Image.asset(widget.depositIcon, width: 40, height: 40),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.depositName,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.selectedDate.day}/${widget.selectedDate.month}/${widget.selectedDate.year}',
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price, Tax, Total
              _buildSummaryRow('Price', '\$${widget.price.toStringAsFixed(2)}'),
              const SizedBox(height: 10),
              _buildSummaryRow('Tax (1%)', '\$${tax.toStringAsFixed(2)}'),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.grey, thickness: 1),
              ),
              _buildSummaryRow(
                'Total',
                '\$${total.toStringAsFixed(2)}',
                isBold: true,
              ),
              const SizedBox(height: 30),

              // Payment Method Selector
              const Text(
                'Choose Paying Method:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: paymentMethods.map((method) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPaymentMethod = method['name'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedPaymentMethod == method['name']
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: selectedPaymentMethod == method['name']
                            ? Colors.blue.withOpacity(0.1)
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Image.asset(method['icon']!, width: 30, height: 30),
                          const SizedBox(width: 10),
                          Text(
                            method['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selectedPaymentMethod == method['name']
                                  ? Colors.blue
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),

              // Pay Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (selectedPaymentMethod == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a payment method'),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentConfirmationScreen(
                          depositName: widget.depositName,
                          price: widget.price,
                          tax: tax,
                          total: total,
                          selectedPaymentMethod: selectedPaymentMethod!,
                          selectedDate: widget.selectedDate,
                          onConfirmPayment: () {
                            // Any additional actions after confirmation
                          },
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Pay',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
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
