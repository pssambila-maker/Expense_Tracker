import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/utils/database_helper.dart';
import 'package:expense_tracker/widgets/new_expense.dart';
import 'package:expense_tracker/widgets/chart.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  List<Expense> _registeredExpenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = true;

  // Filter states
  Category? _selectedCategoryFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);

    try {
      final expenses = await DatabaseHelper.loadExpenses();
      setState(() {
        _registeredExpenses = expenses;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading expenses: $e')),
        );
      }
    }
  }

  void _applyFilters() {
    _filteredExpenses = _registeredExpenses.where((expense) {
      // Category filter
      if (_selectedCategoryFilter != null &&
          expense.category != _selectedCategoryFilter) {
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

  void _openAddExpenseOverlay() {
    _hapticFeedback();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => NewExpense(onSaveExpense: _saveExpense),
    );
  }

  void _openEditExpenseOverlay(Expense expense) {
    _hapticFeedback();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => NewExpense(
        onSaveExpense: _saveExpense,
        expenseToEdit: expense,
      ),
    );
  }

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
            title: Text('Delete',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () {
              Navigator.pop(ctx);
              _deleteExpense(expense);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _saveExpense(Expense expense) async {
    final existingIndex = _registeredExpenses.indexWhere((e) => e.id == expense.id);

    try {
      if (existingIndex >= 0) {
        // Update
        await DatabaseHelper.updateExpense(expense);
        setState(() {
          _registeredExpenses[existingIndex] = expense;
          _applyFilters();
        });
        if (mounted) {
          _hapticFeedback();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense updated!')),
          );
        }
      } else {
        // Add new
        await DatabaseHelper.addExpense(expense);
        setState(() {
          _registeredExpenses.add(expense);
          _applyFilters();
        });
        if (mounted) {
          _hapticFeedback();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Expense added!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving expense: $e')),
        );
      }
    }
  }

  Future<void> _deleteExpense(Expense expense) async {
    final expenseIndex = _registeredExpenses.indexOf(expense);

    setState(() {
      _registeredExpenses.remove(expense);
      _applyFilters();
    });

    _hapticFeedback();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            content: const Text('Expense deleted'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  _registeredExpenses.insert(expenseIndex, expense);
                  _applyFilters();
                });
              },
            ),
          ),
        )
        .closed
        .then((reason) async {
      if (reason != SnackBarClosedReason.action) {
        try {
          await DatabaseHelper.deleteExpense(expense.id);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error deleting expense: $e')),
            );
          }
        }
      }
    });
  }

  void _duplicateExpense(Expense expense) async {
    _hapticFeedback();
    final duplicated = Expense(
      title: '${expense.title} (Copy)',
      amount: expense.amount,
      date: DateTime.now(),
      category: expense.category,
    );

    try {
      await DatabaseHelper.addExpense(duplicated);
      setState(() {
        _registeredExpenses.add(duplicated);
        _applyFilters();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense duplicated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error duplicating expense: $e')),
        );
      }
    }
  }

  void _hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  double get _totalAmount {
    return _filteredExpenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
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
            : const Text('All Expenses'),
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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _openAddExpenseOverlay,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Summary Card
                if (_filteredExpenses.isNotEmpty)
                  Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '\$${_totalAmount.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Expenses',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                '${_filteredExpenses.length}',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Chart
                if (_filteredExpenses.isNotEmpty)
                  Chart(expenses: _filteredExpenses),

                // Category Filters
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

                // Expenses List
                Expanded(
                  child: _filteredExpenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isNotEmpty ||
                                        _selectedCategoryFilter != null
                                    ? Icons.search_off
                                    : Icons.receipt_long_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty ||
                                        _selectedCategoryFilter != null
                                    ? 'No expenses found'
                                    : 'No expenses yet. Start adding some!',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadExpenses,
                          child: ListView.builder(
                            itemCount: _filteredExpenses.length,
                            itemBuilder: (ctx, index) {
                              final expense = _filteredExpenses[index];
                              return Dismissible(
                                key: ValueKey(expense.id),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _deleteExpense(expense),
                                background: Container(
                                  color: Theme.of(context).colorScheme.error,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete,
                                          color: Colors.white, size: 32),
                                      SizedBox(height: 4),
                                      Text('Delete',
                                          style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                child: InkWell(
                                  onLongPress: () => _showExpenseOptions(expense),
                                  onTap: () => _openEditExpenseOverlay(expense),
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardTheme.color,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        child: Icon(
                                          categoryIcons[expense.category],
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      title: Text(expense.title),
                                      subtitle: Text(
                                        '${expense.category.name.toUpperCase()} • ${expense.formattedDate}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '\$${expense.amount.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.chevron_left, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpenseOverlay,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
