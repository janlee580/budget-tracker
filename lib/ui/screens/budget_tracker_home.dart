import 'package:bt/providers/budget_provider.dart';
import 'package:bt/ui/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:bt/data/models/transaction.dart';
import 'package:provider/provider.dart';
import 'package:bt/ui/themes/app_colors.dart';
import 'package:bt/providers/notification_provider.dart';
import 'package:bt/ui/screens/notification_screen.dart';

class BudgetTrackerHome extends StatelessWidget {
  final Function(TransactionType) onAddTransaction;
  final Future<void> Function() onRefresh;

  const BudgetTrackerHome({
    super.key,
    required this.onAddTransaction,
    required this.onRefresh,
  });

  void _showAddTransactionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Transaction Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.add, color: primaryGreen),
                title: const Text('Income'),
                onTap: () {
                  Navigator.pop(context);
                  onAddTransaction(TransactionType.income);
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove, color: warningRed),
                title: const Text('Expense'),
                onTap: () {
                  Navigator.pop(context);
                  onAddTransaction(TransactionType.expense);
                },
              ),
              ListTile(
                leading: const Icon(Icons.savings, color: secondaryBlue),
                title: const Text('Savings'),
                onTap: () {
                  Navigator.pop(context);
                  onAddTransaction(TransactionType.savings);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationScreen()));
                        },
                      ),
                      if (provider.unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              provider.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingsScreen(onReset: onRefresh)));
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: onRefresh,
                child: constraints.maxWidth < 600
                    ? _buildNarrowLayout(context, budgetProvider)
                    : _buildWideLayout(context, budgetProvider),
              );
            },
          ),
        );
      },
    );
  }

  // Layout for smaller screens
  Widget _buildNarrowLayout(BuildContext context, BudgetProvider budgetProvider) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      children: [
        const SizedBox(height: 16),
        _buildQuickActionButtons(context),
        const SizedBox(height: 24),
        _buildBalanceOverviewCard(context, budgetProvider),
        const SizedBox(height: 24),
        _buildSavingsCard(context, budgetProvider),
        const SizedBox(height: 32),
        _buildMonthlyBudgetsCard(context, budgetProvider),
      ],
    );
  }

  // Layout for wider screens
  Widget _buildWideLayout(BuildContext context, BudgetProvider budgetProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickActionButtons(context),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildBalanceOverviewCard(context, budgetProvider),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildSavingsCard(context, budgetProvider),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildMonthlyBudgetsCard(context, budgetProvider),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add, color: white),
        label: const Text('Add Transaction', style: TextStyle(color: white)),
        onPressed: () => _showAddTransactionDialog(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildBalanceOverviewCard(BuildContext context, BudgetProvider budgetProvider) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.secondary.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Total Budget', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text('\$${budgetProvider.totalBalance.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Income',
                    style: TextStyle(
                        color: theme.colorScheme.primary, fontSize: 16)),
                Text('\$${budgetProvider.totalIncomeThisMonth.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expenses',
                    style: TextStyle(
                        color: theme.colorScheme.error, fontSize: 16)),
                Text('-\$${budgetProvider.totalExpensesThisMonth.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsCard(BuildContext context, BudgetProvider budgetProvider) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.secondary.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Saved', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 8),
            Text('\$${budgetProvider.totalSavings.toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBudgetsCard(BuildContext context, BudgetProvider budgetProvider) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.secondary.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Monthly Budgets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...budgetProvider.categoryBudgets.entries.map((entry) {
              final spent = budgetProvider.allTransactions
                  .where((t) =>
                      t.category == entry.key &&
                      t.type == TransactionType.expense &&
                      t.date.month == currentMonth &&
                      t.date.year == currentYear)
                  .fold(0.0, (sum, item) => sum + item.amount);
              final progress =
                  (entry.value > 0) ? (spent / entry.value).clamp(0.0, 1.0) : 0.0;
              return _buildBudgetCategoryRow(
                  context, entry.key, entry.value, progress);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCategoryRow(
      BuildContext context, String category, double budget, double progress) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category, style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: lightGrey,
                valueColor: AlwaysStoppedAnimation<Color>(progress > 0.8
                    ? theme.colorScheme.error
                    : (progress > 0.5
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.primary)),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          Text('\$${budget.toStringAsFixed(0)}',
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
