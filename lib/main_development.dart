import 'package:very_good_coffee/app/app.dart';
import 'package:very_good_coffee/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
