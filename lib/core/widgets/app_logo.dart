import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showName;

  const AppLogo({super.key, this.size = 64, this.showName = true});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.account_balance_wallet, size: size, color: color),
        if (showName) ...[
          const SizedBox(height: 12),
          Text(
            'Expense Tracker',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ],
    );
  }
}