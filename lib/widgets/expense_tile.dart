import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/formatters.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ObjectKey(expense),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(expense.icon)),
          title: Text(expense.title),
          subtitle: Text('${expense.category} • ${expense.dateLabel}'),
          trailing: Text(formatMoney(expense.amount),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// عنصر مصروف بعرض الشبكة
class ExpenseGridTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onTap;

  const ExpenseGridTile({super.key, required this.expense, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(child: Icon(expense.icon)),
              const SizedBox(height: 8),
              Text(expense.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(formatMoney(expense.amount),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}