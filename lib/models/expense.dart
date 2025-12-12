import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/utils/formatters.dart';

// This object generates unique IDs for us
const uuid = Uuid();

// 1. The Fixed List of Categories (Enum) 🔒
enum Category { food, travel, leisure, work }

// 2. A helper map to link Categories to Icons 🍔✈️
const categoryIcons = {
  Category.food: Icons.lunch_dining,
  Category.travel: Icons.flight_takeoff,
  Category.leisure: Icons.movie,
  Category.work: Icons.work,
};

// 3. The Blueprint for an Expense 🏗️
class Expense {
  Expense({
    String? id, // <--- Allow optional ID
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = id ?? uuid.v4(); // Use the passed ID, or generate a new one if null
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  // A helper to format the date nicely
  String get formattedDate {
    return dateFormatter.format(date);
  }
}