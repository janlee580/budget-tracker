import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bt/data/models/transaction.dart';
import 'package:bt/ui/themes/app_colors.dart';
import 'package:bt/providers/budget_provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  SummaryScreenState createState() => SummaryScreenState();
}

class SummaryScreenState extends State<SummaryScreen> {
  String? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final allTransactions = budgetProvider.allTransactions;

        final availableMonths = allTransactions
            .map((t) => DateFormat('yyyy-MM').format(t.date))
            .toSet()
            .toList();
        availableMonths.sort((a, b) => b.compareTo(a)); // Sort descending
        final dropdownMonths = ['Overall Summary', ...availableMonths];

        List<Transaction> filteredTransactions;
        if (_selectedMonth == null || _selectedMonth == 'Overall Summary') {
          filteredTransactions = allTransactions;
        } else {
          filteredTransactions = allTransactions.where((t) {
            return DateFormat('yyyy-MM').format(t.date) == _selectedMonth;
          }).toList();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Summary'),
            actions: [
              if (dropdownMonths.length > 1)
                DropdownButton<String>(
                  value: _selectedMonth ?? 'Overall Summary',
                  items: dropdownMonths.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'Overall Summary'
                            ? 'Overall Summary'
                            : DateFormat('MMM yyyy').format(DateFormat('yyyy-MM').parse(value)),
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonth = value;
                    });
                  },
                  underline: Container(), // Remove underline
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 600;
              return isWide
                  ? _buildWideLayout(context, filteredTransactions)
                  : _buildNarrowLayout(context, filteredTransactions);
            },
          ),
        );
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context, List<Transaction> transactions) {
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        _buildSummaryHeader(context, transactions),
        const SizedBox(height: 24),
        _buildSavingsBarChartCard(context, transactions),
        const SizedBox(height: 24),
        _buildExpensePieChartCard(context, transactions),
        const SizedBox(height: 24),
        _buildSpendingLineChartCard(context, transactions),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, List<Transaction> transactions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildSummaryHeader(context, transactions),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _buildSavingsBarChartCard(context, transactions),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: _buildExpensePieChartCard(context, transactions),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSpendingLineChartCard(context, transactions),
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(BuildContext context, List<Transaction> recentTransactions) {
    final theme = Theme.of(context);
    final totalExpenses = recentTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, item) => sum + item.amount);
    final totalSavings = recentTransactions
        .where((t) => t.type == TransactionType.savings)
        .fold(0.0, (sum, item) => sum + item.amount);

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.secondary.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Total Expenses', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('\$${totalExpenses.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('Total Savings', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text('\$${totalSavings.toStringAsFixed(2)}',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsBarChartCard(BuildContext context, List<Transaction> transactions) {
    final theme = Theme.of(context);
    final savingsTransactions = transactions.where((t) => t.type == TransactionType.savings).toList();

    if (savingsTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, double> monthlySavings = {};
    for (var transaction in savingsTransactions) {
      final month = DateFormat('yyyy-MM').format(transaction.date);
      monthlySavings.update(month, (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    final sortedMonths = monthlySavings.keys.toList()..sort();
    final barGroups = sortedMonths.asMap().entries.map((entry) {
      final index = entry.key;
      final month = entry.value;
      final total = monthlySavings[month]!;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            color: secondaryBlue,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.secondary.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Monthly Savings",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final month = sortedMonths[group.x.toInt()];
                        final formattedMonth = DateFormat('MMM yyyy').format(DateFormat('yyyy-MM').parse(month));
                        return BarTooltipItem(
                          '$formattedMonth\n',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          children: <TextSpan>[
                            TextSpan(
                              text: '\$${rod.toY.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedMonths.length) {
                            final month = sortedMonths[index];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Text(DateFormat('MMM').format(DateFormat('yyyy-MM').parse(month)),
                                  style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: true, border: Border.all(color: lightGrey)),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePieChartCard(BuildContext context, List<Transaction> recentTransactions) {
    final theme = Theme.of(context);
    final expenseTransactions =
        recentTransactions.where((t) => t.type == TransactionType.expense).toList();

    if (expenseTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, double> expenseByCategory = {};
    for (var transaction in expenseTransactions) {
      expenseByCategory.update(transaction.category, (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    final List<Color> pieChartColors = [
      primaryGreen,
      secondaryBlue,
      warningRed,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.teal,
      Colors.pinkAccent,
    ];

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.secondary.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Expense Breakdown",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                return constraints.maxWidth < 200
                    ? _buildCompactPieChart(expenseByCategory, pieChartColors)
                    : _buildStandardPieChart(expenseByCategory, pieChartColors);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactPieChart(Map<String, double> data, List<Color> colors) {
    return _buildLegend(data, colors);
  }

  Widget _buildStandardPieChart(Map<String, double> data, List<Color> colors) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 150,
            child: PieChart(
              PieChartData(
                sections: data.entries.map((entry) {
                  final index = data.keys.toList().indexOf(entry.key);
                  return PieChartSectionData(
                    color: colors[index % colors.length],
                    value: entry.value,
                    title: '',
                    radius: 50,
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildLegend(data, colors),
        ),
      ],
    );
  }

  Widget _buildLegend(Map<String, double> data, List<Color> colors) {
    final totalExpense = data.values.fold(0.0, (sum, amount) => sum + amount);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map((entry) {
        final index = data.keys.toList().indexOf(entry.key);
        final percentage = (entry.value / totalExpense) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${entry.key} (${percentage.toStringAsFixed(1)}%)',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSpendingLineChartCard(BuildContext context, List<Transaction> recentTransactions) {
    final theme = Theme.of(context);
    final expenseTransactions =
        recentTransactions.where((t) => t.type == TransactionType.expense).toList();

    if (expenseTransactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<DateTime, double> dailyExpenses = {};
    for (var transaction in expenseTransactions) {
      final day = DateTime(transaction.date.year, transaction.date.month, transaction.date.day);
      dailyExpenses.update(day, (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount);
    }

    final sortedDays = dailyExpenses.keys.toList()..sort();
    final spots = sortedDays.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), dailyExpenses[entry.value]!);
    }).toList();

    if (spots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.secondary.withAlpha(26),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Spending Trend",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: (sortedDays.length / 5).ceil().toDouble(),
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedDays.length) {
                            final day = sortedDays[index];
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 8.0,
                              child: Text(DateFormat('d MMM').format(day),
                                  style: const TextStyle(fontSize: 10)),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                      show: true, border: Border.all(color: lightGrey)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: primaryGreen,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: primaryGreen.withAlpha(77),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
