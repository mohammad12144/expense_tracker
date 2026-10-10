import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_storage.dart';
import '../utils/constants.dart';
import '../widgets/category_filter.dart';
import '../widgets/expense_tile.dart';
import '../widgets/summary_card.dart';
import 'add_expense_screen.dart';
import 'expense_details_screen.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = ExpenseStorage();
  List<Expense> _expenses = [];
  bool _isLoading = true;
  bool _isGrid = false;
  String? _category; // null = All
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await _storage.load();
    if (!mounted) return;
    setState(() {
      _expenses = saved ?? _sampleExpenses();
      _isLoading = false;
    });
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



  List<Expense> get _visible => _expenses.where((e) {
        final matchCategory = _category == null || e.category == _category;
        final matchQuery =
            e.title.toLowerCase().contains(_query.trim().toLowerCase());
        return matchCategory && matchQuery;
      }).toList();

  double get _total => _expenses.fold(0, (sum, e) => sum + e.amount);

  double get _thisMonth {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0, (sum, e) => sum + e.amount);
  }

  

  Future<void> _openAdd() async {
    final result = await Navigator.push<Expense>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (result != null) {
      setState(() => _expenses.insert(0, result));
      await _storage.save(_expenses);
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
    final index = _expenses.indexOf(expense);
    setState(() => _expenses.remove(expense));
    _storage.save(_expenses);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${expense.title} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              setState(() => _expenses.insert(index, expense));
              _storage.save(_expenses);
            },
          ),
        ),
      );
  }

 

  @override
  Widget build(BuildContext context) {
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final items = _visible;
    return Padding(
      padding: const EdgeInsets.all(AppSizes.listPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: SummaryCard(label: 'Total', value: _total)),
              const SizedBox(width: 12),
              Expanded(
                  child: SummaryCard(label: 'This month', value: _thisMonth)),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search expenses',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 12),
          CategoryFilter(
            selected: _category,
            onChanged: (c) => setState(() => _category = c),
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
                    child: Text(_expenses.isEmpty
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