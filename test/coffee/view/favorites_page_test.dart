import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_repository/coffee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_coffee/coffee/bloc/coffee_bloc.dart';
import 'package:very_good_coffee/coffee/view/view.dart';
import 'package:very_good_coffee/l10n/l10n.dart';

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

      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(const CoffeeFavoritesRequested())).called(1);
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

    testWidgets('pull-to-refresh dispatches CoffeeFavoritesRequested', (
      tester,
    ) async {
      final tempFile = File('${Directory.systemTemp.path}/fav.jpg')
        ..writeAsBytesSync([1, 2, 3]);

      when(() => bloc.state).thenReturn(
        CoffeeFavoritesLoadSuccess([CoffeeImage(path: tempFile.path)]),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [
            CoffeeFavoritesLoadSuccess([CoffeeImage(path: tempFile.path)]),
          ],
        ),
        initialState: CoffeeFavoritesLoadSuccess([
          CoffeeImage(path: tempFile.path),
        ]),
      );

      await tester.pumpApp(buildSubject());

      final refreshIndicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );

      await refreshIndicator.onRefresh();

      verify(() => bloc.add(const CoffeeFavoritesRequested())).called(1);
    });

    testWidgets('renders separators between items', (tester) async {
      final fileA = File('${Directory.systemTemp.path}/a.jpg')
        ..writeAsBytesSync([1]);
      final fileB = File('${Directory.systemTemp.path}/b.jpg')
        ..writeAsBytesSync([2]);
      final favorites = [
        CoffeeImage(path: fileA.path),
        CoffeeImage(path: fileB.path),
      ];

      when(() => bloc.state).thenReturn(
        CoffeeFavoritesLoadSuccess(favorites),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [CoffeeFavoritesLoadSuccess(favorites)],
        ),
        initialState: CoffeeFavoritesLoadSuccess(favorites),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('uses errorBuilder when image decoding fails', (tester) async {
      final file = File('${Directory.systemTemp.path}/bad.jpg')
        ..writeAsBytesSync([0, 1, 2]);
      final favorite = CoffeeImage(path: file.path);

      when(() => bloc.state).thenReturn(
        CoffeeFavoritesLoadSuccess([favorite]),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [
            CoffeeFavoritesLoadSuccess([favorite]),
          ],
        ),
        initialState: CoffeeFavoritesLoadSuccess([favorite]),
      );

      await tester.pumpApp(buildSubject());

      final image = tester.widget<Image>(find.byType(Image));
      final errorBuilder = image.errorBuilder!;
      final errorWidget = errorBuilder(
        tester.element(find.byType(Image)),
        const Object(),
        StackTrace.empty,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: errorWidget),
        ),
      );

      expect(
        find.text('Could not open image at ${favorite.path}'),
        findsOneWidget,
      );
    });
  });
}
