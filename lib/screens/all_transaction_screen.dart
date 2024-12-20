import 'package:flutter/material.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example transactions including date and time
    final List<Map<String, String>> transactions = [
      {
        'title': 'Grocery',
        'amount': '-\$50',
        'photo': 'assets/transactions.png',
        'date': 'Jan 28, 2024, 10:30 AM'
      },
      {
        'title': 'Salary',
        'amount': '+\$1200',
        'photo': 'assets/transactions.png',
        'date': 'Jan 27, 2024, 4:00 PM'
      },
      {
        'title': 'Electricity Bill',
        'amount': '-\$100',
        'photo': 'assets/transactions.png',
        'date': 'Jan 26, 2024, 9:00 AM'
      },
      {
        'title': 'Dining',
        'amount': '-\$30',
        'photo': 'assets/transactions.png',
        'date': 'Jan 25, 2024, 8:00 PM'
      },
      {
        'title': 'Gym Membership',
        'amount': '-\$60',
        'photo': 'assets/transactions.png',
        'date': 'Jan 24, 2024, 7:30 AM'
      },
      {
        'title': 'Freelance',
        'amount': '+\$300',
        'photo': 'assets/transactions.png',
        'date': 'Jan 23, 2024, 11:45 AM'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
      ),
      body: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(transaction['photo']!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Text(transaction['title']!),
            subtitle: Text(transaction['date']!), // Displaying date and time
            trailing: Text(
              transaction['amount']!,
              style: TextStyle(
                fontSize: 16,
                color: transaction['amount']!.startsWith('-')
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          );
        },
      ),
    );
  }
}
