// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:coffee_api/coffee_api.dart';
import 'package:test/test.dart';

void main() {
  group('CoffeeApi', () {
    test('can be instantiated', () {
      expect(CoffeeApi(), isNotNull);
    });
  });
}
