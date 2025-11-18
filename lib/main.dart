import 'dart:io';
import 'package:bt/data/models/transaction.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:bt/ui/screens/manage_budget_screen.dart';
import 'package:bt/ui/screens/transaction_history_screen.dart';
import 'package:bt/providers/theme_provider.dart';
import 'package:bt/services/notification_service.dart';
import 'package:bt/ui/screens/summary_screen.dart';
import 'package:bt/ui/themes/app_themes.dart';
import 'package:bt/ui/screens/add_transaction_screen.dart';
import 'package:bt/ui/screens/budget_tracker_home.dart';
import 'package:bt/providers/notification_provider.dart';
import 'package:bt/providers/budget_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Budget Tracker',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateToAddTransactionScreen(
      BuildContext context, TransactionType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => AddTransactionScreen(initialType: type),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        final List<Widget> screens = [
          BudgetTrackerHome(
            onAddTransaction: (type) =>
                _navigateToAddTransactionScreen(context, type),
            onRefresh: budgetProvider.loadData,
          ),
          const ManageBudgetScreen(),
          const SummaryScreen(),
          TransactionHistoryScreen(transactions: budgetProvider.allTransactions),
        ];

        return Scaffold(
          body: budgetProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart), label: 'Budgets'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart), label: 'Summary'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'Transactions'),
            ],
          ),
        );
      },
    );
  }
}
