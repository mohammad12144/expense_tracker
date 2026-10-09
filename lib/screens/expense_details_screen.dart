import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseDetailsScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Expense details')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 40, child: Icon(expense.icon, size: 40)),
                const SizedBox(height: 16),
                Text(expense.title, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('\$${expense.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 24),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.category_outlined),
                        title: const Text('Category'),
                        trailing: Text(expense.category),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date'),
                        trailing: Text(expense.dateLabel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}