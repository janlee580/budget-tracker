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
import 'package:bt/ui/widgets/gradient_button.dart';

class AddTransactionScreen extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType initialType;

  const AddTransactionScreen({
    super.key,
    this.transaction,
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
  bool get _isEditing => widget.transaction != null;

  final List<String> _incomeCategories = ['Salary', 'Bonus', 'Gift', 'Other'];
  final List<String> _savingsCategories = [
    'General Savings',
    'Vacation',
    'New Car',
    'Retirement'
  ];

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      final transaction = widget.transaction!;
      _transactionType = transaction.type;
      _amountController.text = transaction.amount.toString();
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
    } else {
      _transactionType = widget.initialType;
      final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
      final categories = _getCategoriesForType(_transactionType, budgetProvider);
      if (categories.isNotEmpty) {
        _selectedCategory = categories.first;
      }
    }
  }

  List<String> _getCategoriesForType(
      TransactionType type, BudgetProvider budgetProvider) {
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
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
    final notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final navigator = Navigator.of(context);

    final amount = double.parse(_amountController.text);

    if (_transactionType == TransactionType.expense && !_isEditing) {
      final budget = budgetProvider.categoryBudgets[_selectedCategory] ?? 0.0;
      final spent = budgetProvider.allTransactions
          .where((t) =>
              t.category == _selectedCategory &&
              t.type == TransactionType.expense &&
              t.date.month == _selectedDate.month &&
              t.date.year == _selectedDate.year)
          .fold(0.0, (sum, item) => sum + item.amount);
      final remainingBudget = budget - spent;

      if (amount > remainingBudget) {
        final shortfall = amount - remainingBudget;
        final transferDetails = await _showTransferDialog(context, shortfall,
            budgetProvider.savingsByCategory, _selectedCategory!);

        if (transferDetails != null) {
          final transferAmount = transferDetails['amount']!;
          final fromSavingsCategory = transferDetails['category'] as String;

          await budgetProvider.transferFromSavingsToBudget(
              transferAmount, fromSavingsCategory, _selectedCategory!);

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                  'Transferred \$${transferAmount.toStringAsFixed(2)} from $fromSavingsCategory. Transaction added.'),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: const Text('Transaction cancelled due to insufficient budget.'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
          return; // Abort transaction
        }
      }
    }

    if (_transactionType == TransactionType.savings &&
        !_isEditing &&
        amount > budgetProvider.totalBalance) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(
              'Savings cannot exceed available balance of \$${budgetProvider.totalBalance.toStringAsFixed(2)}'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
      return;
    }

    final newTransaction = Transaction(
      id: _isEditing ? widget.transaction!.id : null,
      category: _selectedCategory!,
      amount: amount,
      date: _selectedDate,
      type: _transactionType,
    );

    if (_isEditing) {
      await budgetProvider.updateTransaction(newTransaction);
      if (mounted) {
        navigator.pop(); // Go back after editing
      }
    } else {
      await budgetProvider.addTransaction(newTransaction);
      final typeString = newTransaction.type.toString().split('.').last;
      final capitalizedType = typeString[0].toUpperCase() + typeString.substring(1);
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
    }
    if (!mounted) return;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Transaction ${_isEditing ? 'updated' : 'added'} successfully!'),
        backgroundColor: theme.colorScheme.primary,
      ),
    );

    if (!_isEditing) {
      setState(() {
        _amountController.clear();
        _selectedDate = DateTime.now();
      });
    }
  }

  Future<Map<String, dynamic>?> _showTransferDialog(
      BuildContext context,
      double shortfall,
      Map<String, double> savingsByCategory,
      String toCategory) async {
    final transferAmountController =
        TextEditingController(text: shortfall.toStringAsFixed(2));
    String? selectedSavingsCategory;
    if (savingsByCategory.isNotEmpty) {
      selectedSavingsCategory = savingsByCategory.keys.first;
    }

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final selectedBalance =
                savingsByCategory[selectedSavingsCategory] ?? 0.0;

            String? validateTransferAmount(String text) {
              if (text.isEmpty) return 'Please enter an amount.';
              final amount = double.tryParse(text);
              if (amount == null) return 'Please enter a valid number.';
              if (amount <= 0) return 'Amount must be positive.';
              if (amount > selectedBalance) {
                return 'Exceeds balance of \$${selectedBalance.toStringAsFixed(2)}.';
              }
              if (amount < shortfall) {
                return 'Must cover shortfall of \$${shortfall.toStringAsFixed(2)}.';
              }
              return null;
            }

            return AlertDialog(
              title: Text('Insufficient Budget for $toCategory'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Your budget is short by \$${shortfall.toStringAsFixed(2)}.'),
                  const SizedBox(height: 16),
                  if (savingsByCategory.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedSavingsCategory,
                      items: savingsByCategory.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(
                              '${entry.key}: \$${entry.value.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedSavingsCategory = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Transfer From',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: transferAmountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount to Transfer',
                        prefixText: '\$',
                        errorText: validateTransferAmount(
                            transferAmountController.text),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ] else
                    const Text('You have no savings to transfer from.'),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(ctx).pop(null),
                ),
                if (savingsByCategory.isNotEmpty)
                  ElevatedButton(
                    child: const Text('Transfer'),
                    onPressed: () {
                      final validationError = validateTransferAmount(
                          transferAmountController.text);
                      if (validationError == null) {
                        final amount =
                            double.parse(transferAmountController.text);
                        Navigator.of(ctx).pop({
                          'category': selectedSavingsCategory,
                          'amount': amount,
                        });
                      }
                    },
                  ),
              ],
            );
          },
        );
      },
    );
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
            title: Text(_isEditing
                ? 'Edit Transaction'
                : 'Add ${_transactionType.toString().split('.').last}', style: const TextStyle(color: Colors.white)),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: primaryGradient,
              ),
            ),
            elevation: 0,
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildWideLayout(budgetProvider, categories);
              } else {
                return _buildNarrowLayout(budgetProvider, categories);
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildNarrowLayout(BudgetProvider budgetProvider, List<String> categories) {
    return SingleChildScrollView(
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
            if (_transactionType == TransactionType.savings && !_isEditing)
              _buildSavingsChart(budgetProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout(BudgetProvider budgetProvider, List<String> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildCategoryDropdown(categories),
                  const SizedBox(height: 24),
                  _buildAmountField(),
                  const SizedBox(height: 24),
                  _buildDateField(),
                  const SizedBox(height: 48),
                  _buildSaveButton(),
                ],
              ),
            ),
            if (_transactionType == TransactionType.savings && !_isEditing)
              const SizedBox(width: 24),
            if (_transactionType == TransactionType.savings && !_isEditing)
              Expanded(
                flex: 3,
                child: _buildSavingsChart(budgetProvider),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<String> categories) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
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
    return GradientButton(
      onPressed: _submitTransaction,
      text: _isEditing ? 'Update Transaction' : 'Save Transaction',
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
            color: primaryGradientTop,
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
