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
  final String source;
  final Duration fetchDuration;

  // Nuevos campos para comparación de payload
  final List<String> allFieldsReceived;  // todos los campos que llegaron
  final List<String> fieldsUsed;         // solo los que la app usó
  final int payloadBytes;                // tamaño real en bytes

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
    required this.allFieldsReceived,
    required this.fieldsUsed,
    required this.payloadBytes,
    this.imageUrl,
  });

  int get wastedFields => allFieldsReceived.length - fieldsUsed.length;
  double get efficiencyPercent =>
      allFieldsReceived.isEmpty
          ? 100
          : (fieldsUsed.length / allFieldsReceived.length) * 100;
}