import 'package:bt/data/models/notification.dart';
import 'package:bt/providers/notification_provider.dart';
import 'package:bt/services/notification_service.dart';
import 'package:bt/data/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:bt/ui/themes/app_colors.dart';
import 'package:bt/providers/budget_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionType initialType;

  const AddTransactionScreen({
    super.key,
    this.initialType = TransactionType.expense,
  });

  @override
  AddTransactionScreenState createState() => AddTransactionScreenState();
}

class AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _transactionType;
  final _amountController = TextEditingController();
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  final List<String> _incomeCategories = ['Salary', 'Bonus', 'Gift', 'Other'];
  final List<String> _savingsCategories = ['General Savings', 'Vacation', 'New Car', 'Retirement'];

  @override
  void initState() {
    super.initState();
    _transactionType = widget.initialType;
    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final categories = _getCategoriesForType(_transactionType, budgetProvider);
    if (categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }
  }

  List<String> _getCategoriesForType(TransactionType type, BudgetProvider budgetProvider) {
    switch (type) {
      case TransactionType.income:
        return _incomeCategories;
      case TransactionType.savings:
        return _savingsCategories;
      case TransactionType.expense:
        return budgetProvider.categoryBudgets.keys.toList();
    }
  }

  void _submitTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final amount = double.parse(_amountController.text);
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);

      if (_transactionType == TransactionType.savings &&
          amount > budgetProvider.totalBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Savings cannot exceed available balance of \$${budgetProvider.totalBalance.toStringAsFixed(2)}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      final newTransaction = Transaction(
        category: _selectedCategory!,
        amount: amount,
        date: _selectedDate,
        type: _transactionType,
      );
      await budgetProvider.addTransaction(newTransaction);

      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final typeString = newTransaction.type.toString().split('.').last;
      final capitalizedType =
          typeString[0].toUpperCase() + typeString.substring(1);

      final transactionNotification = AppNotification(
        id: DateTime.now().millisecondsSinceEpoch,
        title: 'Transaction Added',
        body:
            '$capitalizedType of \$${newTransaction.amount.toStringAsFixed(2)} for ${newTransaction.category} has been added.',
        timestamp: DateTime.now(),
      );
      notificationProvider.addNotification(transactionNotification);
      await NotificationService().showNotification(
        transactionNotification.id,
        transactionNotification.title,
        transactionNotification.body,
        'item x',
      );

      _amountController.clear();
      setState(() {
        _selectedDate = DateTime.now();
      });

      final mounted = this.mounted;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Transaction added successfully!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final categories = _getCategoriesForType(_transactionType, budgetProvider);

        return Scaffold(
          appBar: AppBar(
            title: Text('Add ${_transactionType.toString().split('.').last}'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCategoryDropdown(categories),
                  const SizedBox(height: 24),
                  _buildAmountField(),
                  const SizedBox(height: 24),
                  _buildDateField(),
                  const SizedBox(height: 48),
                  _buildSaveButton(),
                  if (_transactionType == TransactionType.savings)
                    _buildSavingsChart(budgetProvider),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDropdown(List<String> categories) {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '\$',
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter an amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          DateFormat.yMMMd().format(_selectedDate),
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _submitTransaction,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: const Text('Save Transaction'),
    );
  }

  Widget _buildSavingsChart(BudgetProvider budgetProvider) {
    final Map<String, double> savingsByCategory = {};
    for (var transaction in budgetProvider.allTransactions
        .where((t) => t.type == TransactionType.savings)) {
      savingsByCategory.update(
          transaction.category, (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    if (savingsByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final barGroups =
        savingsByCategory.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: amount,
            color: secondaryBlue,
            width: 22,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
    }).toList();

    final double chartWidth = savingsByCategory.length * 60.0;

    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Savings Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: savingsByCategory.values.reduce((a, b) => a > b ? a : b) * 1.2,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final category =
                              savingsByCategory.keys.elementAt(group.x.toInt());
                          return BarTooltipItem(
                            '$category\n',
                            const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(
                                text: '\$${rod.toY.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index >= 0 &&
                                index < savingsByCategory.keys.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 4.0,
                                child: Text(
                                    savingsByCategory.keys.elementAt(index),
                                    style: const TextStyle(fontSize: 10)),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                          reservedSize: 32,
                        ),
                      ),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barGroups: barGroups,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
