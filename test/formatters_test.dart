import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/formatters.dart';

void main() {
  group('formatDate', () {
    test('pads month and day', () {
      expect(formatDate(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('keeps two digit month and day', () {
      expect(formatDate(DateTime(2026, 10, 18)), '2026-10-18');
    });
  });

  group('formatMoney', () {
    test('always shows two decimals', () {
      expect(formatMoney(15), r'$15.00');
      expect(formatMoney(0), r'$0.00');
    });

    test('rounds to two decimals', () {
      expect(formatMoney(1234.567), r'$1234.57');
    });
  });
}
