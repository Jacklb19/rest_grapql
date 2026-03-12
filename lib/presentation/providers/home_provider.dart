import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/favorites_datasource.dart';
import '../../data/datasources/pokemon_list_datasource.dart';
import '../../data/repositories/pokedex_repository_impl.dart';
import '../../domain/entities/pokemon_preview.dart';
import '../../domain/usecases/get_pokemon_list_usecase.dart';
import '../../domain/usecases/toggle_favorite_usecase.dart';

// ─── Infraestructura ──────────────────────────────────────────────────────

final pokemonListDsProvider =
Provider<PokemonListDatasource>((_) => PokemonListDatasource());

final favoritesDsProvider =
Provider<FavoritesDatasource>((_) => FavoritesDatasource());

final pokedexRepoProvider = Provider<PokedexRepositoryImpl>((ref) {
  return PokedexRepositoryImpl(
    listDs: ref.watch(pokemonListDsProvider),
    favDs: ref.watch(favoritesDsProvider),
  );
});

final getListUseCaseProvider = Provider<GetPokemonListUseCase>((ref) {
  return GetPokemonListUseCase(repository: ref.watch(pokedexRepoProvider));
});

final toggleFavUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(repository: ref.watch(pokedexRepoProvider));
});

// ─── State HomeScreen ─────────────────────────────────────────────────────

class HomeState {
  final List<PokemonPreview> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int nextOffset;
  final String? error;

  const HomeState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.nextOffset = 0,
    this.error,
  });

  HomeState copyWith({
    List<PokemonPreview>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? nextOffset,
    String? error,
  }) =>
      HomeState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        nextOffset: nextOffset ?? this.nextOffset,
        error: error ?? this.error,
      );
}

class HomeNotifier extends StateNotifier<HomeState> {
  final GetPokemonListUseCase _useCase;
  HomeNotifier(this._useCase) : super(const HomeState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _useCase.execute(offset: 0);
      state = state.copyWith(
        items: result.items,
        hasMore: result.hasMore,
        nextOffset: result.nextOffset,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final result = await _useCase.execute(offset: state.nextOffset);
      state = state.copyWith(
        items: [...state.items, ...result.items],
        hasMore: result.hasMore,
        nextOffset: result.nextOffset,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(ref.watch(getListUseCaseProvider));
});

// ─── Favoritos ────────────────────────────────────────────────────────────

class FavoritesNotifier extends StateNotifier<Set<int>> {
  final ToggleFavoriteUseCase _toggleUseCase;
  final PokedexRepositoryImpl _repo;

  FavoritesNotifier(this._toggleUseCase, this._repo) : super({}) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final ids = await _repo.getFavoriteIds();
    state = ids.toSet();
  }

  Future<void> toggle(int id) async {
    final isNowFav = await _toggleUseCase.execute(id);
    if (isNowFav) {
      state = {...state, id};
    } else {
      state = state.where((e) => e != id).toSet();
    }
  }

  bool isFavorite(int id) => state.contains(id);
}

final favoritesProvider =
StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  return FavoritesNotifier(
    ref.watch(toggleFavUseCaseProvider),
    ref.watch(pokedexRepoProvider),
  );
});