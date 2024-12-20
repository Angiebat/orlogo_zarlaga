import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'wallet_screen.dart';
import 'all_transaction_screen.dart';

class BankHomeScreen extends StatefulWidget {
  const BankHomeScreen({super.key});

  @override
  State<BankHomeScreen> createState() => _BankHomeScreenState();
}

class _BankHomeScreenState extends State<BankHomeScreen> {
  final PersistentTabController _controller = PersistentTabController(initialIndex: 0);
  List<Map<String, dynamic>> recentTransactions = [];
  double balance = 0.0;
  double income = 0.0;
  double expenditure = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchRecentTransactions();
  }

  void _fetchRecentTransactions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
    // Handle the case where the user is not logged in
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User not logged in!')),
    );
    return;
  }
  final uid = user.uid;
  FirebaseFirestore.instance.collection('users')
      .doc(uid)
      .collection('addMoney').snapshots().listen((snapshot) {
    final List<Map<String, dynamic>> transactions = [];
    double totalIncome = 0.0;
    double totalExpenditure = 0.0;
    double totalBalance = 0.0;
    
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final amount = data['Amount'] is num ? (data['Amount'] as num).toDouble() : 0.0;
      final title = data['title'] ?? 'Unknown';
      final date = _formatDate(data['date']);
      final photo = _getPhotoForTitle(title);

      transactions.add({
        'title': title,
        'Amount': amount >= 0 ? '+\$${amount.toStringAsFixed(2)}' : '-\$${amount.abs().toStringAsFixed(2)}',
        'date': date,
        'photo': photo,
      });

      // Calculate totals
      if (amount >= 0) {
        totalIncome += amount;
      } else {
        totalExpenditure += amount.abs();
      }
      totalBalance += amount;
    }

    setState(() {
      recentTransactions = transactions;
      income = totalIncome;
      expenditure = totalExpenditure;
      balance = totalBalance;
    });
  }, onError: (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching transactions: $e')),
    );
  });
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

  @override
  Widget build(BuildContext context) {
    final String currentDate = DateTime.now().toString().split(' ')[0];

    return PersistentTabView(
      context,
      controller: _controller,
      screens: [
        _buildHomeScreenContent(currentDate),
        const Placeholder(), // Statistics Screen
        const WalletScreen(),
        const Placeholder(), // Profile Screen
      ],
      items: [
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.home),
          title: 'Home',
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.blue,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.bar_chart),
          title: 'Statistics',
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.blue,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.account_balance_wallet),
          title: 'Wallet',
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.blue,
        ),
        PersistentBottomNavBarItem(
          icon: const Icon(Icons.person),
          title: 'Profile',
          activeColorPrimary: Colors.green,
          inactiveColorPrimary: Colors.blue,
        ),
      ],
      navBarStyle: NavBarStyle.style3,
    );
  }

  Widget _buildHomeScreenContent(String currentDate) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 250,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/Rectangle9.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60, left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.person, size: 30),
                              ),
                              const SizedBox(width: 16),
                              const Text(
                                'Hello, Khanka',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 13),
                          Text(
                            'Date: $currentDate',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Transactions',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AllTransactionsScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'See All Transactions',
                              style: TextStyle(fontSize: 14, color: Colors.blue),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = recentTransactions[index];
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: AssetImage(transaction['photo']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(transaction['title']),
                      subtitle: Text(transaction['date']),
                      trailing: Text(
                        transaction['Amount'],
                        style: TextStyle(
                          fontSize: 16,
                          color: transaction['Amount'].startsWith('-')
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    );
                  },
                  childCount: recentTransactions.length,
                ),
              ),
            ],
          ),
          Positioned(
            top: 180,
            left: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text('Income', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('\$${income.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, color: Colors.green)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Expenditure', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(
                            '\$${expenditure.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 28, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
