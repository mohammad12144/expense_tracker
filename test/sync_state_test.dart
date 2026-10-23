import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/expenses/domain/sync_state.dart';

void main() {
  test('synced state has no pending work', () {
    expect(SyncState.synced.isSynced, isTrue);
    expect(SyncState.synced.label, 'All changes saved');
  });

  test('cached data means offline', () {
    const s = SyncState(isFromCache: true, hasPendingWrites: false);
    expect(s.isSynced, isFalse);
    expect(s.label, 'Offline - showing saved data');
  });

  test('pending writes while online means syncing', () {
    const s = SyncState(isFromCache: false, hasPendingWrites: true);
    expect(s.isSynced, isFalse);
    expect(s.label, 'Syncing changes...');
  });

  test('offline with pending writes', () {
    const s = SyncState(isFromCache: true, hasPendingWrites: true);
    expect(s.label, 'Offline - changes will sync when you reconnect');
  });

  test('equal states are equal (needed by distinct())', () {
    const a = SyncState(isFromCache: true, hasPendingWrites: false);
    const b = SyncState(isFromCache: true, hasPendingWrites: false);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
  });
}
