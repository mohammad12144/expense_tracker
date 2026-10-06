import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _expenses = [
    ('Groceries', 45.50, Icons.shopping_cart),
    ('Fuel', 30.00, Icons.local_gas_station),
    ('Coffee', 4.25, Icons.coffee),
    ('Internet bill', 25.00, Icons.wifi),
    ('Restaurant', 38.75, Icons.restaurant),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _expenses.fold<double>(0, (sum, e) => sum + e.$2);

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(child: _SummaryCard(label: 'Total', value: total)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _SummaryCard(label: 'This month', value: total)),
                ],
              ),
              const SizedBox(height: 24),
              Text('Recent expenses',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final e in _expenses)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(e.$3)),
                    title: Text(e.$1),
                    trailing: Text('\$${e.$2.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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