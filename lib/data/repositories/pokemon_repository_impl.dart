
import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/pokeapi_rest_datasource.dart';
import '../datasources/pokeapi_graphql_datasource.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final PokeApiRestDatasource restDatasource;
  final PokeApiGraphqlDatasource graphqlDatasource;

  PokemonRepositoryImpl({
    required this.restDatasource,
    required this.graphqlDatasource,
  });

  @override
  Future<Pokemon> getPokemonRest(String nameOrId) =>
      restDatasource.getPokemon(nameOrId);

  @override
  Future<Pokemon> getPokemonGraphql(String nameOrId) =>
      graphqlDatasource.getPokemon(nameOrId);
}