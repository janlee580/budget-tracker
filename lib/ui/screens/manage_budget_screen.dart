import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bt/data/models/transaction.dart';
import 'package:bt/ui/themes/app_colors.dart';
import 'package:bt/providers/budget_provider.dart';

class ManageBudgetScreen extends StatelessWidget {
  const ManageBudgetScreen({super.key});

  void _addOrUpdateCategoryBudget(BuildContext context, BudgetProvider budgetProvider, [String? categoryName]) {
    final isUpdating = categoryName != null;
    final categoryNameController =
        TextEditingController(text: isUpdating ? categoryName : '');
    final categoryBudgetController = TextEditingController(
        text: isUpdating ? budgetProvider.categoryBudgets[categoryName]?.toStringAsFixed(2) : '');
    final dialogFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUpdating ? 'Update Budget' : 'Add Category', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Form(
          key: dialogFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: categoryNameController,
                decoration: const InputDecoration(labelText: 'Category Name'),
                readOnly: isUpdating,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a category name.';
                  if (!isUpdating && budgetProvider.categoryBudgets.containsKey(value)) return 'Category already exists.';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: categoryBudgetController,
                decoration: const InputDecoration(labelText: 'Budget', prefixText: '\$'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a budget.';
                  final budget = double.tryParse(value);
                  if (budget == null || budget <= 0) return 'Enter a valid budget.';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: textBlack),
            child: const Text('Save'),
            onPressed: () {
              if (dialogFormKey.currentState!.validate()) {
                final category = categoryNameController.text;
                final budget = double.parse(categoryBudgetController.text);
                final newBudgets = Map<String, double>.from(budgetProvider.categoryBudgets);
                newBudgets[category] = budget;
                budgetProvider.updateCategoryBudgets(newBudgets);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _deleteCategoryBudget(BuildContext context, BudgetProvider budgetProvider, String category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete the "$category" budget category?'),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: warningRed, foregroundColor: white),
            child: const Text('Delete'),
            onPressed: () {
              final newBudgets = Map<String, double>.from(budgetProvider.categoryBudgets);
              newBudgets.remove(category);
              budgetProvider.updateCategoryBudgets(newBudgets);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Budgets'),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              final budgets = budgetProvider.categoryBudgets.entries.toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Category Budgets", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => _addOrUpdateCategoryBudget(context, budgetProvider),
                          icon: Icon(Icons.add_circle, color: primaryGreen),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isWide
                        ? GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              childAspectRatio: 1.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: budgets.length,
                            itemBuilder: (context, index) {
                              final entry = budgets[index];
                              return _buildCategoryBudgetCard(context, budgetProvider, entry.key, entry.value);
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            itemCount: budgets.length,
                            itemBuilder: (context, index) {
                              final entry = budgets[index];
                              return _buildCategoryBudgetCard(context, budgetProvider, entry.key, entry.value);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }


  Widget _buildCategoryBudgetCard(BuildContext context, BudgetProvider budgetProvider, String category, double budget) {
    final now = DateTime.now();
    final spent = budgetProvider.allTransactions
        .where((t) =>
            t.category == category &&
            t.type == TransactionType.expense &&
            t.date.year == now.year &&
            t.date.month == now.month)
        .fold(0.0, (sum, item) => sum + item.amount);
    final progress = (budget > 0) ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final remaining = budget - spent;

    Color getProgressColor(double progress) {
      if (progress >= 0.9) return warningRed;
      if (progress >= 0.7) return Colors.orangeAccent;
      return primaryGreen;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('\$${remaining.toStringAsFixed(2)} left',
                    style: TextStyle(color: remaining < 0 ? warningRed : Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: const Duration(milliseconds: 750),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: lightGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(getProgressColor(value)),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                );
              },
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Spent \$${spent.toStringAsFixed(2)} of \$${budget.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20, color: Colors.blueGrey),
                      onPressed: () => _addOrUpdateCategoryBudget(context, budgetProvider, category),
                      tooltip: 'Edit Budget',
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: warningRed),
                      onPressed: () => _deleteCategoryBudget(context, budgetProvider, category),
                      tooltip: 'Delete Budget',
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
