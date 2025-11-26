import 'dart:io';

import 'package:coffee_repository/coffee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_coffee/coffee/bloc/coffee_bloc.dart';
import 'package:very_good_coffee/l10n/l10n.dart';

class CoffeeFavoritesPage extends StatelessWidget {
  const CoffeeFavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoffeeBloc(
        repository: context.read<CoffeeRepository>(),
      )..add(const CoffeeFavoritesRequested()),
      child: const CoffeeFavoritesView(),
    );
  }
}

class CoffeeFavoritesView extends StatelessWidget {
  const CoffeeFavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.coffeeFavoritesTitle)),
      body: SafeArea(
        child: BlocBuilder<CoffeeBloc, CoffeeState>(
          builder: (context, state) {
            return switch (state) {
              CoffeeFavoritesLoadSuccess(:final favorites) => _FavoritesList(
                favorites: favorites,
              ),
              CoffeeFavoritesLoadFailure(:final message) => _FavoritesError(
                message: message,
                onRetry: () => context.read<CoffeeBloc>().add(
                  const CoffeeFavoritesRequested(),
                ),
              ),
              CoffeeFavoritesLoadInProgress() => const _FavoritesLoading(),
              _ => const _FavoritesLoading(),
            };
          },
        ),
      ),
    );
  }
}

class _FavoritesLoading extends StatelessWidget {
  const _FavoritesLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _FavoritesError extends StatelessWidget {
  const _FavoritesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.coffeeRetryButtonLabel),
          ),
        ],
      ),
    );
  }
}

class _FavoritesList extends StatelessWidget {
  const _FavoritesList({required this.favorites});

  final List<CoffeeImage> favorites;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.coffeeFavoritesEmptyLabel,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<CoffeeBloc>().add(const CoffeeFavoritesRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final coffeeImage = favorites[index];
          final file = File(coffeeImage.path);

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                  if (file.existsSync())
                    Image.file(
                      file,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _FavoriteImageError(
                        path: coffeeImage.path,
                      ),
                    )
                  else
                    _FavoriteImageError(path: coffeeImage.path),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        key: ValueKey('favorite_delete_${coffeeImage.path}'),
                        icon: const Icon(Icons.delete_outline),
                        color: Colors.white,
                        tooltip: context.l10n.coffeeFavoriteDeleteTooltip,
                        onPressed: () {
                          context.read<CoffeeBloc>().add(
                            CoffeeFavoriteDeleted(coffeeImage),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FavoriteImageError extends StatelessWidget {
  const _FavoriteImageError({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            context.l10n.coffeeFavoriteImageErrorLabel(path),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ),
    );
  }
}
