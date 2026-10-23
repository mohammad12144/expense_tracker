import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/filters_provider.dart';

const kPageSize = 20;

/// How many filtered expenses the list currently shows.
class VisibleCountNotifier extends Notifier<int> {
  @override
  int build() {
    // Going back to the first page whenever the filter or search changes.
    ref.listen(categoryFilterProvider, (_, _) => state = kPageSize);
    ref.listen(searchQueryProvider, (_, _) => state = kPageSize);
    return kPageSize;
  }

  void loadMore() => state += kPageSize;

  void reset() => state = kPageSize;
}

final visibleCountProvider = NotifierProvider<VisibleCountNotifier, int>(
  VisibleCountNotifier.new,
);

/// The current page of the filtered expenses.
final pagedExpensesProvider = Provider<List<Expense>>((ref) {
  final items = ref.watch(visibleExpensesProvider);
  final count = ref.watch(visibleCountProvider);
  return items.length <= count ? items : items.sublist(0, count);
});
