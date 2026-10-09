import 'package:flutter/material.dart';

class Expense {
  final String title;
  final double amount;
  final DateTime date;
  final String category;

  const Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  static const categories = ['Food', 'Transport', 'Bills', 'Shopping', 'Other'];

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        category: json['category'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category,
      };

  IconData get icon => switch (category) {
        'Food' => Icons.restaurant,
        'Transport' => Icons.directions_car,
        'Bills' => Icons.receipt_long,
        'Shopping' => Icons.shopping_cart,
        _ => Icons.category,
      };

  String get dateLabel {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}