import 'pokemon.dart';

class CompareResult {
  final Pokemon restPokemon;
  final Pokemon graphqlPokemon;

  const CompareResult({
    required this.restPokemon,
    required this.graphqlPokemon,
  });

  // Diferencia de tiempo de respuesta
  Duration get timeDifference =>
      (restPokemon.fetchDuration - graphqlPokemon.fetchDuration).abs();

  bool get restWasFaster =>
      restPokemon.fetchDuration < graphqlPokemon.fetchDuration;
}