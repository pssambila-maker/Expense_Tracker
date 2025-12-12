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
}
