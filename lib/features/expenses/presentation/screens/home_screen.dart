import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/expense.dart';
import 'package:expense_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expenses_provider.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/filters_provider.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/paging_provider.dart';
import 'package:expense_tracker/features/expenses/presentation/widgets/sync_banner.dart';
import 'package:expense_tracker/features/notifications/presentation/providers/push_provider.dart';
import 'package:expense_tracker/core/utils/constants.dart';
import 'package:expense_tracker/core/widgets/category_filter.dart';
import 'package:expense_tracker/core/widgets/expense_tile.dart';
import 'package:expense_tracker/core/widgets/summary_card.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/features/expenses/presentation/screens/expense_details_screen.dart';
import 'package:expense_tracker/screens/products_screen.dart';
import 'package:expense_tracker/core/screens/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // UI state that belongs to this screen only
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    // If notification permission was already granted, enable receiving.
    // (microtask so we do not change state while the widget is building)
    Future.microtask(() => ref.read(pushControllerProvider.notifier).init());
  }

  /// Runs a Firestore operation without blocking the UI.
  /// Offline, the returned future only completes after the server confirms,
  /// so we never await it.
  void _fire(Future<void> Function() action) {
    unawaited(action().catchError((Object e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('Failed: $e')));
    }));
  }

  // ---------- Actions ----------

  Future<void> _openAdd() async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    final repo = ref.read(expenseRepositoryProvider);
    if (result != null && repo != null) {
      _fire(() => repo.add(result));
    }
  }

  void _openDetails(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExpenseDetailsScreen(expense: expense)),
    );
  }

  void _delete(Expense expense) {
    final repo = ref.read(expenseRepositoryProvider);
    if (repo == null) return;
    _fire(() => repo.remove(expense));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${expense.title} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => _fire(() => repo.restore(expense)),
          ),
        ),
      );
  }

  /// Debug builds only: adds 50 sample expenses to try paging and performance.
  void _seedSamples() {
    final repo = ref.read(expenseRepositoryProvider);
    if (repo == null) return;
    final now = DateTime.now();
    for (var i = 0; i < 50; i++) {
      _fire(() => repo.add(Expense(
            title: 'Sample ${i + 1}',
            amount: (i + 1) * 3.5,
            date: now.subtract(Duration(days: i)),
            category: Expense.categories[i % Expense.categories.length],
          )));
    }
  }

  Future<void> _logout() async {
    await ref.read(firebaseAuthProvider).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: 'Debug: add 50 sample expenses',
              icon: const Icon(Icons.science_outlined),
              onPressed: _seedSamples,
            ),
          IconButton(
            tooltip: 'Products (API demo)',
            icon: const Icon(Icons.storefront_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductsScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add expense',
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(maxWidth: AppSizes.contentMaxWidth),
          child: expensesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Failed to load: $e')),
            data: (expenses) => _buildContent(hasAny: expenses.isNotEmpty),
          ),
        ),
      ),
    );
  }

  Widget _buildContent({required bool hasAny}) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.listPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SyncBanner(),
          const _SummaryRow(),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search expenses',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) =>
                ref.read(searchQueryProvider.notifier).setQuery(v),
          ),
          const SizedBox(height: 12),
          const _FilterBar(),
          Row(
            children: [
              Text('Recent expenses',
                  style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              IconButton(
                tooltip: _isGrid ? 'Show list' : 'Show grid',
                icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
                onPressed: () => setState(() => _isGrid = !_isGrid),
              ),
            ],
          ),
          Expanded(
            child: _ExpenseList(
              hasAny: hasAny,
              isGrid: _isGrid,
              onOpen: _openDetails,
              onDelete: _delete,
            ),
          ),
        ],
      ),
    );
  }
}

/// Watches only the totals, so typing in the search box does not rebuild it.
class _SummaryRow extends ConsumerWidget {
  const _SummaryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: SummaryCard(label: 'Total', value: ref.watch(totalProvider)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SummaryCard(
              label: 'This month', value: ref.watch(thisMonthProvider)),
        ),
      ],
    );
  }
}

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CategoryFilter(
      selected: ref.watch(categoryFilterProvider),
      onChanged: (c) => ref.read(categoryFilterProvider.notifier).select(c),
    );
  }
}

/// The paged list/grid. Only this widget rebuilds when the filter,
/// the search text or the page size changes.
class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({
    required this.hasAny,
    required this.isGrid,
    required this.onOpen,
    required this.onDelete,
  });

  final bool hasAny;
  final bool isGrid;
  final void Function(Expense) onOpen;
  final void Function(Expense) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(pagedExpensesProvider);
    final total = ref.watch(visibleExpensesProvider).length;

    if (items.isEmpty) {
      return Center(
        child: Text(hasAny
            ? 'No results found.'
            : 'No expenses yet. Tap + to add.'),
      );
    }

    return Column(
      children: [
        Expanded(child: isGrid ? _grid(items) : _list(items)),
        if (items.length < total)
          TextButton.icon(
            onPressed: () => ref.read(visibleCountProvider.notifier).loadMore(),
            icon: const Icon(Icons.expand_more),
            label: Text('Load more (${items.length} of $total)'),
          ),
      ],
    );
  }

  Widget _list(List<Expense> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => ExpenseTile(
        key: ValueKey(items[i].id ?? i),
        expense: items[i],
        onTap: () => onOpen(items[i]),
        onDelete: () => onDelete(items[i]),
      ),
    );
  }

  Widget _grid(List<Expense> items) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => ExpenseGridTile(
        key: ValueKey(items[i].id ?? i),
        expense: items[i],
        onTap: () => onOpen(items[i]),
      ),
    );
  }
}