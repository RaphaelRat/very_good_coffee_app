import 'package:equatable/equatable.dart';

/// {@template coffee_image}
/// Model representing a locally stored coffee image.
/// {@endtemplate}
class CoffeeImage extends Equatable {
  /// Creates a new [CoffeeImage] instance.
  const CoffeeImage({
    required this.path,
  });

  /// Absolute path to the image stored on disk.
  final String path;

  @override
  List<Object?> get props => [path];
}
