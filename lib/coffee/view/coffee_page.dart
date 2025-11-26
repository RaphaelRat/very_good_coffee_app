import 'package:coffee_repository/coffee_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:very_good_coffee/coffee/bloc/coffee_bloc.dart';
import 'package:very_good_coffee/coffee/view/favorites_page.dart';
import 'package:very_good_coffee/l10n/l10n.dart';

class CoffeePage extends StatelessWidget {
  const CoffeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoffeeBloc(
        repository: context.read<CoffeeRepository>(),
      )..add(const CoffeeRequested()),
      child: const CoffeeView(),
    );
  }
}

class CoffeeView extends StatelessWidget {
  const CoffeeView({super.key});

  static const refreshButtonKey = Key('coffeeView_refreshButton');
  static const saveAndNextButtonKey = Key('coffeeView_saveAndNextButton');
  static const favoritesButtonKey = Key('coffeeView_favoritesButton');

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final coffeeBloc = context.read<CoffeeBloc>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.counterAppBarTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: BlocBuilder<CoffeeBloc, CoffeeState>(
                  builder: (context, state) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: switch (state) {
                        CoffeeLoadSuccess(:final imageUrl) => _CoffeeImageCard(
                          imageUrl: imageUrl,
                        ),
                        CoffeeLoadFailure(:final message) => _ErrorCard(
                          message: message,
                          onRetry: () => coffeeBloc.add(
                            const CoffeeRequested(),
                          ),
                        ),
                        CoffeeDownloadFailure(
                          :final message,
                          :final imageUrl,
                        ) =>
                          _ErrorCard(
                            message: message,
                            onRetry: () =>
                                coffeeBloc.add(CoffeeSaved(imageUrl)),
                          ),

                        CoffeeLoadInProgress() => const _LoadingCard(),
                        _ => const _LoadingCard(),
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<CoffeeBloc, CoffeeState>(
                builder: (context, state) {
                  final isLoading = state is CoffeeLoadInProgress;
                  final imageUrl = state is CoffeeLoadSuccess
                      ? state.imageUrl
                      : null;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              key: refreshButtonKey,
                              onPressed: isLoading
                                  ? null
                                  : () => coffeeBloc.add(
                                      const CoffeeRequested(),
                                    ),
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.coffeeRefreshButtonLabel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              key: saveAndNextButtonKey,
                              onPressed: isLoading || imageUrl == null
                                  ? null
                                  : () => coffeeBloc.add(
                                      CoffeeSaved(imageUrl),
                                    ),
                              icon: const Icon(Icons.favorite),
                              label: Text(l10n.coffeeSaveAndNextButtonLabel),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        key: favoritesButtonKey,
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const CoffeeFavoritesPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: Text(l10n.coffeeFavoritesButtonLabel),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoffeeImageCard extends StatelessWidget {
  const _CoffeeImageCard({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const _LoadingCard();
              },
              errorBuilder: (context, _, _) => _ErrorCard(
                message: context.l10n.coffeeImageLoadErrorLabel,
                onRetry: () =>
                    context.read<CoffeeBloc>().add(const CoffeeRequested()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            context.l10n.coffeeLoadingLabel,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
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
