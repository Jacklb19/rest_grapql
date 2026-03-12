class PokemonStat {
  final String name;
  final int value;
  const PokemonStat({required this.name, required this.value});
}

class Pokemon {
  final int id;
  final String name;
  final int height;
  final int weight;
  final int baseExperience;
  final List<String> types;
  final List<String> abilities;
  final List<PokemonStat> stats;
  final String? imageUrl;
  final String source; // 'REST' o 'GraphQL'
  final Duration fetchDuration;

  const Pokemon({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.baseExperience,
    required this.types,
    required this.abilities,
    required this.stats,
    required this.source,
    required this.fetchDuration,
    this.imageUrl,
  });
}