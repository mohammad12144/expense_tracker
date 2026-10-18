import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';

void main() {
  final expense = Expense(
    title: 'coffee',
    amount: 15,
    date: DateTime(2026, 10, 12),
    category: 'Food',
  );

  group('Expense json', () {
    test('toJson contains all fields', () {
      final json = expense.toJson();
      expect(json['title'], 'coffee');
      expect(json['amount'], 15);
      expect(json['category'], 'Food');
      expect(json['date'], DateTime(2026, 10, 12).toIso8601String());
    });

    test('fromJson(toJson) round trip keeps the data', () {
      final copy = Expense.fromJson(expense.toJson());
      expect(copy.title, expense.title);
      expect(copy.amount, expense.amount);
      expect(copy.date, expense.date);
      expect(copy.category, expense.category);
      expect(copy.id, isNull);
    });

    test('fromJson accepts integer amounts', () {
      final e = Expense.fromJson({
        'title': 't',
        'amount': 20,
        'date': '2026-01-01T00:00:00.000',
        'category': 'Other',
      });
      expect(e.amount, 20.0);
    });

    test('fromJson throws on missing required fields', () {
      expect(
        () => Expense.fromJson({'amount': 1, 'date': '2026-01-01', 'category': 'Food'}),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('Expense helpers', () {
    test('dateLabel is formatted as yyyy-MM-dd', () {
      expect(expense.dateLabel, '2026-10-12');
    });

    test('icon depends on the category', () {
      Expense with_(String c) =>
          Expense(title: 't', amount: 1, date: DateTime(2026), category: c);
      expect(with_('Food').icon, Icons.restaurant);
      expect(with_('Transport').icon, Icons.directions_car);
      expect(with_('Bills').icon, Icons.receipt_long);
      expect(with_('Shopping').icon, Icons.shopping_cart);
      expect(with_('Other').icon, Icons.category);
      expect(with_('Unknown').icon, Icons.category);
    });

    test('categories list has the five known categories', () {
      expect(Expense.categories,
          ['Food', 'Transport', 'Bills', 'Shopping', 'Other']);
    });
  });
}