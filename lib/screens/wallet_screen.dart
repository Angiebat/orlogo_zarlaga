import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  

import 'add_money_screen.dart';
import 'payment_screen.dart';
import 'payment_summary_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _showUpcomingTransactions = false;

  double totalBalance = 0.0;
  List<Map<String, dynamic>> recentTransactions = [];
  List<Map<String, dynamic>> upcomingTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _fetchTransactions(); 
}
  Future<void> _fetchTransactions() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in!')),
      );
      return;
    }

    final uid = user.uid;

    // Listen to AddMoney transactions
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addMoney')
        .snapshots()
        .listen((addMoneySnapshot) {
      final addMoneyTransactions = addMoneySnapshot.docs.map((doc) {
        final data = doc.data();
        final title = data['title'] ?? 'Add Money';
        final amount = data['Amount'] is num ? (data['Amount'] as num).toDouble() : 0.0;
        final formattedDate = _formatDate(data['date']);

        return {
          'title': title,
          'amount': '+\$${amount.toStringAsFixed(2)}',
          'date': formattedDate,
          'photo': _getPhotoForTitle(title),
        };
      }).toList();

      // Update state
      setState(() {
        recentTransactions = addMoneyTransactions;

        // Calculate total balance
        totalBalance = recentTransactions.fold(0.0, (sum, transaction) {
          final amountString = transaction['amount'] as String;
          final numericAmount = double.tryParse(
              amountString.replaceAll(RegExp(r'[^\d.-]'), ''));
          return numericAmount != null ? sum + numericAmount : sum;
        });

        // Ensure proper formatting of amounts
        for (var transaction in recentTransactions) {
          if (transaction['amount'].startsWith('+\$-')) {
            transaction['amount'] = transaction['amount'].replaceFirst('+\$-', '-\$');
          }
        }
      });
    });

    // Listen to Payments transactions
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('payments')
        .snapshots()
        .listen((paymentSnapshot) {
      final paymentTransactions = paymentSnapshot.docs.map((doc) {
        final data = doc.data();
        final title = data['depositName'] ?? 'Unknown';
        final price = data['price'] is num ? (data['price'] as num).toDouble() : 0.0;

        return {
          'title': title,
          'amount': '-\$${price.toStringAsFixed(2)}',
          'date': _formatDate(data['dueDate']),
          'photo': _getPhotoForTitle(title),
        };
      }).toList();

      // Update state
      setState(() {
        upcomingTransactions = paymentTransactions;
      });
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching transactions: $e')),
    );
  }
}


String _getPhotoForTitle(String title) {
  switch (title) {
    case 'Debit Card':
      return 'assets/debit_card_icon.png';
    case 'Netflix':
      return 'assets/netflix_icon.png';
    case 'Car Insurance':
      return 'assets/car_icon.png';
    case 'Electricity Bill':
      return 'assets/electricity_icon.png';
    default:
      return 'assets/transactions.png'; 
  }
}


 String _formatDate(dynamic date) {
  try {
    if (date is Timestamp) {
      
      return DateFormat('MMM d, yyyy').format(date.toDate());
    } else if (date is String) {
      try {
        
        try {
          return DateFormat('MMM d, yyyy').format(
            DateFormat('MMM d, yyyy').parse(date)
          );
        } catch (specificFormatError) {
          
          final parsers = [
            DateFormat('yyyy-MM-dd'),
            DateFormat('MM/dd/yyyy'),
            DateFormat('dd-MM-yyyy'),
          ];

          for (var parser in parsers) {
            try {
              DateTime parsedDate = parser.parse(date);
              return DateFormat('MMM d, yyyy').format(parsedDate);
            } catch (_) {

              continue;
            }
          }
          print('Could not parse date: $date');
          return date; 
        }
      } catch (parseError) {
        print('Date parsing error: $parseError for date: $date');
        return date; 
      }
    } else if (date == null) {
      return 'No date';
    }
    
    print('Unhandled date type: ${date.runtimeType}');
    return date.toString();
  } catch (e) {
    print('Unexpected error in _formatDate: $e');
    return date.toString();
  }
}
  
  Future<void> onConfirmPayment(String title, double price) async {
  try {
    
    final paymentDoc = await FirebaseFirestore.instance
        .collection('payments')
        .where('depositName', isEqualTo: title)
        .get();

    
    for (var doc in paymentDoc.docs) {
      await doc.reference.delete();
    }

    
    setState(() {
    
      totalBalance -= price;
      recentTransactions.add({
        'title': title,
        'amount': '-\$${price.toStringAsFixed(2)}', 
        'date': _formatDate(DateTime.now()), 
        'photo': 'assets/transactions.png', 
      });

      
      upcomingTransactions.removeWhere((transaction) => transaction['title'] == title);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error confirming payment: $e')),
    );
  }
}
  
  DateTime _parseDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return DateTime.now(); // Default to current date if the input is null or empty
  }

  try {
    // Match the format used in the transaction date
    return DateFormat('MMM d, yyyy').parse(dateString);
  } catch (e) {
    print('Error parsing date: $e');
    return DateTime.now(); // Fallback to current date on failure
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
            'Wallet',
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
              
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalBalance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCircleButton(
                    context,
                    icon: Icons.add,
                    label: 'Add',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddMoneyScreen()),
                      );
                    },
                  ),
                  _buildCircleButton(
                    context,
                    icon: Icons.payment,
                    label: 'Pay',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PaymentScreen()),
                      );
                    },
                  ),
                  _buildCircleButton(
                    context,
                    icon: Icons.send,
                    label: 'Send',
                    onTap: () {
                      
                    },
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTabButton(
                    label: 'Recent Trans',
                    isSelected: !_showUpcomingTransactions,
                    onTap: () => setState(() {
                      _showUpcomingTransactions = false;
                    }),
                  ),
                  _buildTabButton(
                    label: 'Upcoming Trans',
                    isSelected: _showUpcomingTransactions,
                    onTap: () => setState(() {
                      _showUpcomingTransactions = true;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _showUpcomingTransactions
                      ? upcomingTransactions.length
                      : recentTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _showUpcomingTransactions
                        ? upcomingTransactions[index]
                        : recentTransactions[index];

                    final formattedDate = _formatDate(transaction['date']);
                    
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
  title: Text(transaction['title']),
  subtitle: Text(formattedDate), 
  trailing: _showUpcomingTransactions
      ? TextButton(
          onPressed: () {
            final transaction = upcomingTransactions[index];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentSummaryScreen(
                  depositName: transaction['title'] ?? 'Unknown',
                  depositIcon: transaction['photo'] ?? 'assets/debit_card_icon.png',
                 selectedDate: _parseDate(transaction['date']),
                  price: double.tryParse(transaction['amount']?.replaceAll(RegExp(r'[^\d.-]'), '') ?? '0') ?? 0.0,
                ),
              ),
            );
          },
          child: const Text('Pay'),
        )
      : Text(
          transaction['amount'],
          style: TextStyle(
            fontSize: 16,
            color: transaction['amount'].contains('-')
                ? Colors.red 
                : Colors.green, 
          ),
        ),
);

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.withOpacity(0.1),
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.black,
          ),
        ),
      ),
    );
  }
}

