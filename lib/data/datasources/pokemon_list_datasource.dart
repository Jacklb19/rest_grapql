import 'package:dio/dio.dart';
import '../../domain/entities/pokemon_preview.dart';

class PokemonListDatasource {
  final Dio _dio;

  static const _baseUrl = 'https://pokeapi.co/api/v2';

  PokemonListDatasource()
      : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<({List<PokemonPreview> items, bool hasMore, int nextOffset})>
  getPokemonList({int offset = 0, int limit = 20}) async {
    final response = await _dio.get('/pokemon', queryParameters: {
      'offset': offset,
      'limit': limit,
    });

    final data = response.data as Map<String, dynamic>;
    final results = (data['results'] as List)
        .map((e) => PokemonPreview.fromJson(e as Map<String, dynamic>))
        .toList();

    return (
    items: results,
    hasMore: data['next'] != null,
    nextOffset: offset + limit,
    );
  }
}