import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/entities/pokemon.dart';

class PokeApiGraphqlDatasource {
  late final GraphQLClient _client;

  static const String _endpoint = 'https://beta.pokeapi.co/graphql/v1beta';

  // Exactamente los campos que pedimos — ni uno más
  static const List<String> _requestedFields = [
    'id', 'name', 'height', 'weight', 'base_experience',
    'pokemon_v2_pokemontypes', 'pokemon_v2_pokemonabilities',
    'pokemon_v2_pokemonstats', 'pokemon_v2_pokemonsprites',
  ];

  PokeApiGraphqlDatasource() {
    _client = GraphQLClient(
      link: HttpLink(_endpoint),
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  static const String _pokemonQuery = r'''
    query GetPokemon($name: String!) {
      pokemon_v2_pokemon(where: {name: {_eq: $name}}) {
        id
        name
        height
        weight
        base_experience
        pokemon_v2_pokemontypes {
          pokemon_v2_type { name }
        }
        pokemon_v2_pokemonabilities {
          pokemon_v2_ability { name }
        }
        pokemon_v2_pokemonstats {
          base_stat
          pokemon_v2_stat { name }
        }
        pokemon_v2_pokemonsprites {
          sprites
        }
      }
    }
  ''';

  Future<Pokemon> getPokemon(String nameOrId) async {
    final sw = Stopwatch()..start();

    final result = await _client.query(QueryOptions(
      document: gql(_pokemonQuery),
      variables: {'name': nameOrId},
      fetchPolicy: FetchPolicy.networkOnly,
    ));

    sw.stop();

    if (result.hasException) {
      throw Exception(
          'Error GraphQL: ${result.exception?.graphqlErrors.firstOrNull?.message ?? result.exception.toString()}');
    }

    final list = result.data?['pokemon_v2_pokemon'] as List?;
    if (list == null || list.isEmpty) {
      throw Exception('Pokémon "$nameOrId" no encontrado en GraphQL.');
    }

    final data = list.first as Map<String, dynamic>;

    // Medimos el payload exacto que llegó
    final rawJson = json.encode(data);
    final payloadBytes = utf8.encode(rawJson).length;

    final types = (data['pokemon_v2_pokemontypes'] as List)
        .map((t) => t['pokemon_v2_type']['name'] as String)
        .toList();

    final abilities = (data['pokemon_v2_pokemonabilities'] as List)
        .map((a) => a['pokemon_v2_ability']['name'] as String)
        .toList();

    final stats = (data['pokemon_v2_pokemonstats'] as List)
        .map((s) => PokemonStat(
      name: s['pokemon_v2_stat']['name'] as String,
      value: s['base_stat'] as int,
    ))
        .toList();

    String? imageUrl;
    try {
      final spritesRaw = (data['pokemon_v2_pokemonsprites'] as List).firstOrNull;
      if (spritesRaw != null) {
        final spritesMap = spritesRaw['sprites'] as Map<String, dynamic>?;
        imageUrl = spritesMap?['other']?['official-artwork']?['front_default'] as String? ??
            spritesMap?['front_default'] as String?;
      }
    } catch (_) {}

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
      source: 'GraphQL',
      fetchDuration: sw.elapsed,
      allFieldsReceived: _requestedFields, // GraphQL solo trajo lo que pedimos
      fieldsUsed: _requestedFields,         // 100% de eficiencia
      payloadBytes: payloadBytes,
    );
  }
}