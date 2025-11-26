import 'dart:io';

import 'package:coffee_api/coffee_api.dart';
import 'package:coffee_repository/coffee_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockCoffeeApi extends Mock implements CoffeeApi {}

class _MockHttpClient extends Mock implements HttpClient {}

class _FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeUri());
  });

  group('CoffeeRepository', () {
    late CoffeeApi coffeeApi;
    late HttpClient httpClient;
    late Directory tempDir;
    late CoffeeRepository repository;

    setUp(() async {
      coffeeApi = _MockCoffeeApi();
      httpClient = _MockHttpClient();

      tempDir = await Directory.systemTemp.createTemp(
        'coffee_repo_test_',
      );

      repository = CoffeeRepository(
        coffeeApi: coffeeApi,
        favoritesDirectory: tempDir,
        httpClient: httpClient,
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    group('fetchRandomCoffeeImageUrl', () {
      test('returns URL when CoffeeApi succeeds', () async {
        const imageUrl = 'https://example.com/coffee.jpg';

        when(() => coffeeApi.getRandomCoffeeImageUrl()).thenAnswer(
          (_) async => imageUrl,
        );

        final result = await repository.fetchRandomCoffeeImageUrl();

        expect(result, equals(imageUrl));
        verify(() => coffeeApi.getRandomCoffeeImageUrl()).called(1);
      });

      test(
        'throws load failure when CoffeeApiMalformedResponse is thrown',
        () async {
          when(() => coffeeApi.getRandomCoffeeImageUrl()).thenThrow(
            const CoffeeApiMalformedResponse(),
          );

          expect(
            repository.fetchRandomCoffeeImageUrl(),
            throwsA(isA<CoffeeRepositoryLoadFailure>()),
          );
        },
      );

      test(
        'throws load failure when CoffeeApiRequestFailure is thrown',
        () async {
          when(() => coffeeApi.getRandomCoffeeImageUrl()).thenThrow(
            const CoffeeApiRequestFailure(500),
          );

          expect(
            repository.fetchRandomCoffeeImageUrl(),
            throwsA(isA<CoffeeRepositoryLoadFailure>()),
          );
        },
      );

      test(
        'throws load failure for any unknown exception',
        () async {
          when(() => coffeeApi.getRandomCoffeeImageUrl()).thenThrow(
            Exception('boom'),
          );

          expect(
            repository.fetchRandomCoffeeImageUrl(),
            throwsA(isA<CoffeeRepositoryLoadFailure>()),
          );
        },
      );
    });

    group('saveFavorite', () {
      test(
        'throws download failure when HttpClient.getUrl throws',
        () async {
          const imageUrl = 'https://example.com/coffee.jpg';

          when(() => httpClient.getUrl(any())).thenThrow(
            Exception('network error'),
          );

          expect(
            repository.saveFavorite(imageUrl),
            throwsA(isA<CoffeeRepositoryDownloadFailure>()),
          );
        },
      );
    });

    group('loadFavorites', () {
      test(
        'returns empty list when favorites directory does not exist',
        () async {
          if (tempDir.existsSync()) {
            await tempDir.delete(recursive: true);
          }

          final favorites = await repository.loadFavorites();

          expect(favorites, isEmpty);
        },
      );

      test('returns list of CoffeeImage when files are present', () async {
        if (!tempDir.existsSync()) {
          tempDir.createSync(recursive: true);
        }

        final fileA = File('${tempDir.path}/a.jpg');
        final fileB = File('${tempDir.path}/b.jpg');

        await fileA.writeAsBytes([1, 2, 3]);
        await fileB.writeAsBytes([4, 5, 6]);

        final favorites = await repository.loadFavorites();

        expect(favorites.length, equals(2));

        final paths = favorites.map((image) => image.path).toList();
        expect(paths, contains(fileA.path));
        expect(paths, contains(fileB.path));
      });
    });

    group('deleteFavorite', () {
      test('deletes only the specified file', () async {
        if (!tempDir.existsSync()) {
          tempDir.createSync(recursive: true);
        }

        final fileA = File('${tempDir.path}/a.jpg')..writeAsBytesSync([1]);
        final fileB = File('${tempDir.path}/b.jpg')..writeAsBytesSync([2]);

        await repository.deleteFavorite(CoffeeImage(path: fileA.path));

        expect(fileA.existsSync(), isFalse);
        expect(fileB.existsSync(), isTrue);
      });

      test('throws delete failure when file does not exist', () async {
        final missing = CoffeeImage(path: '${tempDir.path}/missing.jpg');

        expect(
          repository.deleteFavorite(missing),
          throwsA(isA<CoffeeRepositoryDeleteFailure>()),
        );
      });
    });
  });
}
