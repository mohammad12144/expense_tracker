import 'package:flutter/material.dart';
import '../models/expense.dart';

class CategoryFilter extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const CategoryFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('All', selected == null, () => onChanged(null)),
          for (final c in Expense.categories)
            _chip(c, selected == c, () => onChanged(c)),
        ],
      ),
    );
  }

  Widget _chip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}