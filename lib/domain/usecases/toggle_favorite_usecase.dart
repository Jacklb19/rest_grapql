import '../repositories/pokedex_repository.dart';

class ToggleFavoriteUseCase {
  final PokedexRepository repository;
  ToggleFavoriteUseCase({required this.repository});

  Future<bool> execute(int pokemonId) async {
    final already = await repository.isFavorite(pokemonId);
    if (already) {
      await repository.removeFavorite(pokemonId);
      return false; // ya no es favorito
    } else {
      await repository.addFavorite(pokemonId);
      return true; // ahora es favorito
    }
  }
}