import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/paging_provider.dart';

List<Expense> _sample(int n) => List.generate(
      n,
      (i) => Expense(
        title: 'Item $i',
        amount: i + 1.0,
        date: DateTime(2026, 1, 1).add(Duration(days: i)),
        category: 'Food',
      ),
    );

Future<ProviderContainer> _container(List<Expense> data) async {
  final c = ProviderContainer(overrides: [
    expensesProvider.overrideWith((ref) => Stream.value(data)),
  ]);
  addTearDown(c.dispose);
  c.listen(expensesProvider, (_, _) {});
  await c.read(expensesProvider.future);
  return c;
}

void main() {
  test('shows only the first page', () async {
    final c = await _container(_sample(45));
    expect(c.read(pagedExpensesProvider).length, kPageSize);
  });

  test('loadMore shows more until everything is visible', () async {
    final c = await _container(_sample(45));

    c.read(visibleCountProvider.notifier).loadMore();
    expect(c.read(pagedExpensesProvider).length, 40);

    c.read(visibleCountProvider.notifier).loadMore();
    expect(c.read(pagedExpensesProvider).length, 45);
  });

  test('small lists are not cut', () async {
    final c = await _container(_sample(5));
    expect(c.read(pagedExpensesProvider).length, 5);
  });

  test('changing the search goes back to the first page', () async {
    final c = await _container(_sample(45));

    c.read(visibleCountProvider.notifier).loadMore();
    expect(c.read(visibleCountProvider), 40);

    c.read(searchQueryProvider.notifier).setQuery('Item 1');
    expect(c.read(visibleCountProvider), kPageSize);
  });
}