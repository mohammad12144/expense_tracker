/// Describes how the local Firestore view relates to the server.
class SyncState {
  const SyncState({required this.isFromCache, required this.hasPendingWrites});

  /// True when the data comes from the local cache (offline or not yet synced).
  final bool isFromCache;

  /// True when local changes have not reached the server yet.
  final bool hasPendingWrites;

  static const synced = SyncState(isFromCache: false, hasPendingWrites: false);

  bool get isSynced => !isFromCache && !hasPendingWrites;

  String get label {
    if (isFromCache && hasPendingWrites) {
      return 'Offline - changes will sync when you reconnect';
    }
    if (isFromCache) return 'Offline - showing saved data';
    if (hasPendingWrites) return 'Syncing changes...';
    return 'All changes saved';
  }

  @override
  bool operator ==(Object other) =>
      other is SyncState &&
      other.isFromCache == isFromCache &&
      other.hasPendingWrites == hasPendingWrites;

  @override
  int get hashCode => Object.hash(isFromCache, hasPendingWrites);
}
