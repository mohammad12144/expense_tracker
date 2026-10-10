import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/api_client.dart';
import '../utils/formatters.dart';
import '../widgets/loading_button.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final Expense expense;

  const ExpenseDetailsScreen({super.key, required this.expense});

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final _api = ApiClient();
  bool _isSending = false;

  Future<void> _sendToServer() async {
    setState(() => _isSending = true);
    String message;
    try {
      // API تجريبي: بيرجّع id وهمي ولا يحفظ فعليًا
      final data = await _api.post(
        'https://jsonplaceholder.typicode.com/posts',
        {
          'title': widget.expense.title,
          'body':
              '${widget.expense.category} - ${formatMoney(widget.expense.amount)}',
          'userId': 1,
        },
      );
      message = 'Sent! Server returned id: ${data['id']}';
    } on ApiException catch (e) {
      message = e.message;
    } catch (_) {
      message = 'Something went wrong.';
    }
    if (!mounted) return;
    setState(() => _isSending = false);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expense = widget.expense;
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
                Text(formatMoney(expense.amount),
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: LoadingButton(
                    label: 'Send to server (test)',
                    onPressed: _sendToServer,
                    isLoading: _isSending,
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