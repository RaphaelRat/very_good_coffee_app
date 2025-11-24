import 'dart:convert';

import 'package:coffee_api/coffee_api.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  group('CoffeeApi', () {
    late http.Client httpClient;
    late CoffeeApi api;

    setUp(() {
      httpClient = _MockHttpClient();
      api = CoffeeApi(httpClient: httpClient);

      registerFallbackValue(Uri());
    });

    test('uses the provided http client', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'file': 'https://example.com/coffee.jpg'}),
          200,
        ),
      );

      await api.getRandomCoffeeImageUrl();

      verify(() => httpClient.get(any())).called(1);
    });

    test('returns URL when status code is 200 and body is valid', () async {
      const imageUrl = 'https://example.com/coffee.jpg';

      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'file': imageUrl}),
          200,
        ),
      );

      final result = await api.getRandomCoffeeImageUrl();

      expect(result, equals(imageUrl));
    });

    test(
      'throws CoffeeApiRequestFailure when status code is not 200',
      () async {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response('Internal Server Error', 500),
        );

        expect(
          api.getRandomCoffeeImageUrl(),
          throwsA(isA<CoffeeApiRequestFailure>()),
        );
      },
    );

    test(
      'throws CoffeeApiMalformedResponse when body is not valid JSON',
      () async {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response('not-json', 200),
        );

        expect(
          api.getRandomCoffeeImageUrl(),
          throwsA(isA<CoffeeApiMalformedResponse>()),
        );
      },
    );

    test('throws CoffeeApiMalformedResponse when JSON is not a Map', () async {
      when(() => httpClient.get(any())).thenAnswer(
        (_) async => http.Response(
          jsonEncode(['not-a-map']),
          200,
        ),
      );

      expect(
        api.getRandomCoffeeImageUrl(),
        throwsA(isA<CoffeeApiMalformedResponse>()),
      );
    });

    test(
      'throws CoffeeApiMalformedResponse when file field is missing',
      () async {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'foo': 'bar'}),
            200,
          ),
        );

        expect(
          api.getRandomCoffeeImageUrl(),
          throwsA(isA<CoffeeApiMalformedResponse>()),
        );
      },
    );

    test(
      'throws CoffeeApiMalformedResponse when file field is not a String',
      () async {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'file': 123}),
            200,
          ),
        );

        expect(
          api.getRandomCoffeeImageUrl(),
          throwsA(isA<CoffeeApiMalformedResponse>()),
        );
      },
    );

    test(
      'throws CoffeeApiMalformedResponse when file field is empty',
      () async {
        when(() => httpClient.get(any())).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'file': ''}),
            200,
          ),
        );

        expect(
          api.getRandomCoffeeImageUrl(),
          throwsA(isA<CoffeeApiMalformedResponse>()),
        );
      },
    );
  });
}
