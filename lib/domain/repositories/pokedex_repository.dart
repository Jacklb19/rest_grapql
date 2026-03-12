import '../entities/pokemon_preview.dart';

abstract class PokedexRepository {
  /// Obtiene página de Pokémon para el HomeScreen (REST, offset-based)
  Future<({List<PokemonPreview> items, bool hasMore, int nextOffset})>
  getPokemonList({int offset = 0, int limit = 20});

  /// Favoritos — persistidos localmente con shared_preferences
  Future<List<int>> getFavoriteIds();
  Future<void> addFavorite(int id);
  Future<void> removeFavorite(int id);
  Future<bool> isFavorite(int id);
}