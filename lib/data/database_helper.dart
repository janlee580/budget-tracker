import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('budget_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE transactions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category TEXT NOT NULL,
      amount REAL NOT NULL,
      date TEXT NOT NULL,
      type TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE category_budgets(
      category TEXT PRIMARY KEY,
      budget REAL NOT NULL
    )
    ''');
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await instance.database;
    await db.insert('transactions', transaction.toMap());
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final db = await instance.database;
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(int id) async {
    final db = await instance.database;
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => Transaction.fromMap(json)).toList();
  }

  Future<void> updateCategoryBudgets(Map<String, double> budgets) async {
    final db = await instance.database;
    final batch = db.batch();
    batch.delete('category_budgets');
    for (var entry in budgets.entries) {
      batch.insert('category_budgets', {'category': entry.key, 'budget': entry.value});
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, double>> getCategoryBudgets() async {
    final db = await instance.database;
    final result = await db.query('category_budgets');
    return {for (var e in result) e['category'] as String: e['budget'] as double};
  }
  Future<double> calculateTotalIncome() async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
        [TransactionType.income.name]);
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> calculateTotalExpenses() async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
        [TransactionType.expense.name]);
    return (result.first['total'] as double?) ?? 0.0;
  }
  
    Future<double> calculateTotalIncomeThisMonth() async {
    final db = await instance.database;
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();

    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = ? AND strftime('%Y-%m', date) = ?",
      [TransactionType.income.name, '$year-$month'],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> calculateTotalExpensesThisMonth() async {
    final db = await instance.database;
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();

    final result = await db.rawQuery(
      "SELECT SUM(amount) as total FROM transactions WHERE type = ? AND strftime('%Y-%m', date) = ?",
      [TransactionType.expense.name, '$year-$month'],
    );
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<double> calculateTotalSavings() async {
    final db = await instance.database;
    final result = await db.rawQuery(
        'SELECT SUM(amount) as total FROM transactions WHERE type = ?',
        [TransactionType.savings.name]);
    return (result.first['total'] as double?) ?? 0.0;
  }

  Future<void> deleteAllData() async {
    final db = await instance.database;
    await db.delete('transactions');
    await db.delete('category_budgets');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
