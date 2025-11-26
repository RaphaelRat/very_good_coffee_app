import 'package:bloc_test/bloc_test.dart';
import 'package:coffee_repository/coffee_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:very_good_coffee/coffee/bloc/coffee_bloc.dart';

class _MockCoffeeRepository extends Mock implements CoffeeRepository {}

void main() {
  group('CoffeeBloc', () {
    late CoffeeRepository repository;
    late CoffeeBloc bloc;

    setUp(() {
      repository = _MockCoffeeRepository();
      bloc = CoffeeBloc(repository: repository);
    });

    tearDown(() => bloc.close());

    test('initial state is CoffeeInitial', () {
      expect(bloc.state, equals(const CoffeeInitial()));
    });

    group('CoffeeRequested', () {
      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoadInProgress, CoffeeLoadSuccess] '
        'when fetch succeeds',
        build: () {
          when(() => repository.fetchRandomCoffeeImageUrl()).thenAnswer(
            (_) async => 'https://example.com/coffee.jpg',
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeRequested()),
        expect: () => const <CoffeeState>[
          CoffeeLoadInProgress(),
          CoffeeLoadSuccess('https://example.com/coffee.jpg'),
        ],
        verify: (_) {
          verify(() => repository.fetchRandomCoffeeImageUrl()).called(1);
        },
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoadInProgress, CoffeeLoadFailure] '
        'when CoffeeRepositoryLoadFailure is thrown',
        build: () {
          when(() => repository.fetchRandomCoffeeImageUrl()).thenThrow(
            const CoffeeRepositoryLoadFailure('load failed'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeRequested()),
        expect: () => const <CoffeeState>[
          CoffeeLoadInProgress(),
          CoffeeLoadFailure('load failed'),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoadInProgress, CoffeeLoadFailure] '
        'when an unexpected Exception is thrown',
        build: () {
          when(() => repository.fetchRandomCoffeeImageUrl()).thenThrow(
            Exception('boom'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeRequested()),
        expect: () => <CoffeeState>[
          const CoffeeLoadInProgress(),
          const CoffeeLoadFailure('Unexpected error: Exception: boom'),
        ],
      );
    });

    group('CoffeeSaved', () {
      const imageUrl = 'https://example.com/coffee.jpg';

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoadInProgress, CoffeeLoadSuccess] '
        'when save and fetch succeed',
        build: () {
          when(() => repository.saveFavorite(imageUrl)).thenAnswer(
            (_) async => const CoffeeImage(path: '/tmp/a.jpg'),
          );
          when(() => repository.fetchRandomCoffeeImageUrl()).thenAnswer(
            (_) async => 'https://example.com/coffee2.jpg',
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeSaved(imageUrl)),
        expect: () => const <CoffeeState>[
          CoffeeLoadInProgress(),
          CoffeeLoadSuccess('https://example.com/coffee2.jpg'),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoadInProgress, CoffeeDownloadFailure] '
        'when CoffeeRepositoryDownloadFailure is thrown',
        build: () {
          when(() => repository.saveFavorite(imageUrl)).thenThrow(
            const CoffeeRepositoryDownloadFailure('download failed'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeSaved(imageUrl)),
        expect: () => const <CoffeeState>[
          CoffeeLoadInProgress(),
          CoffeeDownloadFailure(
            message: 'Could not save image: download failed',
            imageUrl: imageUrl,
          ),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoadInProgress, CoffeeLoadFailure] '
        'when CoffeeRepositoryLoadFailure is thrown after saving',
        build: () {
          when(() => repository.saveFavorite(imageUrl)).thenAnswer(
            (_) async => const CoffeeImage(path: '/tmp/a.jpg'),
          );
          when(() => repository.fetchRandomCoffeeImageUrl()).thenThrow(
            const CoffeeRepositoryLoadFailure('load failed'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeSaved(imageUrl)),
        expect: () => const <CoffeeState>[
          CoffeeLoadInProgress(),
          CoffeeLoadFailure('load failed'),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeLoadInProgress, CoffeeLoadFailure] '
        'when an unexpected Exception is thrown',
        build: () {
          when(() => repository.saveFavorite(imageUrl)).thenThrow(
            Exception('boom'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeSaved(imageUrl)),
        expect: () => <CoffeeState>[
          const CoffeeLoadInProgress(),
          const CoffeeLoadFailure('Unexpected error: Exception: boom'),
        ],
      );
    });

    group('CoffeeFavoritesRequested', () {
      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeFavoritesLoadInProgress, CoffeeFavoritesLoadSuccess] '
        'when favorites load succeeds',
        build: () {
          when(() => repository.loadFavorites()).thenAnswer(
            (_) async => const [
              CoffeeImage(path: '/tmp/a.jpg'),
              CoffeeImage(path: '/tmp/b.jpg'),
            ],
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeFavoritesRequested()),
        expect: () => const <CoffeeState>[
          CoffeeFavoritesLoadInProgress(),
          CoffeeFavoritesLoadSuccess(
            [
              CoffeeImage(path: '/tmp/a.jpg'),
              CoffeeImage(path: '/tmp/b.jpg'),
            ],
          ),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeFavoritesLoadInProgress, CoffeeFavoritesLoadFailure] '
        'when CoffeeRepositoryLoadFailure is thrown',
        build: () {
          when(() => repository.loadFavorites()).thenThrow(
            const CoffeeRepositoryLoadFailure('favorites failed'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeFavoritesRequested()),
        expect: () => const <CoffeeState>[
          CoffeeFavoritesLoadInProgress(),
          CoffeeFavoritesLoadFailure('favorites failed'),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeFavoritesLoadInProgress, CoffeeFavoritesLoadFailure] '
        'when an unexpected Exception is thrown',
        build: () {
          when(() => repository.loadFavorites()).thenThrow(
            Exception('boom'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeFavoritesRequested()),
        expect: () => <CoffeeState>[
          const CoffeeFavoritesLoadInProgress(),
          const CoffeeFavoritesLoadFailure(
            'Unexpected error: Exception: boom',
          ),
        ],
      );
    });

    group('CoffeeFavoriteDeleted', () {
      const image = CoffeeImage(path: '/tmp/a.jpg');

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeFavoritesLoadInProgress, CoffeeFavoritesLoadSuccess] '
        'when delete succeeds',
        build: () {
          when(() => repository.deleteFavorite(image)).thenAnswer(
            (_) async {},
          );
          when(() => repository.loadFavorites()).thenAnswer(
            (_) async => const [CoffeeImage(path: '/tmp/b.jpg')],
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeFavoriteDeleted(image)),
        expect: () => const <CoffeeState>[
          CoffeeFavoritesLoadInProgress(),
          CoffeeFavoritesLoadSuccess(
            [CoffeeImage(path: '/tmp/b.jpg')],
          ),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeFavoritesLoadInProgress, CoffeeFavoritesLoadFailure] '
        'when CoffeeRepositoryDeleteFailure is thrown',
        build: () {
          when(() => repository.deleteFavorite(image)).thenThrow(
            const CoffeeRepositoryDeleteFailure('delete failed'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeFavoriteDeleted(image)),
        expect: () => const <CoffeeState>[
          CoffeeFavoritesLoadInProgress(),
          CoffeeFavoritesLoadFailure('delete failed'),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeFavoritesLoadInProgress, CoffeeFavoritesLoadFailure] '
        'when unexpected exception is thrown',
        build: () {
          when(() => repository.deleteFavorite(image)).thenThrow(
            Exception('boom'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeFavoriteDeleted(image)),
        expect: () => <CoffeeState>[
          const CoffeeFavoritesLoadInProgress(),
          const CoffeeFavoritesLoadFailure('Unexpected error: Exception: boom'),
        ],
      );

      blocTest<CoffeeBloc, CoffeeState>(
        'emits [CoffeeFavoritesLoadInProgress, CoffeeFavoritesLoadFailure] '
        'when loading favorites after delete fails',
        build: () {
          when(() => repository.deleteFavorite(image)).thenAnswer(
            (_) async {},
          );
          when(() => repository.loadFavorites()).thenThrow(
            const CoffeeRepositoryLoadFailure('load failed'),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const CoffeeFavoriteDeleted(image)),
        expect: () => const <CoffeeState>[
          CoffeeFavoritesLoadInProgress(),
          CoffeeFavoritesLoadFailure('load failed'),
        ],
      );
    });
  });
}
