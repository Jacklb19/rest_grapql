import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/entities/pokemon.dart';

class PokeApiRestDatasource {
  final Dio _dio;

  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  // Campos que la app REALMENTE usa de los ~47 que REST retorna
  static const List<String> _usedFields = [
    'id', 'name', 'height', 'weight', 'base_experience',
    'types', 'abilities', 'stats', 'sprites',
  ];

  PokeApiRestDatasource()
      : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Pokemon> getPokemon(String nameOrId) async {
    final sw = Stopwatch()..start();

    try {
      final response = await _dio.get('/pokemon/$nameOrId');
      sw.stop();

      final data = response.data as Map<String, dynamic>;

      // Medimos el payload real
      final rawJson = json.encode(data);
      final payloadBytes = utf8.encode(rawJson).length;

      // Todos los campos raíz que REST retornó
      final allFields = data.keys.toList();

      final types = (data['types'] as List)
          .map((t) => t['type']['name'] as String)
          .toList();

      final abilities = (data['abilities'] as List)
          .map((a) => a['ability']['name'] as String)
          .toList();

      final stats = (data['stats'] as List)
          .map((s) => PokemonStat(
        name: s['stat']['name'] as String,
        value: s['base_stat'] as int,
      ))
          .toList();

      final sprites = data['sprites'] as Map<String, dynamic>;
      final imageUrl =
          sprites['other']?['official-artwork']?['front_default'] as String? ??
              sprites['front_default'] as String?;

      return Pokemon(
        id: data['id'] as int,
        name: data['name'] as String,
        height: data['height'] as int,
        weight: data['weight'] as int,
        baseExperience: data['base_experience'] as int? ?? 0,
        types: types,
        abilities: abilities,
        stats: stats,
        imageUrl: imageUrl,
        source: 'REST',
        fetchDuration: sw.elapsed,
        allFieldsReceived: allFields,
        fieldsUsed: _usedFields,
        payloadBytes: payloadBytes,
      );
    } on DioException catch (e) {
      sw.stop();
      if (e.response?.statusCode == 404) {
        throw Exception('Pokémon "$nameOrId" no encontrado.');
      }
      throw Exception('Error REST: ${e.message}');
    }
  }
}