import 'package:flutter/material.dart';
import 'package:expense_tracker/core/utils/formatters.dart';

class SummaryCard extends StatelessWidget {
  final String label;
  final double value;

  const SummaryCard({super.key, required this.label, required this.value});

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
            Text(formatMoney(value),
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}