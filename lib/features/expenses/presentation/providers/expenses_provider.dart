import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseFirestore;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/data/expense_repository.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_provider.dart';

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// الـ repository الخاص بالمستخدم الحالي. بيتبدّل لحاله عند تغيير المستخدم.
final expenseRepositoryProvider = Provider<ExpenseRepository?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return FirestoreExpenseRepository(ref.watch(firestoreProvider), user.uid);
});

/// قائمة المصاريف الحية من Firestore (أي تغيير بيوصل للواجهة فورًا)
final expensesProvider = StreamProvider<List<Expense>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  if (repo == null) return Stream.value(const <Expense>[]);
  return repo.watch();
});

// ---------- قيم محسوبة (derived state) ----------

final totalProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const <Expense>[];
  return expenses.fold<double>(0, (acc, e) => acc + e.amount);
});

final thisMonthProvider = Provider<double>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const <Expense>[];
  final now = DateTime.now();
  return expenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold<double>(0, (acc, e) => acc + e.amount);
});