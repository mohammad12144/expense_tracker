import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
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
                    const SizedBox(height: 16),
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