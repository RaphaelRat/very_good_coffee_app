part of 'coffee_bloc.dart';

abstract class CoffeeState extends Equatable {
  const CoffeeState();

  @override
  List<Object?> get props => [];
}

class CoffeeInitial extends CoffeeState {
  const CoffeeInitial();
}

class CoffeeLoadInProgress extends CoffeeState {
  const CoffeeLoadInProgress();
}

class CoffeeLoadSuccess extends CoffeeState {
  const CoffeeLoadSuccess(this.imageUrl);

  final String imageUrl;

  @override
  List<Object?> get props => [imageUrl];
}

class CoffeeDownloadFailure extends CoffeeState {
  const CoffeeDownloadFailure({required this.imageUrl, required this.message});

  final String imageUrl;
  final String message;

  @override
  List<Object?> get props => [imageUrl, message];
}

class CoffeeLoadFailure extends CoffeeState {
  const CoffeeLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CoffeeFavoritesLoadInProgress extends CoffeeState {
  const CoffeeFavoritesLoadInProgress();
}

class CoffeeFavoritesLoadSuccess extends CoffeeState {
  const CoffeeFavoritesLoadSuccess(this.favorites);

  final List<CoffeeImage> favorites;

  @override
  List<Object?> get props => [favorites];
}

class CoffeeFavoritesLoadFailure extends CoffeeState {
  const CoffeeFavoritesLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
