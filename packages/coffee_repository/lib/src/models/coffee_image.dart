import 'package:meta/meta.dart';

/// {@template coffee_image}
/// Model representing a locally stored coffee image.
/// {@endtemplate}
@immutable
class CoffeeImage {
  /// Creates a new [CoffeeImage] instance.
  const CoffeeImage({
    required this.path,
  });

  /// Absolute path to the image stored on disk.
  final String path;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CoffeeImage && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
