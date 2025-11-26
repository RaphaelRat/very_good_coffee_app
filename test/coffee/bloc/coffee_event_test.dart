import 'package:coffee_repository/coffee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_coffee/coffee/bloc/coffee_bloc.dart';

void main() {
  group('CoffeeEvent', () {
    test('CoffeeRequested supports value equality', () {
      const event = CoffeeRequested();

      expect(event, equals(const CoffeeRequested()));
      expect(event.props, equals(const []));
    });

    test('CoffeeSaved supports value equality', () {
      expect(
        const CoffeeSaved('a'),
        equals(const CoffeeSaved('a')),
      );
      expect(
        const CoffeeSaved('a').props,
        equals(['a']),
      );
    });

    test('CoffeeFavoritesRequested supports value equality', () {
      expect(
        const CoffeeFavoritesRequested(),
        equals(const CoffeeFavoritesRequested()),
      );
    });

    test('CoffeeFavoriteDeleted supports value equality', () {
      const coffeeImage = CoffeeImage(path: '/tmp/a.jpg');
      expect(
        const CoffeeFavoriteDeleted(coffeeImage),
        equals(const CoffeeFavoriteDeleted(coffeeImage)),
      );
      expect(
        const CoffeeFavoriteDeleted(coffeeImage).props,
        equals([coffeeImage]),
      );
    });
  });
}
