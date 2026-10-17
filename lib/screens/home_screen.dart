import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/expense.dart';
import '../providers/auth_provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/filters_provider.dart';
import '../providers/push_provider.dart';
import '../utils/constants.dart';
import '../widgets/category_filter.dart';
import '../widgets/expense_tile.dart';
import '../widgets/summary_card.dart';
import 'add_expense_screen.dart';
import 'expense_details_screen.dart';
import 'products_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // حالة واجهة مؤقتة بتخص هالشاشة بس
  bool _isGrid = false;

  @override
  void initState() {
    super.initState();
    // إذا إذن الإشعارات معطى من قبل، بنفعّل الاستقبال (microtask عشان ما نعدّل state أثناء البناء)
    Future.microtask(() => ref.read(pushControllerProvider.notifier).init());
  }

  /// بننفّذ عملية Firestore بدون ما نوقف الواجهة.
  void _fire(Future<void> Function() action) {
    unawaited(action().catchError((Object e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('Failed: $e')));
    }));
  }

  // ---------- أفعال ----------

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
      MaterialPageRoute(
          builder: (_) => ExpenseDetailsScreen(expense: expense)),
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

  Future<void> _logout() async {
    await ref.read(firebaseAuthProvider).signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // ---------- واجهة ----------

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
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
            data: (expenses) => _buildContent(expenses),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<Expense> allExpenses) {
    final items = ref.watch(visibleExpensesProvider);

    return Padding(
      padding: const EdgeInsets.all(AppSizes.listPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                    label: 'Total', value: ref.watch(totalProvider)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                    label: 'This month', value: ref.watch(thisMonthProvider)),
              ),
            ],
          ),
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
          CategoryFilter(
            selected: ref.watch(categoryFilterProvider),
            onChanged: (c) =>
                ref.read(categoryFilterProvider.notifier).select(c),
          ),
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
            child: items.isEmpty
                ? Center(
                    child: Text(allExpenses.isEmpty
                        ? 'No expenses yet. Tap + to add.'
                        : 'No results found.'),
                  )
                : (_isGrid ? _buildGrid(items) : _buildList(items)),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Expense> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => ExpenseTile(
        expense: items[i],
        onTap: () => _openDetails(items[i]),
        onDelete: () => _delete(items[i]),
      ),
    );
  }

  Widget _buildGrid(List<Expense> items) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => ExpenseGridTile(
        expense: items[i],
        onTap: () => _openDetails(items[i]),
      ),
    );
  }
}