import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expenses_provider.dart';

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, String?>(
      CategoryFilterNotifier.new,
    );

class CategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? category) => state = category;
}

/// نص البحث
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final visibleExpensesProvider = Provider<List<Expense>>((ref) {
  final expenses = ref.watch(expensesProvider).value ?? const <Expense>[];
  final category = ref.watch(categoryFilterProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return expenses.where((e) {
    final matchCategory = category == null || e.category == category;
    final matchQuery = e.title.toLowerCase().contains(query);
    return matchCategory && matchQuery;
  }).toList();
});
