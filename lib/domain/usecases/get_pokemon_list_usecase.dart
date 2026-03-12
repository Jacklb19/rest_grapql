import '../entities/pokemon_preview.dart';
import '../repositories/pokedex_repository.dart';

class GetPokemonListUseCase {
  final PokedexRepository repository;
  GetPokemonListUseCase({required this.repository});

  Future<({List<PokemonPreview> items, bool hasMore, int nextOffset})>
  execute({int offset = 0}) => repository.getPokemonList(offset: offset);
}