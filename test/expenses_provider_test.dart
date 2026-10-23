import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Expense make(String title, double amount, String category) => Expense(
  title: title,
  amount: amount,
  date: DateTime.now(),
  category: category,
);

ProviderContainer makeContainer(List<Expense> data) {
  final container = ProviderContainer(
    overrides: [expensesProvider.overrideWith((ref) => Stream.value(data))],
  );
  addTearDown(container.dispose);
  // Riverpod 3: بدون مستمع الـ provider بيتوقف، فبنخلي مستمع شغّال طول الاختبار
  container.listen(expensesProvider, (_, _) {});
  return container;
}

void main() {
  test('total and this-month are derived from expenses', () async {
    final c = makeContainer([
      make('Coffee', 5, 'Food'),
      make('Taxi', 8, 'Transport'),
    ]);
    await c.read(expensesProvider.future);

    expect(c.read(totalProvider), 13);
    expect(c.read(thisMonthProvider), 13);
  });

  test('category filter and search', () async {
    final c = makeContainer([
      make('Coffee', 5, 'Food'),
      make('Taxi', 8, 'Transport'),
    ]);
    await c.read(expensesProvider.future);

    c.read(categoryFilterProvider.notifier).select('Food');
    expect(c.read(visibleExpensesProvider).map((e) => e.title), ['Coffee']);

    c.read(categoryFilterProvider.notifier).select(null);
    c.read(searchQueryProvider.notifier).setQuery('tax');
    expect(c.read(visibleExpensesProvider).map((e) => e.title), ['Taxi']);
  });
}
