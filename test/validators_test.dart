import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/utils/validators.dart';

void main() {
  group('Validators.required', () {
    test('returns default message for null, empty and blank', () {
      expect(Validators.required(null), 'Required');
      expect(Validators.required(''), 'Required');
      expect(Validators.required('   '), 'Required');
    });

    test('returns custom message', () {
      expect(Validators.required('', message: 'Title needed'), 'Title needed');
    });

    test('returns null for valid text', () {
      expect(Validators.required('coffee'), isNull);
    });
  });

  group('Validators.name', () {
    test('rejects null and too short names', () {
      expect(Validators.name(null), 'Enter your name');
      expect(Validators.name('a'), 'Enter your name');
      expect(Validators.name('  a  '), 'Enter your name');
    });

    test('accepts 2+ characters', () {
      expect(Validators.name('Al'), isNull);
    });
  });

  group('Validators.email', () {
    test('requires a value', () {
      expect(Validators.email(null), 'Email is required');
      expect(Validators.email('  '), 'Email is required');
    });

    test('rejects invalid formats', () {
      expect(Validators.email('abc'), 'Enter a valid email');
      expect(Validators.email('a@b'), 'Enter a valid email');
      expect(Validators.email('a.b'), 'Enter a valid email');
    });

    test('accepts a valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('requires a value', () {
      expect(Validators.password(null), 'Password is required');
      expect(Validators.password(''), 'Password is required');
    });

    test('requires at least 6 characters', () {
      expect(Validators.password('12345'), 'At least 6 characters');
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.matches', () {
    test('returns message when values differ', () {
      final v = Validators.matches(() => 'secret1');
      expect(v('secret2'), 'Passwords do not match');
    });

    test('returns null when values match', () {
      final v = Validators.matches(() => 'secret1');
      expect(v('secret1'), isNull);
    });

    test('compares against the latest value of the other field', () {
      var other = 'a';
      final v = Validators.matches(() => other);
      expect(v('a'), isNull);
      other = 'b';
      expect(v('a'), 'Passwords do not match');
    });
  });

  group('Validators.amount', () {
    test('rejects non numbers', () {
      expect(Validators.amount(null), 'Enter a valid number');
      expect(Validators.amount(''), 'Enter a valid number');
      expect(Validators.amount('abc'), 'Enter a valid number');
    });

    test('rejects zero and negative numbers', () {
      expect(Validators.amount('0'), 'Must be greater than 0');
      expect(Validators.amount('-5'), 'Must be greater than 0');
    });

    test('accepts positive numbers', () {
      expect(Validators.amount('12.5'), isNull);
      expect(Validators.amount('1'), isNull);
    });
  });
}