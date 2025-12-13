import 'dart:io';
import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/utils/database_helper.dart';
import 'package:expense_tracker/widgets/chart.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Expense> _expenses = [];
  bool _isLoading = true;

  // For monthly view
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // For yearly view
  int _selectedYearForYearly = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_loadData);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      List<Expense> expenses;
      if (_tabController.index == 0) {
        // Monthly
        expenses = await DatabaseHelper.loadExpensesForMonth(
          _selectedYear,
          _selectedMonth,
        );
      } else {
        // Yearly
        expenses = await DatabaseHelper.loadExpensesForYear(_selectedYearForYearly);
      }

      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  double get _totalAmount {
    return _expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double get _averageDaily {
    if (_expenses.isEmpty) return 0;
    if (_tabController.index == 0) {
      // Monthly - days in month
      final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
      return _totalAmount / daysInMonth;
    } else {
      // Yearly - 365 days
      return _totalAmount / 365;
    }
  }

  Future<void> _exportToCSV() async {
    try {
      List<List<dynamic>> rows = [
        ['Date', 'Title', 'Category', 'Amount'],
      ];

      for (var expense in _expenses) {
        rows.add([
          expense.formattedDate,
          expense.title,
          expense.category.name.toUpperCase(),
          expense.amount.toStringAsFixed(2),
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final period = _tabController.index == 0
          ? '${DateFormat('MMMM_yyyy').format(DateTime(_selectedYear, _selectedMonth))}'
          : '$_selectedYearForYearly';
      final path = '${directory.path}/expenses_$period.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: 'Expenses Report for $period');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _expenses.isEmpty ? null : _exportToCSV,
            tooltip: 'Export CSV',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Monthly'),
            Tab(text: 'Yearly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonthlyView(),
          _buildYearlyView(),
        ],
      ),
    );
  }

  Widget _buildMonthlyView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) {
      return Column(
        children: [
          // Month/Year Selector
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        if (_selectedMonth == 1) {
                          _selectedMonth = 12;
                          _selectedYear--;
                        } else {
                          _selectedMonth--;
                        }
                      });
                      _loadData();
                    },
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(
                      DateTime(_selectedYear, _selectedMonth),
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      final now = DateTime.now();
                      if (_selectedYear < now.year ||
                          (_selectedYear == now.year && _selectedMonth < now.month)) {
                        setState(() {
                          if (_selectedMonth == 12) {
                            _selectedMonth = 1;
                            _selectedYear++;
                          } else {
                            _selectedMonth++;
                          }
                        });
                        _loadData();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses for this period',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Month/Year Selector
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      if (_selectedMonth == 1) {
                        _selectedMonth = 12;
                        _selectedYear--;
                      } else {
                        _selectedMonth--;
                      }
                    });
                    _loadData();
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(
                    DateTime(_selectedYear, _selectedMonth),
                  ),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    final now = DateTime.now();
                    if (_selectedYear < now.year ||
                        (_selectedYear == now.year && _selectedMonth < now.month)) {
                      setState(() {
                        if (_selectedMonth == 12) {
                          _selectedMonth = 1;
                          _selectedYear++;
                        } else {
                          _selectedMonth++;
                        }
                      });
                      _loadData();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        _buildSummaryCards(),
        Chart(expenses: _expenses),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildCategoryBreakdown(),
                  _buildExpensesList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearlyView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_expenses.isEmpty) {
      return Column(
        children: [
          // Year Selector
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        _selectedYearForYearly--;
                      });
                      _loadData();
                    },
                  ),
                  Text(
                    '$_selectedYearForYearly',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _selectedYearForYearly < DateTime.now().year
                        ? () {
                            setState(() {
                              _selectedYearForYearly++;
                            });
                            _loadData();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses for this period',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Year Selector
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedYearForYearly--;
                    });
                    _loadData();
                  },
                ),
                Text(
                  '$_selectedYearForYearly',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _selectedYearForYearly < DateTime.now().year
                      ? () {
                          setState(() {
                            _selectedYearForYearly++;
                          });
                          _loadData();
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
        _buildSummaryCards(),
        Chart(expenses: _expenses),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildCategoryBreakdown(),
                  _buildExpensesList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Map<Category, double> get _categoryBreakdown {
    Map<Category, double> breakdown = {};
    for (var expense in _expenses) {
      breakdown[expense.category] = (breakdown[expense.category] ?? 0) + expense.amount;
    }
    return breakdown;
  }

  Category? get _topCategory {
    if (_expenses.isEmpty) return null;
    final breakdown = _categoryBreakdown;
    return breakdown.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  Widget _buildSummaryCards() {
    final topCategory = _topCategory;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '\$${_totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Avg/Day',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '\$${_averageDaily.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Count',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '${_expenses.length}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (topCategory != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          categoryIcons[topCategory],
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Top Category',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              topCategory.name.toUpperCase(),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '\$${_categoryBreakdown[topCategory]!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    if (_expenses.isEmpty) return const SizedBox.shrink();

    final breakdown = _categoryBreakdown;
    final sortedEntries = breakdown.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              final percentage = (entry.value / _totalAmount * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              categoryIcons[entry.key],
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key.name.toUpperCase(),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '\$${entry.value.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    if (_expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'All Expenses',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _expenses.length,
          itemBuilder: (ctx, index) {
            final expense = _expenses[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                leading: Icon(
                  categoryIcons[expense.category],
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(expense.title),
                subtitle: Text(expense.formattedDate),
                trailing: Text(
                  '\$${expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
