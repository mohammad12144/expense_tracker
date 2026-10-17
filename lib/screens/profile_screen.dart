import 'package:firebase_messaging/firebase_messaging.dart'
    show AuthorizationStatus;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/push_provider.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final created = user?.metadata.creationTime;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
          child: user == null
              ? const Text('Not signed in')
              : ListView(
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(user.displayName ?? '(no name)'),
                      subtitle: const Text('Name'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: Text(user.email ?? ''),
                      subtitle: const Text('Email'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(user.uid),
                      subtitle: const Text('User ID'),
                    ),
                    if (created != null)
                      ListTile(
                        leading: const Icon(Icons.event_outlined),
                        title: Text(formatDate(created)),
                        subtitle: const Text('Member since'),
                      ),
                    const Divider(),
                    const _NotificationsSection(),
                    const Divider(),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      onPressed: () async {
                        await ref.read(firebaseAuthProvider).signOut();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _NotificationsSection extends ConsumerWidget {
  const _NotificationsSection();

  // `_` بيغطي denied و deniedPermanently وأي قيمة جديدة بالمستقبل
  String _statusLabel(AuthorizationStatus? s) => switch (s) {
        null => 'Checking...',
        AuthorizationStatus.authorized => 'Enabled',
        AuthorizationStatus.provisional => 'Enabled (provisional)',
        AuthorizationStatus.notDetermined => 'Not enabled yet',
        _ => 'Blocked in browser/system settings',
      };

  // منعرض جزء من الـ token بس (ما بنعرضه كامل ولا بنطبعه بالـ logs)
  String _shortToken(String t) => t.length > 16
      ? '${t.substring(0, 8)}...${t.substring(t.length - 6)}'
      : t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!NotificationService.isSupported) {
      return const ListTile(
        leading: Icon(Icons.notifications_off_outlined),
        title: Text('Push notifications'),
        subtitle: Text(
            'Not supported on this platform (use Chrome, Android or iOS).'),
      );
    }

    final push = ref.watch(pushControllerProvider);
    final token = push.token;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.notifications_outlined),
          title: const Text('Push notifications'),
          subtitle: Text(_statusLabel(push.status)),
        ),
        if (!push.enabled)
          FilledButton.tonalIcon(
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(push.busy ? 'Please wait...' : 'Enable notifications'),
            onPressed: push.busy
                ? null
                : () => ref.read(pushControllerProvider.notifier).enable(),
          ),
        if (token != null)
          ListTile(
            leading: const Icon(Icons.key_outlined),
            title: Text(_shortToken(token)),
            subtitle: const Text('FCM token (copy it to send a test push)'),
            trailing: IconButton(
              tooltip: 'Copy token',
              icon: const Icon(Icons.copy),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: token));
                messenger.showSnackBar(
                    const SnackBar(content: Text('Token copied')));
              },
            ),
          ),
        if (push.error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              push.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    );
  }
}