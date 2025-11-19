import 'package:bt/providers/budget_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bt/data/models/transaction.dart';
import 'package:bt/ui/screens/add_transaction_screen.dart';
import 'package:bt/ui/themes/app_colors.dart';

class TransactionHistoryScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionHistoryScreen({super.key, required this.transactions});

  void _editTransaction(BuildContext context, Transaction transaction) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => AddTransactionScreen(transaction: transaction),
    ));
  }

  void _deleteTransaction(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () {
              Provider.of<BudgetProvider>(context, listen: false)
                  .deleteTransaction(transaction.id!);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incomeTransactions =
        transactions.where((t) => t.type == TransactionType.income).toList();
    final expenseTransactions =
        transactions.where((t) => t.type == TransactionType.expense).toList();
    final savingsTransactions =
        transactions.where((t) => t.type == TransactionType.savings).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: primaryGradient,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Income'),
              Tab(text: 'Expenses'),
              Tab(text: 'Savings'),
            ],
            labelColor: Colors.white,
            indicatorColor: Colors.white,
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final content = TabBarView(
              children: [
                _buildTransactionList(context, incomeTransactions),
                _buildTransactionList(context, expenseTransactions),
                _buildTransactionList(context, savingsTransactions),
              ],
            );

            if (isWide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: content,
                ),
              );
            }
            return content;
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList(
      BuildContext context, List<Transaction> transactions) {
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
          color = primaryGradientTop;
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
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            title: Text(
              transaction.category,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(DateFormat.yMMMd().format(transaction.date)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '$prefix\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editTransaction(context, transaction),
                  color: Colors.blue,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteTransaction(context, transaction),
                  color: warningRed,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
