import '../../domain/entities/pokemon_preview.dart';
import '../../domain/repositories/pokedex_repository.dart';
import '../datasources/favorites_datasource.dart';
import '../datasources/pokemon_list_datasource.dart';

class PokedexRepositoryImpl implements PokedexRepository {
  final PokemonListDatasource listDs;
  final FavoritesDatasource favDs;

  PokedexRepositoryImpl({required this.listDs, required this.favDs});

  @override
  Future<({List<PokemonPreview> items, bool hasMore, int nextOffset})>
  getPokemonList({int offset = 0, int limit = 20}) =>
      listDs.getPokemonList(offset: offset, limit: limit);

  @override
  Future<List<int>> getFavoriteIds() => favDs.getAll();

  @override
  Future<void> addFavorite(int id) => favDs.add(id);

  @override
  Future<void> removeFavorite(int id) => favDs.remove(id);

  @override
  Future<bool> isFavorite(int id) => favDs.contains(id);
}