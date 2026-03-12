import '../entities/compare_result.dart';
import '../repositories/pokemon_repository.dart';

class ComparePokemonUseCase {
  final PokemonRepository repository;

  ComparePokemonUseCase({required this.repository});

  /// Dispara REST y GraphQL al mismo tiempo con Future.wait
  Future<CompareResult> execute(String nameOrId) async {
    final name = nameOrId.trim().toLowerCase();

    final results = await Future.wait([
      repository.getPokemonRest(name),
      repository.getPokemonGraphql(name),
    ]);

    return CompareResult(
      restPokemon: results[0],
      graphqlPokemon: results[1],
    );
  }
}