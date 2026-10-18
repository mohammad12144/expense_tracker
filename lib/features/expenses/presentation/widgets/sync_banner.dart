import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/features/expenses/domain/sync_state.dart';
import 'package:expense_tracker/features/expenses/presentation/providers/expenses_provider.dart';

/// Small banner that shows when the app is offline or still syncing.
class SyncBanner extends ConsumerWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStateProvider).value ?? SyncState.synced;
    if (state.isSynced) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final offline = state.isFromCache;
    final background =
        offline ? scheme.errorContainer : scheme.secondaryContainer;
    final foreground =
        offline ? scheme.onErrorContainer : scheme.onSecondaryContainer;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(offline ? Icons.cloud_off : Icons.sync,
              size: 18, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(state.label, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }
}