import 'package:coffee_repository/coffee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_coffee/app/app.dart';

class _MockCoffeeRepository extends Mock implements CoffeeRepository {}

void main() {
  group('App', () {
    late CoffeeRepository repository;

    setUp(() {
      repository = _MockCoffeeRepository();
      when(
        () => repository.fetchRandomCoffeeImageUrl(),
      ).thenAnswer((_) async => 'https://example.com/coffee.jpg');
    });

    testWidgets('renders CoffeePage', (tester) async {
      await tester.pumpWidget(App(coffeeRepository: repository));
      await tester.pump();

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
