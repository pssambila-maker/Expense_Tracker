import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/chart.dart';
import 'package:expense_tracker/database_helper.dart';
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
  List<Expense> _registeredExpenses = [];
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  // 1. Load Data from DB with error handling 📤
  void _loadExpenses() async {
    try {
      final data = await DatabaseHelper.loadExpenses();
      setState(() {
        _registeredExpenses = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        _showErrorSnackBar('Failed to load expenses: ${e.toString()}');
      }
    }
  }

  // 2. Add to DB with error handling 📥
  void _addExpense(Expense expense) async {
    try {
      await DatabaseHelper.addExpense(expense);
      setState(() {
        _registeredExpenses.add(expense);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to add expense: ${e.toString()}');
      }
    }
  }

  // 3. Delete from DB with undo functionality 🗑️
  void _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);

    setState(() {
      _registeredExpenses.remove(expense);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Expense deleted'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _registeredExpenses.insert(expenseIndex, expense);
            });
          },
        ),
      ),
    );

    // Wait for undo period before actually deleting from database
    await Future.delayed(const Duration(seconds: 4));

    // Only delete if the expense is still removed from the list
    if (!_registeredExpenses.contains(expense)) {
      try {
        await DatabaseHelper.deleteExpense(expense.id);
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to delete expense: ${e.toString()}');
          // Re-add expense if deletion failed
          setState(() {
            _registeredExpenses.insert(expenseIndex, expense);
          });
        }
      }
    }
  }

  // Helper method to show error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // Calculate total using fold() for cleaner code
  double get _totalExpenses => _registeredExpenses.fold(
    0.0,
    (sum, expense) => sum + expense.amount,
  );

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => NewExpense(onAddExpense: _addExpense),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = const Center(child: CircularProgressIndicator());

    if (!_isLoading) {
      if (_registeredExpenses.isEmpty) {
        mainContent = const Center(
          child: Text(
            'No expenses found. Start adding some!',
            style: TextStyle(fontSize: 16),
          ),
        );
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
                itemBuilder: (ctx, index) {
                  final expense = _registeredExpenses[index];
                  return Dismissible(
                    key: ValueKey(expense.id),
                    background: Container(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.75),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _removeExpense(expense);
                    },
                    child: Card(
                      child: ListTile(
                        leading: Icon(
                          categoryIcons[expense.category],
                          size: 32,
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${expense.category.name.toUpperCase()} • ${expense.formattedDate}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        trailing: Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('WiseSteward'),
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
