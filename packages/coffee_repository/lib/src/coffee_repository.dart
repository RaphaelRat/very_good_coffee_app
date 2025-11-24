import 'dart:io';

import 'package:coffee_api/coffee_api.dart';
import 'package:coffee_repository/src/exceptions.dart';
import 'package:coffee_repository/src/models/coffee_image.dart';
import 'package:meta/meta.dart';

/// {@template coffee_repository}
/// Repository responsible for fetching coffee images and storing favorites.
///
/// This repository handles:
/// - network calls via [CoffeeApi]
/// - error normalization
/// - downloading images
/// - reading locally stored favorites
/// {@endtemplate}
@immutable
class CoffeeRepository {
  /// Creates a new [CoffeeRepository] instance.
  CoffeeRepository({
    required CoffeeApi coffeeApi,
    Directory? favoritesDirectory,
    HttpClient? httpClient,
  }) : _coffeeApi = coffeeApi,
       _favoritesDirectory =
           favoritesDirectory ??
           Directory('${Directory.current.path}/favorites'),
       _httpClient = httpClient ?? HttpClient();

  final CoffeeApi _coffeeApi;
  final Directory _favoritesDirectory;
  final HttpClient _httpClient;

  /// Fetches a random image URL from the Coffee API.
  Future<String> fetchRandomCoffeeImageUrl() async {
    try {
      return await _coffeeApi.getRandomCoffeeImageUrl();
    } on CoffeeApiMalformedResponse {
      throw const CoffeeRepositoryLoadFailure('Malformed response from API.');
    } on CoffeeApiRequestFailure {
      throw const CoffeeRepositoryLoadFailure('API returned a non-200 error.');
    } catch (e) {
      throw CoffeeRepositoryLoadFailure('Unknown error: $e');
    }
  }

  /// Downloads an image and saves it to disk as a favorite.
  Future<CoffeeImage> saveFavorite(String imageUrl) async {
    try {
      if (!_favoritesDirectory.existsSync()) {
        _favoritesDirectory.createSync(recursive: true);
      }

      final fileName = imageUrl.split('/').last;
      final imagePath = '${_favoritesDirectory.path}/$fileName';

      final request = await _httpClient.getUrl(Uri.parse(imageUrl));
      final response = await request.close();

      final bytes = await response.fold<List<int>>(
        <int>[],
        (buffer, data) => buffer..addAll(data),
      );

      final file = File(imagePath);
      await file.writeAsBytes(bytes);

      return CoffeeImage(path: imagePath);
    } catch (e) {
      throw CoffeeRepositoryDownloadFailure(
        'Failed to download image: $e',
      );
    }
  }

  /// Loads all locally stored favorite images.
  Future<List<CoffeeImage>> loadFavorites() async {
    try {
      if (!_favoritesDirectory.existsSync()) {
        return const [];
      }

      final files = _favoritesDirectory
          .listSync()
          .whereType<File>()
          .map((file) => CoffeeImage(path: file.path))
          .toList();

      return files;
    } catch (e) {
      throw CoffeeRepositoryLoadFailure(
        'Failed to read local favorites: $e',
      );
    }
  }
}
