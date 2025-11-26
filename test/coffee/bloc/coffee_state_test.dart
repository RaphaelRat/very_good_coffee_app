import 'package:coffee_repository/coffee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:very_good_coffee/coffee/bloc/coffee_bloc.dart';

void main() {
  group('CoffeeState', () {
    test('CoffeeInitial supports equality', () {
      expect(const CoffeeInitial(), equals(const CoffeeInitial()));
    });

    test('CoffeeLoadInProgress supports equality', () {
      expect(
        const CoffeeLoadInProgress(),
        equals(const CoffeeLoadInProgress()),
      );
    });

    test('CoffeeLoadSuccess holds imageUrl', () {
      const state = CoffeeLoadSuccess('a');
      expect(state.props, equals(['a']));
    });

    test('CoffeeDownloadFailure holds props', () {
      const state = CoffeeDownloadFailure(imageUrl: 'a', message: 'm');
      expect(state.props, equals(['a', 'm']));
    });

    test('CoffeeLoadFailure holds message', () {
      const state = CoffeeLoadFailure('oops');
      expect(state.props, equals(['oops']));
    });

    test('CoffeeFavoritesLoadInProgress supports equality', () {
      expect(
        const CoffeeFavoritesLoadInProgress(),
        equals(const CoffeeFavoritesLoadInProgress()),
      );
    });

    test('CoffeeFavoritesLoadSuccess holds favorites list', () {
      const favorites = [CoffeeImage(path: '/tmp/a')];
      const state = CoffeeFavoritesLoadSuccess(favorites);
      expect(state.props, equals([favorites]));
    });

    test('CoffeeFavoritesLoadFailure holds message', () {
      const state = CoffeeFavoritesLoadFailure('fail');
      expect(state.props, equals(['fail']));
    });
  });
}
