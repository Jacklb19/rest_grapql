import '../entities/pokemon.dart';

abstract class PokemonRepository {
  /// Obtiene un Pokémon via REST (PokéAPI REST)
  Future<Pokemon> getPokemonRest(String nameOrId);

  /// Obtiene el mismo Pokémon via GraphQL (PokéAPI GraphQL beta)
  Future<Pokemon> getPokemonGraphql(String nameOrId);
}