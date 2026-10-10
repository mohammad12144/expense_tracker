import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_button.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _date;
  String? _category;
  bool _dateError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
        _dateError = false;
      });
    }
  }

  void _save() {
    final valid = _formKey.currentState!.validate();
    if (_date == null) setState(() => _dateError = true);
    if (!valid || _date == null) return;

    final expense = Expense(
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      date: _date!,
      category: _category!,
    );
    Navigator.pop(context, expense); // رجّع المصروف للشاشة السابقة
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.pagePadding),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      label: 'Title',
                      icon: Icons.edit_outlined,
                      controller: _titleController,
                      validator: (v) =>
                          Validators.required(v, message: 'Title is required'),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Amount',
                      icon: Icons.attach_money,
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: Validators.amount,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(AppSizes.radius),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date',
                          prefixIcon: const Icon(Icons.calendar_today),
                          errorText: _dateError ? 'Pick a date' : null,
                        ),
                        child: Text(
                            _date == null ? 'Select date' : formatDate(_date!)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        for (final c in Expense.categories)
                          DropdownMenuItem(value: c, child: Text(c)),
                      ],
                      onChanged: (v) => setState(() => _category = v),
                      validator: (v) => v == null ? 'Choose a category' : null,
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(label: 'Save', onPressed: _save),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}