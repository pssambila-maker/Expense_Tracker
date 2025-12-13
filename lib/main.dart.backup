import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/chart.dart';
import 'package:expense_tracker/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
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
  List<Expense> _filteredExpenses = [];
  var _isLoading = true;
  var _showSwipeHint = true;

  // Filter states
  Category? _selectedCategoryFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadPreferences();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load user preferences
  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showSwipeHint = prefs.getBool('showSwipeHint') ?? true;
    });
  }

  // Save swipe hint preference
  void _saveSwipeHintPreference(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showSwipeHint', show);
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
              _saveSwipeHintPreference(false);
              Navigator.pop(ctx);
            },
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  // 1. Load Data from DB with error handling 📤
  Future<void> _loadExpenses() async {
    try {
      final data = await DatabaseHelper.loadExpenses();
      setState(() {
        _registeredExpenses = data;
        _applyFilters();
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

  // Apply filters to expense list
  void _applyFilters() {
    _filteredExpenses = _registeredExpenses.where((expense) {
      // Category filter
      if (_selectedCategoryFilter != null && expense.category != _selectedCategoryFilter) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty &&
          !expense.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      return true;
    }).toList();
  }

  // 2. Add or Update expense
  void _saveExpense(Expense expense) async {
    final existingIndex = _registeredExpenses.indexWhere((e) => e.id == expense.id);

    try {
      if (existingIndex >= 0) {
        // Update existing expense
        await DatabaseHelper.updateExpense(expense);
        setState(() {
          _registeredExpenses[existingIndex] = expense;
          _applyFilters();
        });
        if (mounted) {
          _hapticFeedback();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense updated successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        // Add new expense
        await DatabaseHelper.addExpense(expense);
        setState(() {
          _registeredExpenses.add(expense);
          _applyFilters();
        });
        if (mounted) {
          _hapticFeedback();
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
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save expense: ${e.toString()}');
      }
    }
  }

  // 3. Delete from DB with undo functionality 🗑️
  void _removeExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);

    setState(() {
      _registeredExpenses.remove(expense);
      _applyFilters();
    });

    _hapticFeedback();

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
              _applyFilters();
            });
          },
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 4));

    if (!_registeredExpenses.contains(expense)) {
      try {
        await DatabaseHelper.deleteExpense(expense.id);
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Failed to delete expense: ${e.toString()}');
          setState(() {
            _registeredExpenses.insert(expenseIndex, expense);
            _applyFilters();
          });
        }
      }
    }
  }

  // Show options menu for expense
  void _showExpenseOptions(Expense expense) {
    _hapticFeedback();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(ctx);
              _openEditExpenseOverlay(expense);
            },
          ),
          ListTile(
            leading: const Icon(Icons.content_copy),
            title: const Text('Duplicate'),
            onTap: () {
              Navigator.pop(ctx);
              _duplicateExpense(expense);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            title: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () {
              Navigator.pop(ctx);
              _removeExpense(expense);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Duplicate expense
  void _duplicateExpense(Expense expense) {
    _saveExpense(Expense(
      title: '${expense.title} (Copy)',
      amount: expense.amount,
      date: DateTime.now(),
      category: expense.category,
    ));
  }

  // Export to CSV
  Future<void> _exportToCSV() async {
    try {
      List<List<dynamic>> rows = [
        ['Date', 'Title', 'Category', 'Amount'],
      ];

      for (var expense in _registeredExpenses) {
        rows.add([
          expense.formattedDate,
          expense.title,
          expense.category.name.toUpperCase(),
          expense.amount.toStringAsFixed(2),
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/expenses_export.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles(
        [XFile(path)],
        text: 'My Expenses',
      );

      if (mounted) {
        _hapticFeedback();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expenses exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to export: ${e.toString()}');
      }
    }
  }

  // Haptic feedback
  void _hapticFeedback() {
    HapticFeedback.lightImpact();
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

  // Calculate total
  double get _totalExpenses => _filteredExpenses.fold(
    0.0,
    (sum, expense) => sum + expense.amount,
  );

  void _openAddExpenseOverlay() {
    _hapticFeedback();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => NewExpense(onSaveExpense: _saveExpense),
    );
  }

  void _openEditExpenseOverlay(Expense expense) {
    _hapticFeedback();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => NewExpense(
        onSaveExpense: _saveExpense,
        expenseToEdit: expense,
      ),
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
        mainContent = RefreshIndicator(
          onRefresh: _loadExpenses,
          child: Column(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategoryFilter != null
                              ? '${_selectedCategoryFilter!.name.toUpperCase()} Total'
                              : 'Total Spending',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download, size: 20),
                          onPressed: _exportToCSV,
                          tooltip: 'Export to CSV',
                        ),
                      ],
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
                      '${_filteredExpenses.length} ${_filteredExpenses.length == 1 ? 'expense' : 'expenses'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),

              // Chart
              if (_filteredExpenses.isNotEmpty)
                Chart(expenses: _filteredExpenses),

              // Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _selectedCategoryFilter == null,
                      onSelected: (selected) {
                        _hapticFeedback();
                        setState(() {
                          _selectedCategoryFilter = null;
                          _applyFilters();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ...Category.values.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          avatar: Icon(categoryIcons[category], size: 18),
                          label: Text(category.name.toUpperCase()),
                          selected: _selectedCategoryFilter == category,
                          onSelected: (selected) {
                            _hapticFeedback();
                            setState(() {
                              _selectedCategoryFilter = selected ? category : null;
                              _applyFilters();
                            });
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Section header for expenses list
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _filteredExpenses.isEmpty ? 'No Results' : 'Recent Expenses',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

              // Expenses list
              Expanded(
                child: _filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No expenses match your filters',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _filteredExpenses.length,
                        itemBuilder: (ctx, index) {
                          final expense = _filteredExpenses[index];
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
                              return true;
                            },
                            onDismissed: (direction) {
                              _removeExpense(expense);
                            },
                            child: InkWell(
                              onLongPress: () => _showExpenseOptions(expense),
                              onTap: () => _openEditExpenseOverlay(expense),
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
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search expenses...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white60),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _applyFilters();
                  });
                },
              )
            : const Text('WiseSteward'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _applyFilters();
                }
              });
            },
          ),
        ],
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
