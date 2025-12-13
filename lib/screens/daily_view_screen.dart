import 'package:flutter/material.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/utils/database_helper.dart';
import 'package:expense_tracker/widgets/chart.dart';
import 'package:intl/intl.dart';

class DailyViewScreen extends StatefulWidget {
  const DailyViewScreen({super.key});

  @override
  State<DailyViewScreen> createState() => _DailyViewScreenState();
}

enum ViewMode { day, week }

class _DailyViewScreenState extends State<DailyViewScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Expense> _dayExpenses = [];
  List<Expense> _weekExpenses = [];
  bool _isLoading = true;
  ViewMode _viewMode = ViewMode.day;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    if (_viewMode == ViewMode.day) {
      await _loadExpensesForSelectedDay();
    } else {
      await _loadExpensesForSelectedWeek();
    }
  }

  Future<void> _loadExpensesForSelectedDay() async {
    setState(() => _isLoading = true);

    try {
      final expenses = await DatabaseHelper.loadExpensesForDay(_selectedDate);
      setState(() {
        _dayExpenses = expenses;
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

  Future<void> _loadExpensesForSelectedWeek() async {
    setState(() => _isLoading = true);

    try {
      final startOfWeek = _getStartOfWeek(_selectedDate);
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      final expenses = await DatabaseHelper.loadExpensesForDateRange(
        startOfWeek,
        endOfWeek,
      );
      setState(() {
        _weekExpenses = expenses;
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

  DateTime _getStartOfWeek(DateTime date) {
    // Get Monday of the week (weekday 1 = Monday, 7 = Sunday)
    final dayOfWeek = date.weekday;
    return date.subtract(Duration(days: dayOfWeek - 1));
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _loadExpenses();
    }
  }

  void _goToPrevious() {
    setState(() {
      if (_viewMode == ViewMode.day) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      } else {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      }
    });
    _loadExpenses();
  }

  void _goToNext() {
    final next = _viewMode == ViewMode.day
        ? _selectedDate.add(const Duration(days: 1))
        : _selectedDate.add(const Duration(days: 7));

    if (next.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      setState(() {
        _selectedDate = next;
      });
      _loadExpenses();
    }
  }

  double get _totalAmount {
    final expenses = _viewMode == ViewMode.day ? _dayExpenses : _weekExpenses;
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  List<Expense> get _currentExpenses {
    return _viewMode == ViewMode.day ? _dayExpenses : _weekExpenses;
  }

  Map<String, List<Expense>> get _expensesByDay {
    if (_viewMode != ViewMode.week) return {};

    final Map<String, List<Expense>> grouped = {};
    final startOfWeek = _getStartOfWeek(_selectedDate);

    for (int i = 0; i < 7; i++) {
      final day = startOfWeek.add(Duration(days: i));
      final dayKey = DateFormat('yyyy-MM-dd').format(day);
      grouped[dayKey] = [];
    }

    for (var expense in _weekExpenses) {
      final dayKey = DateFormat('yyyy-MM-dd').format(expense.date);
      if (grouped.containsKey(dayKey)) {
        grouped[dayKey]!.add(expense);
      }
    }

    return grouped;
  }

  double _getTotalForDay(String dayKey) {
    final expenses = _expensesByDay[dayKey] ?? [];
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  @override
  Widget build(BuildContext context) {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    final startOfWeek = _getStartOfWeek(_selectedDate);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return Scaffold(
      appBar: AppBar(
        title: Text(_viewMode == ViewMode.day ? 'Daily View' : 'Week View'),
        actions: [
          SegmentedButton<ViewMode>(
            segments: const [
              ButtonSegment<ViewMode>(
                value: ViewMode.day,
                label: Text('Day'),
                icon: Icon(Icons.calendar_today, size: 16),
              ),
              ButtonSegment<ViewMode>(
                value: ViewMode.week,
                label: Text('Week'),
                icon: Icon(Icons.view_week, size: 16),
              ),
            ],
            selected: {_viewMode},
            onSelectionChanged: (Set<ViewMode> newSelection) {
              setState(() {
                _viewMode = newSelection.first;
              });
              _loadExpenses();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Date Selector Card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _goToPrevious,
                      ),
                      InkWell(
                        onTap: _selectDate,
                        child: Row(
                          children: [
                            Icon(
                              _viewMode == ViewMode.day
                                  ? Icons.calendar_today
                                  : Icons.view_week,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _viewMode == ViewMode.day
                                  ? DateFormat.yMMMMd().format(_selectedDate)
                                  : '${DateFormat.MMMd().format(startOfWeek)} - ${DateFormat.MMMd().format(endOfWeek)}',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(width: 4),
                            if (isToday && _viewMode == ViewMode.day)
                              Chip(
                                label: const Text('Today'),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primaryContainer,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: isToday && _viewMode == ViewMode.day
                            ? null
                            : _goToNext,
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
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
                        children: [
                          Text(
                            'Expenses',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${_currentExpenses.length}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (_viewMode == ViewMode.week)
                        Column(
                          children: [
                            Text(
                              'Daily Avg',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              '\$${(_totalAmount / 7).toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Chart
          if (_currentExpenses.isNotEmpty) Chart(expenses: _currentExpenses),

          // Content based on view mode
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _currentExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _viewMode == ViewMode.day
                                  ? 'No expenses for this day'
                                  : 'No expenses for this week',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : _viewMode == ViewMode.day
                        ? _buildDayView()
                        : _buildWeekView(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayView() {
    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: ListView.builder(
        itemCount: _dayExpenses.length,
        itemBuilder: (ctx, index) {
          final expense = _dayExpenses[index];
          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  categoryIcons[expense.category],
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(expense.title),
              subtitle: Text(
                expense.category.name.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
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
    );
  }

  Widget _buildWeekView() {
    final startOfWeek = _getStartOfWeek(_selectedDate);
    final expensesByDay = _expensesByDay;

    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: ListView.builder(
        itemCount: 7,
        itemBuilder: (ctx, index) {
          final day = startOfWeek.add(Duration(days: index));
          final dayKey = DateFormat('yyyy-MM-dd').format(day);
          final dayExpenses = expensesByDay[dayKey] ?? [];
          final dayTotal = _getTotalForDay(dayKey);
          final isToday = day.year == DateTime.now().year &&
              day.month == DateTime.now().month &&
              day.day == DateTime.now().day;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: isToday ? 4 : 1,
            color: isToday
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                : null,
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: isToday
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  DateFormat.E().format(day).substring(0, 1),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isToday
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Text(
                    DateFormat.MMMd().format(day),
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isToday) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: const Text('Today', style: TextStyle(fontSize: 10)),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                '${dayExpenses.length} expense${dayExpenses.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              trailing: Text(
                '\$${dayTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
              ),
              children: dayExpenses.isEmpty
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No expenses',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    ]
                  : dayExpenses.map((expense) {
                      return ListTile(
                        dense: true,
                        leading: Icon(
                          categoryIcons[expense.category],
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(expense.title),
                        subtitle: Text(
                          expense.category.name.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: Text(
                          '\$${expense.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    }).toList(),
            ),
          );
        },
      ),
    );
  }
}
