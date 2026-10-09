import 'package:flutter/material.dart';
import '../models/expense.dart';
import 'add_expense_screen.dart';
import 'expense_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> _expenses = [
    Expense(
        title: 'Groceries',
        amount: 45.50,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Food'),
    Expense(
        title: 'Fuel',
        amount: 30.00,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Transport'),
    Expense(
        title: 'Internet bill',
        amount: 25.00,
        date: DateTime.now().subtract(const Duration(days: 3)),
        category: 'Bills'),
  ];

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
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${expense.title} deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () => setState(() => _expenses.insert(index, expense)),
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
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, '/login', (route) => false),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _SummaryCard(label: 'Total', value: _total)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _SummaryCard(
                          label: 'This month', value: _thisMonth)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Recent expenses',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (_expenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('No expenses yet. Tap + to add.')),
                ),
              for (final e in _expenses)
                Dismissible(
                  key: ObjectKey(e),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _delete(e),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(e.icon)),
                      title: Text(e.title),
                      subtitle: Text('${e.category} • ${e.dateLabel}'),
                      trailing: Text('\$${e.amount.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () => _openDetails(e),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double value;

  const _SummaryCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text('\$${value.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}