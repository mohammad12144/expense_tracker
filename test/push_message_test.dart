import 'package:expense_tracker/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allowed route is kept', () {
    const m = PushMessage(data: {'route': '/notification'});
    expect(m.route, '/notification');
  });

  test('unknown or malicious route falls back to the safe default', () {
    const m = PushMessage(data: {'route': 'https://evil.example/steal'});
    expect(m.route, '/notification');
    expect(const PushMessage().route, '/notification');
  });
}