import 'package:coffee_repository/coffee_repository.dart' show CoffeeRepository;
import 'package:coffee_repository/src/coffee_repository.dart'
    show CoffeeRepository;
import 'package:meta/meta.dart';

/// Base class for all exceptions thrown by the [CoffeeRepository].
///
/// Repository exceptions represent domain-level failures. They are
/// normalized errors that can be surfaced to the UI layer or handled
/// by blocs without exposing lower-level implementation details.
@immutable
sealed class CoffeeRepositoryException implements Exception {
  /// Creates a new [CoffeeRepositoryException].
  const CoffeeRepositoryException();
}

/// Exception thrown when downloading a coffee image fails.
///
/// This typically occurs when the network request fails, when the file
/// cannot be written to disk, or when the response stream cannot be read.
class CoffeeRepositoryDownloadFailure extends CoffeeRepositoryException {
  /// Creates a new [CoffeeRepositoryDownloadFailure].
  ///
  /// The [message] property contains additional context about the
  /// underlying failure.
  const CoffeeRepositoryDownloadFailure(this.message);

  /// Description of the underlying failure.
  final String message;
}

/// Exception thrown when deleting a stored favorite fails.
///
/// This can happen when the file cannot be found or when the underlying
/// filesystem operation fails unexpectedly.
class CoffeeRepositoryDeleteFailure extends CoffeeRepositoryException {
  /// Creates a new [CoffeeRepositoryDeleteFailure].
  ///
  /// The [message] property contains additional context about the failure.
  const CoffeeRepositoryDeleteFailure(this.message);

  /// Description of the underlying failure.
  final String message;
}

/// Exception thrown when reading stored favorite images fails.
///
/// This happens when the favorites directory cannot be accessed or when
/// an unexpected filesystem error is encountered.
class CoffeeRepositoryLoadFailure extends CoffeeRepositoryException {
  /// Creates a new [CoffeeRepositoryLoadFailure].
  ///
  /// The [message] property contains additional context about the failure.
  const CoffeeRepositoryLoadFailure(this.message);

  /// Description of the underlying failure.
  final String message;
}
