import 'dart:io';

import 'package:coffee_api/coffee_api.dart';
import 'package:coffee_repository/coffee_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:very_good_coffee/app/app.dart';
import 'package:very_good_coffee/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() async {
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final favoritesDirectory = Directory(
      '${appDocumentsDirectory.path}/favorites_stg',
    );

    final coffeeRepository = CoffeeRepository(
      coffeeApi: CoffeeApi(),
      favoritesDirectory: favoritesDirectory,
    );

    return App(coffeeRepository: coffeeRepository);
  });
}
