import 'package:bloc/bloc.dart';
import 'package:coffee_repository/coffee_repository.dart';
import 'package:equatable/equatable.dart';

part 'coffee_event.dart';
part 'coffee_state.dart';

class CoffeeBloc extends Bloc<CoffeeEvent, CoffeeState> {
  CoffeeBloc({required CoffeeRepository repository})
    : _repository = repository,
      super(const CoffeeInitial()) {
    on<CoffeeRequested>(_onCoffeeRequested);
    on<CoffeeSaved>(_onCoffeeSaved);
    on<CoffeeFavoritesRequested>(_onCoffeeFavoritesRequested);
    on<CoffeeFavoriteDeleted>(_onCoffeeFavoriteDeleted);
  }

  final CoffeeRepository _repository;

  Future<void> _onCoffeeRequested(
    CoffeeRequested event,
    Emitter<CoffeeState> emit,
  ) async {
    emit(const CoffeeLoadInProgress());
    try {
      final url = await _repository.fetchRandomCoffeeImageUrl();
      emit(CoffeeLoadSuccess(url));
    } on CoffeeRepositoryLoadFailure catch (e) {
      emit(CoffeeLoadFailure(e.message));
    } on Exception catch (e) {
      emit(CoffeeLoadFailure('Unexpected error: $e'));
    }
  }

  Future<void> _onCoffeeSaved(
    CoffeeSaved event,
    Emitter<CoffeeState> emit,
  ) async {
    emit(const CoffeeLoadInProgress());
    try {
      await _repository.saveFavorite(event.imageUrl);
      final url = await _repository.fetchRandomCoffeeImageUrl();
      emit(CoffeeLoadSuccess(url));
    } on CoffeeRepositoryDownloadFailure catch (e) {
      emit(
        CoffeeDownloadFailure(
          message: 'Could not save image: ${e.message}',
          imageUrl: event.imageUrl,
        ),
      );
    } on CoffeeRepositoryLoadFailure catch (e) {
      emit(CoffeeLoadFailure(e.message));
    } on Exception catch (e) {
      emit(CoffeeLoadFailure('Unexpected error: $e'));
    }
  }

  Future<void> _onCoffeeFavoritesRequested(
    CoffeeFavoritesRequested event,
    Emitter<CoffeeState> emit,
  ) async {
    emit(const CoffeeFavoritesLoadInProgress());
    try {
      final favorites = await _repository.loadFavorites();
      emit(CoffeeFavoritesLoadSuccess(favorites));
    } on CoffeeRepositoryLoadFailure catch (e) {
      emit(CoffeeFavoritesLoadFailure(e.message));
    } on Exception catch (e) {
      emit(CoffeeFavoritesLoadFailure('Unexpected error: $e'));
    }
  }

  Future<void> _onCoffeeFavoriteDeleted(
    CoffeeFavoriteDeleted event,
    Emitter<CoffeeState> emit,
  ) async {
    emit(const CoffeeFavoritesLoadInProgress());
    try {
      await _repository.deleteFavorite(event.coffeeImage);
      final favorites = await _repository.loadFavorites();
      emit(CoffeeFavoritesLoadSuccess(favorites));
    } on CoffeeRepositoryDeleteFailure catch (e) {
      emit(CoffeeFavoritesLoadFailure(e.message));
    } on CoffeeRepositoryLoadFailure catch (e) {
      emit(CoffeeFavoritesLoadFailure(e.message));
    } on Exception catch (e) {
      emit(CoffeeFavoritesLoadFailure('Unexpected error: $e'));
    }
  }
}
