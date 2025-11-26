import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_repository/coffee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_coffee/coffee/bloc/coffee_bloc.dart';
import 'package:very_good_coffee/coffee/view/view.dart';

import '../../helpers/pump_app.dart';

class _MockCoffeeRepository extends Mock implements CoffeeRepository {}

class _MockCoffeeBloc extends MockBloc<CoffeeEvent, CoffeeState>
    implements CoffeeBloc {}

class _FakeCoffeeEvent extends Fake implements CoffeeEvent {}

class _FakeCoffeeState extends Fake implements CoffeeState {}

void main() {
  late CoffeeRepository repository;

  setUpAll(() {
    registerFallbackValue(_FakeCoffeeEvent());
    registerFallbackValue(_FakeCoffeeState());
  });

  setUp(() {
    repository = _MockCoffeeRepository();
  });

  group('CoffeeFavoritesPage', () {
    testWidgets('loads favorites on start', (tester) async {
      when(() => repository.loadFavorites()).thenAnswer((_) async => const []);

      await tester.pumpApp(
        RepositoryProvider.value(
          value: repository,
          child: const CoffeeFavoritesPage(),
        ),
      );
      await tester.pump();

      verify(() => repository.loadFavorites()).called(1);
    });
  });

  group('CoffeeFavoritesView', () {
    late CoffeeBloc bloc;

    setUp(() {
      bloc = _MockCoffeeBloc();
    });

    Widget buildSubject() {
      return RepositoryProvider.value(
        value: repository,
        child: BlocProvider.value(
          value: bloc,
          child: const CoffeeFavoritesView(),
        ),
      );
    }

    testWidgets('shows loading state', (tester) async {
      when(() => bloc.state).thenReturn(const CoffeeFavoritesLoadInProgress());
      whenListen(
        bloc,
        const Stream<CoffeeState>.empty(),
        initialState: const CoffeeFavoritesLoadInProgress(),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry', (tester) async {
      when(() => bloc.state).thenReturn(
        const CoffeeFavoritesLoadFailure('error'),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [const CoffeeFavoritesLoadFailure('error')],
        ),
        initialState: const CoffeeFavoritesLoadFailure('error'),
      );

      await tester.pumpApp(buildSubject());

      expect(find.text('error'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets(
      'shows empty message when there are no favorites',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const CoffeeFavoritesLoadSuccess([]),
        );
        whenListen(
          bloc,
          Stream<CoffeeState>.fromIterable(
            [const CoffeeFavoritesLoadSuccess([])],
          ),
          initialState: const CoffeeFavoritesLoadSuccess([]),
        );

        await tester.pumpApp(buildSubject());

        expect(find.text('No saved images yet.'), findsOneWidget);
      },
    );

    testWidgets(
      'shows error placeholder when file does not exist',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const CoffeeFavoritesLoadSuccess(
            [CoffeeImage(path: '/tmp/missing.jpg')],
          ),
        );
        whenListen(
          bloc,
          Stream<CoffeeState>.fromIterable(
            [
              const CoffeeFavoritesLoadSuccess(
                [CoffeeImage(path: '/tmp/missing.jpg')],
              ),
            ],
          ),
          initialState: const CoffeeFavoritesLoadSuccess(
            [CoffeeImage(path: '/tmp/missing.jpg')],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(
          find.text('Could not open image at /tmp/missing.jpg'),
          findsOneWidget,
        );
      },
    );

    testWidgets('dispatches delete event when delete is tapped', (
      tester,
    ) async {
      const image = CoffeeImage(path: '/tmp/a.jpg');

      when(() => bloc.state).thenReturn(
        const CoffeeFavoritesLoadSuccess([image]),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [
            const CoffeeFavoritesLoadSuccess([image]),
          ],
        ),
        initialState: const CoffeeFavoritesLoadSuccess([image]),
      );

      await tester.pumpApp(buildSubject());

      await tester.tap(
        find.byKey(const ValueKey('favorite_delete_/tmp/a.jpg')),
      );

      verify(() => bloc.add(const CoffeeFavoriteDeleted(image))).called(1);
    });
  });
}
