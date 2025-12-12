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
  var _showSwipeHint = true; // Track if we should show hint

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _checkFirstTimeUser();
  }

  // Check if user has seen the swipe hint before
  void _checkFirstTimeUser() async {
    // In a real app, you'd use SharedPreferences
    // For now, show hint on first expense add
    await Future.delayed(const Duration(seconds: 2));
    if (mounted && _registeredExpenses.isNotEmpty && _showSwipeHint) {
      _showSwipeHintDialog();
    }
  }

  void _showSwipeHintDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.swipe_left, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Quick Tip!'),
          ],
        ),
        content: const Text(
          'Swipe left on any expense to delete it. You\'ll have 4 seconds to undo!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _showSwipeHint = false;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
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

        // Show hint after first expense
        if (_registeredExpenses.length == 1 && _showSwipeHint) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _showSwipeHintDialog();
          });
        }
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
        mainContent = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No expenses yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add your first expense',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      } else {
        mainContent = Column(
          children: [
            // Improved header with stats
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Spending',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${_totalExpenses.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_registeredExpenses.length} ${_registeredExpenses.length == 1 ? 'expense' : 'expenses'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),

            // Chart
            Chart(expenses: _registeredExpenses),

            // Section header for expenses list
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Expenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_registeredExpenses.isNotEmpty)
                    TextButton.icon(
                      onPressed: _showSwipeHintDialog,
                      icon: const Icon(Icons.help_outline, size: 16),
                      label: const Text('Help'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                ],
              ),
            ),

            // Expenses list with improved design
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: _registeredExpenses.length,
                itemBuilder: (ctx, index) {
                  final expense = _registeredExpenses[index];
                  return Dismissible(
                    key: ValueKey(expense.id),
                    background: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (direction) async {
                      // Show a subtle animation hint
                      return true;
                    },
                    onDismissed: (direction) {
                      _removeExpense(expense);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            categoryIcons[expense.category],
                            size: 28,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${expense.category.name.toUpperCase()} • ${expense.formattedDate}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Icon(
                              Icons.chevron_left,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ],
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
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpenseOverlay,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: mainContent,
    );
  }
}
