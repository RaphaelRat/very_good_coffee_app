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

  group('CoffeePage', () {
    testWidgets('provides bloc and requests coffee on start', (tester) async {
      when(
        () => repository.fetchRandomCoffeeImageUrl(),
      ).thenAnswer((_) async => 'https://example.com/a.jpg');

      await tester.pumpApp(
        RepositoryProvider.value(
          value: repository,
          child: const CoffeePage(),
        ),
      );
      await tester.pump();

      expect(find.byType(CoffeeView), findsOneWidget);
      verify(() => repository.fetchRandomCoffeeImageUrl()).called(1);
    });
  });

  group('CoffeeView', () {
    late CoffeeBloc bloc;

    setUp(() {
      bloc = _MockCoffeeBloc();
    });

    Widget buildSubject() {
      return RepositoryProvider.value(
        value: repository,
        child: BlocProvider.value(
          value: bloc,
          child: const CoffeeView(),
        ),
      );
    }

    testWidgets('shows loading indicator when state is loading', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(const CoffeeLoadInProgress());
      whenListen(
        bloc,
        const Stream<CoffeeState>.empty(),
        initialState: const CoffeeLoadInProgress(),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      expect(find.text('Fetching coffee...'), findsOneWidget);
    });

    testWidgets('shows image and enables actions on load success', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [const CoffeeLoadSuccess('https://example.com/a.jpg')],
        ),
        initialState: const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );

      await tester.pumpApp(buildSubject());

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('New image'), findsOneWidget);
      expect(find.text('Save & new'), findsOneWidget);
      expect(find.text('Saved images'), findsOneWidget);
    });

    testWidgets(
      'shows error message and disables save when load fails',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const CoffeeLoadFailure('oops'),
        );
        whenListen(
          bloc,
          Stream<CoffeeState>.fromIterable(
            [const CoffeeLoadFailure('oops')],
          ),
          initialState: const CoffeeLoadFailure('oops'),
        );

        await tester.pumpApp(buildSubject());

        expect(find.text('oops'), findsOneWidget);

        final saveButton = tester.widget<ElevatedButton>(
          find.byKey(CoffeeView.saveAndNextButtonKey),
        );
        expect(saveButton.onPressed, isNull);

        final refreshButton = tester.widget<ElevatedButton>(
          find.byKey(CoffeeView.refreshButtonKey),
        );
        expect(refreshButton.onPressed, isNotNull);
      },
    );

    testWidgets('shows download failure and retries save', (tester) async {
      when(() => bloc.state).thenReturn(
        const CoffeeDownloadFailure(
          imageUrl: 'https://example.com/a.jpg',
          message: 'download failed',
        ),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [
            const CoffeeDownloadFailure(
              imageUrl: 'https://example.com/a.jpg',
              message: 'download failed',
            ),
          ],
        ),
        initialState: const CoffeeDownloadFailure(
          imageUrl: 'https://example.com/a.jpg',
          message: 'download failed',
        ),
      );

      await tester.pumpApp(buildSubject());

      expect(find.text('download failed'), findsOneWidget);

      await tester.tap(find.text('Try again'));

      verify(
        () => bloc.add(const CoffeeSaved('https://example.com/a.jpg')),
      ).called(1);
    });

    testWidgets('refresh button dispatches CoffeeRequested', (tester) async {
      when(() => bloc.state).thenReturn(
        const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [const CoffeeLoadSuccess('https://example.com/a.jpg')],
        ),
        initialState: const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );

      await tester.pumpApp(buildSubject());

      await tester.tap(find.byKey(CoffeeView.refreshButtonKey));

      verify(() => bloc.add(const CoffeeRequested())).called(1);
    });

    testWidgets('save button dispatches CoffeeSaved', (tester) async {
      when(() => bloc.state).thenReturn(
        const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [const CoffeeLoadSuccess('https://example.com/a.jpg')],
        ),
        initialState: const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );

      await tester.pumpApp(buildSubject());

      await tester.tap(find.byKey(CoffeeView.saveAndNextButtonKey));

      verify(
        () => bloc.add(const CoffeeSaved('https://example.com/a.jpg')),
      ).called(1);
    });

    testWidgets('retry button dispatches CoffeeRequested on load failure', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const CoffeeLoadFailure('oops'),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [const CoffeeLoadFailure('oops')],
        ),
        initialState: const CoffeeLoadFailure('oops'),
      );

      await tester.pumpApp(buildSubject());

      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(const CoffeeRequested())).called(1);
    });

    testWidgets('navigates to favorites page', (tester) async {
      when(() => bloc.state).thenReturn(
        const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [const CoffeeLoadSuccess('https://example.com/a.jpg')],
        ),
        initialState: const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );
      when(() => repository.loadFavorites()).thenAnswer((_) async => const []);

      await tester.pumpWidget(
        RepositoryProvider.value(
          value: repository,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: BlocProvider.value(
              value: bloc,
              child: const CoffeeView(),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(CoffeeView.favoritesButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(CoffeeFavoritesView), findsOneWidget);
    });

    testWidgets('image load error retries CoffeeRequested', (tester) async {
      when(() => bloc.state).thenReturn(
        const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );
      whenListen(
        bloc,
        Stream<CoffeeState>.fromIterable(
          [const CoffeeLoadSuccess('https://example.com/a.jpg')],
        ),
        initialState: const CoffeeLoadSuccess('https://example.com/a.jpg'),
      );

      await tester.pumpApp(buildSubject());

      final image = tester.widget<Image>(find.byType(Image));
      final errorBuilder = image.errorBuilder!;
      final errorWidget = errorBuilder(
        tester.element(find.byType(Image)),
        const Object(),
        StackTrace.empty,
      );

      final onRetry = (errorWidget as dynamic).onRetry as VoidCallback;
      onRetry();

      verify(() => bloc.add(const CoffeeRequested())).called(1);
    });
  });
}
