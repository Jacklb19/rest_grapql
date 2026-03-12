/// Modelo liviano para la lista — no carga todos los campos,
/// solo lo necesario para mostrar en el HomeScreen.
class PokemonPreview {
  final int id;
  final String name;

  const PokemonPreview({required this.id, required this.name});

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  factory PokemonPreview.fromJson(Map<String, dynamic> json) {
    // La URL de la API tiene la forma: https://pokeapi.co/api/v2/pokemon/1/
    final url = json['url'] as String;
    final id = int.parse(url.split('/').where((s) => s.isNotEmpty).last);
    return PokemonPreview(id: id, name: json['name'] as String);
  }
}