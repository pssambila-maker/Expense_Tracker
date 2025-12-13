import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:expense_tracker/models/expense.dart';

class DatabaseHelper {
  // 1. Open the Database (and create table if needed) 📂
  static Future<sql.Database> _getDB() async {
    try {
      final dbPath = await sql.getDatabasesPath();
      return sql.openDatabase(
        path.join(dbPath, 'expenses.db'),
        onCreate: (db, version) {
          return db.execute(
            'CREATE TABLE user_expenses(id TEXT PRIMARY KEY, title TEXT, amount REAL, date TEXT, category TEXT)',
          );
        },
        version: 1,
      );
    } catch (e) {
      throw Exception('Failed to open database: $e');
    }
  }

  // 2. Save an Expense 📥
  static Future<void> addExpense(Expense expense) async {
    try {
      final db = await _getDB();
      await db.insert(
        'user_expenses',
        {
          'id': expense.id,
          'title': expense.title,
          'amount': expense.amount,
          'date': expense.date.toIso8601String(), // Convert Date to String
          'category': expense.category.name,       // Convert Enum to String
        },
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to add expense: $e');
    }
  }

  // 3. Load All Expenses 📤
  static Future<List<Expense>> loadExpenses() async {
    try {
      final db = await _getDB();
      final data = await db.query('user_expenses');

      return data.map((row) {
        return Expense(
          // We have to recreate the Expense object from the raw data
          id: row['id'] as String, // Use the ID from database!
          title: row['title'] as String,
          amount: row['amount'] as double,
          date: DateTime.parse(row['date'] as String), // String -> Date
          category: Category.values.firstWhere(
            (c) => c.name == row['category'], // String -> Enum
          ),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load expenses: $e');
    }
  }

  // 4. Update an Expense ✏️
  static Future<void> updateExpense(Expense expense) async {
    try {
      final db = await _getDB();
      await db.update(
        'user_expenses',
        {
          'title': expense.title,
          'amount': expense.amount,
          'date': expense.date.toIso8601String(),
          'category': expense.category.name,
        },
        where: 'id = ?',
        whereArgs: [expense.id],
      );
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  // 5. Delete an Expense 🗑️
  static Future<void> deleteExpense(String id) async {
    try {
      final db = await _getDB();
      await db.delete('user_expenses', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  // 6. Load Expenses for a Specific Day 📅
  static Future<List<Expense>> loadExpensesForDay(DateTime date) async {
    try {
      final db = await _getDB();
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final data = await db.query(
        'user_expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
        orderBy: 'date DESC',
      );

      return data.map((row) {
        return Expense(
          id: row['id'] as String,
          title: row['title'] as String,
          amount: row['amount'] as double,
          date: DateTime.parse(row['date'] as String),
          category: Category.values.firstWhere(
            (c) => c.name == row['category'],
          ),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load expenses for day: $e');
    }
  }

  // 7. Load Expenses for a Specific Month 📆
  static Future<List<Expense>> loadExpensesForMonth(int year, int month) async {
    try {
      final db = await _getDB();
      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

      final data = await db.query(
        'user_expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()],
        orderBy: 'date DESC',
      );

      return data.map((row) {
        return Expense(
          id: row['id'] as String,
          title: row['title'] as String,
          amount: row['amount'] as double,
          date: DateTime.parse(row['date'] as String),
          category: Category.values.firstWhere(
            (c) => c.name == row['category'],
          ),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load expenses for month: $e');
    }
  }

  // 8. Load Expenses for a Specific Year 📊
  static Future<List<Expense>> loadExpensesForYear(int year) async {
    try {
      final db = await _getDB();
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year, 12, 31, 23, 59, 59);

      final data = await db.query(
        'user_expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startOfYear.toIso8601String(), endOfYear.toIso8601String()],
        orderBy: 'date DESC',
      );

      return data.map((row) {
        return Expense(
          id: row['id'] as String,
          title: row['title'] as String,
          amount: row['amount'] as double,
          date: DateTime.parse(row['date'] as String),
          category: Category.values.firstWhere(
            (c) => c.name == row['category'],
          ),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load expenses for year: $e');
    }
  }

  // 9. Load Expenses within a Date Range 📋
  static Future<List<Expense>> loadExpensesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _getDB();
      final data = await db.query(
        'user_expenses',
        where: 'date >= ? AND date <= ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: 'date DESC',
      );

      return data.map((row) {
        return Expense(
          id: row['id'] as String,
          title: row['title'] as String,
          amount: row['amount'] as double,
          date: DateTime.parse(row['date'] as String),
          category: Category.values.firstWhere(
            (c) => c.name == row['category'],
          ),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load expenses for date range: $e');
    }
  }
}
