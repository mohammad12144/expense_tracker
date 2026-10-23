import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/notifications/presentation/providers/push_provider.dart';
import 'package:expense_tracker/features/notifications/data/notification_service.dart';
import 'package:expense_tracker/core/utils/constants.dart';

/// الشاشة الهدف لأي إشعار (route: /notification)
class NotificationTargetScreen extends ConsumerWidget {
  const NotificationTargetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final inbox = ref.watch(pushControllerProvider).inbox;
    final PushMessage? message = arg is PushMessage
        ? arg
        : (inbox.isNotEmpty ? inbox.first : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: message == null
              ? const Padding(
                  padding: EdgeInsets.all(AppSizes.pagePadding),
                  child: Text(
                    'Deep link target reached.\nNo notification payload yet.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications_active),
                      title: Text(message.title ?? '(no title)'),
                      subtitle: Text(message.body ?? '(no body)'),
                    ),
                    if (message.data.isNotEmpty) ...[
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Data payload'),
                      ),
                      for (final e in message.data.entries)
                        ListTile(
                          dense: true,
                          title: Text(e.key),
                          subtitle: Text('${e.value}'),
                        ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
