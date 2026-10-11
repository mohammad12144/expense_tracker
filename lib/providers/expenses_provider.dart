import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../services/expense_storage.dart';

final expenseStorageProvider =
    Provider<ExpenseStorage>((ref) => ExpenseStorage());

final expensesProvider =
    AsyncNotifierProvider<ExpensesNotifier, List<Expense>>(
        ExpensesNotifier.new);

class ExpensesNotifier extends AsyncNotifier<List<Expense>> {
  ExpenseStorage get _storage => ref.read(expenseStorageProvider);

  List<Expense> get _current => state.value ?? const [];

  @override
  Future<List<Expense>> build() async {
    final saved = await _storage.load();
    return saved ?? _sampleExpenses();
  }

  Future<void> add(Expense expense) async {
    final updated = [expense, ..._current];
    state = AsyncData(updated);
    await _storage.save(updated);
  }

  /// بيرجّع مكان العنصر عشان نقدر نعمل Undo
  int remove(Expense expense) {
    final index = _current.indexOf(expense);
    final updated = [..._current]..remove(expense);
    state = AsyncData(updated);
    unawaited(_storage.save(updated));
    return index;
  }

  void restore(int index, Expense expense) {
    final updated = [..._current];
    final at = index.clamp(0, updated.length).toInt();
    updated.insert(at, expense);
    state = AsyncData(updated);
    unawaited(_storage.save(updated));
  }

  List<Expense> _sampleExpenses() {
    final now = DateTime.now();
    return [
      Expense(
          title: 'Groceries',
          amount: 45.50,
          date: now.subtract(const Duration(days: 1)),
          category: 'Food'),
      Expense(
          title: 'Fuel',
          amount: 30.00,
          date: now.subtract(const Duration(days: 2)),
          category: 'Transport'),
      Expense(
          title: 'Internet bill',
          amount: 25.00,
          date: now.subtract(const Duration(days: 3)),
          category: 'Bills'),
    ];
  }
}


final totalProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const <Expense>[];
  return expenses.fold<double>(0, (sum, e) => sum + e.amount);
});

final thisMonthProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const <Expense>[];
  final now = DateTime.now();
  return expenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold<double>(0, (sum, e) => sum + e.amount);
});