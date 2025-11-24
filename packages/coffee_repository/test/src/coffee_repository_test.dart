// Not required for test files
// ignore_for_file: prefer_const_constructors
import 'package:coffee_repository/coffee_repository.dart';
import 'package:test/test.dart';

void main() {
  group('CoffeeRepository', () {
    test('can be instantiated', () {
      expect(CoffeeRepository(), isNotNull);
    });
  });
}
