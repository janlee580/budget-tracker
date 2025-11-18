import 'package:flutter/material.dart';
import 'package:bt/data/database_helper.dart';
import 'package:bt/data/models/transaction.dart';

class BudgetProvider with ChangeNotifier {
  Map<String, double> _categoryBudgets = {};
  List<Transaction> _allTransactions = [];
  double _totalSavings = 0.0;
  double _totalBalance = 0.0;
  double _totalIncomeThisMonth = 0.0;
  double _totalExpensesThisMonth = 0.0;
  bool _isLoading = true;

  Map<String, double> get categoryBudgets => _categoryBudgets;
  List<Transaction> get allTransactions => _allTransactions;
  double get totalSavings => _totalSavings;
  double get totalBalance => _totalBalance;
  double get totalIncomeThisMonth => _totalIncomeThisMonth;
  double get totalExpensesThisMonth => _totalExpensesThisMonth;
  bool get isLoading => _isLoading;

  BudgetProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final dbHelper = DatabaseHelper.instance;
    _allTransactions = (await dbHelper.getTransactions()).cast<Transaction>().toList();
    _categoryBudgets = await dbHelper.getCategoryBudgets();
    _totalSavings = await dbHelper.calculateTotalSavings();

    final totalIncome = await dbHelper.calculateTotalIncome();
    final totalExpenses = await dbHelper.calculateTotalExpenses();
    _totalBalance = totalIncome - totalExpenses - _totalSavings;
    _totalIncomeThisMonth = await dbHelper.calculateTotalIncomeThisMonth();
    _totalExpensesThisMonth = await dbHelper.calculateTotalExpensesThisMonth();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await DatabaseHelper.instance.insertTransaction(transaction);
    await loadData();
  }

  Future<void> updateCategoryBudgets(Map<String, double> newBudgets) async {
    await DatabaseHelper.instance.updateCategoryBudgets(newBudgets);
    await loadData();
  }
}
