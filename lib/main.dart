import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/chart.dart'; 
import 'package:expense_tracker/database_helper.dart'; // <--- Import the Helper!
import 'new_expense.dart';

// 1. Light Mode Seed (Purple) 🟣
var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 96, 59, 181),
);

// 2. Dark Mode Seed (Dark Blue) 🌙
var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 5, 99, 125),
);

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        cardTheme: CardThemeData(
          color: kDarkColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkColorScheme.primaryContainer,
            foregroundColor: kDarkColorScheme.onPrimaryContainer,
          ),
        ),
      ),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: kColorScheme.onPrimaryContainer,
          foregroundColor: kColorScheme.primaryContainer,
        ),
        cardTheme: CardThemeData(
          color: kColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primaryContainer,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: kColorScheme.onSecondaryContainer,
            fontSize: 16,
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Start with an empty list (we will load data in a second!)
  List<Expense> _registeredExpenses = []; 
  var _isLoading = true; // To show a spinner while loading

  @override
  void initState() {
    super.initState();
    _loadExpenses(); // <--- Trigger the load when app starts
  }

  // 1. Load Data from DB 📤
  void _loadExpenses() async {
    final data = await DatabaseHelper.loadExpenses();
    setState(() {
      _registeredExpenses = data;
      _isLoading = false;
    });
  }

  // 2. Add to DB 📥
  void _addExpense(Expense expense) async {
    await DatabaseHelper.addExpense(expense); // Save to disk
    setState(() {
      _registeredExpenses.add(expense); // Update UI
    });
  }

  // 3. Delete from DB 🗑️
  void _removeExpense(Expense expense) async {
    await DatabaseHelper.deleteExpense(expense.id); // Delete from disk
    setState(() {
      _registeredExpenses.remove(expense); // Update UI
    });
    
    // Optional: Add Undo logic here later if we want!
  }

  double get _totalExpenses {
    double sum = 0;
    for (final expense in _registeredExpenses) {
      sum += expense.amount;
    }
    return sum;
  }

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading spinner if we are still fetching data
    Widget mainContent = const Center(child: CircularProgressIndicator());

    if (!_isLoading) {
      if (_registeredExpenses.isEmpty) {
        mainContent = const Center(child: Text('No expenses found. Start adding some!'));
      } else {
        mainContent = Column(
          children: [
            Chart(expenses: _registeredExpenses),
            Card(
              margin: const EdgeInsets.all(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Total Spent: \$${_totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _registeredExpenses.length,
                itemBuilder: (ctx, index) => Dismissible(
                  key: ValueKey(_registeredExpenses[index].id),
                  onDismissed: (direction) {
                    _removeExpense(_registeredExpenses[index]);
                  },
                  child: ListTile(
                    leading: Icon(categoryIcons[_registeredExpenses[index].category]),
                    title: Text(_registeredExpenses[index].title),
                    trailing: Text(
                      '\$${_registeredExpenses[index].amount.toStringAsFixed(2)}',
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddExpenseOverlay,
        child: const Icon(Icons.add),
      ),
      body: mainContent,
    );
  }
}