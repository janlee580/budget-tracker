import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bt/data/models/transaction.dart';
import 'package:bt/ui/themes/app_colors.dart'; // For color palette

class TransactionHistoryScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionHistoryScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final incomeTransactions =
        transactions.where((t) => t.type == TransactionType.income).toList();
    final expenseTransactions =
        transactions.where((t) => t.type == TransactionType.expense).toList();
    final savingsTransactions =
        transactions.where((t) => t.type == TransactionType.savings).toList();

    return DefaultTabController(
      length: 3, // Updated to 3 tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Income'),
              Tab(text: 'Expenses'),
              Tab(text: 'Savings'), // New tab
            ],
            labelColor: textBlack,
            indicatorColor: primaryGreen,
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionList(incomeTransactions),
            _buildTransactionList(expenseTransactions),
            _buildTransactionList(savingsTransactions), // New list view
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions yet.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isIncome = transaction.type == TransactionType.income;
        final isSavings = transaction.type == TransactionType.savings;

        Color color;
        IconData icon;
        String prefix;

        if (isIncome) {
          color = primaryGreen;
          icon = Icons.arrow_upward;
          prefix = '+';
        } else if (isSavings) {
          color = secondaryBlue;
          icon = Icons.savings;
          prefix = '+';
        } else {
          color = warningRed;
          icon = Icons.arrow_downward;
          prefix = '-';
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(125),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        transaction.category,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd().format(transaction.date),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '$prefix\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
