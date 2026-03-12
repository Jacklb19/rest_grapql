import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/pokeapi_rest_datasource.dart';
import '../../data/datasources/pokeapi_graphql_datasource.dart';
import '../../data/repositories/pokemon_repository_impl.dart';
import '../../domain/entities/compare_result.dart';
import '../../domain/usecases/compare_pokemon_usecase.dart';

// ─── Infraestructura ──────────────────────────────────────────────────────

final restDatasourceProvider =
Provider<PokeApiRestDatasource>((_) => PokeApiRestDatasource());

final graphqlDatasourceProvider =
Provider<PokeApiGraphqlDatasource>((_) => PokeApiGraphqlDatasource());

final pokemonRepositoryProvider = Provider<PokemonRepositoryImpl>((ref) {
  return PokemonRepositoryImpl(
    restDatasource: ref.watch(restDatasourceProvider),
    graphqlDatasource: ref.watch(graphqlDatasourceProvider),
  );
});

final compareUseCaseProvider = Provider<ComparePokemonUseCase>((ref) {
  return ComparePokemonUseCase(
    repository: ref.watch(pokemonRepositoryProvider),
  );
});

// ─── State ────────────────────────────────────────────────────────────────

enum CompareStatus { initial, loading, success, error }

class CompareState {
  final CompareStatus status;
  final CompareResult? result;
  final String? errorMessage;
  final String query;

  const CompareState({
    this.status = CompareStatus.initial,
    this.result,
    this.errorMessage,
    this.query = '',
  });

  CompareState copyWith({
    CompareStatus? status,
    CompareResult? result,
    String? errorMessage,
    String? query,
  }) {
    return CompareState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      query: query ?? this.query,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────

class CompareNotifier extends StateNotifier<CompareState> {
  final ComparePokemonUseCase _useCase;

  CompareNotifier(this._useCase) : super(const CompareState());

  Future<void> compare(String nameOrId) async {
    if (nameOrId.trim().isEmpty) return;

    state = CompareState(
      status: CompareStatus.loading,
      query: nameOrId.trim(),
    );

    try {
      final result = await _useCase.execute(nameOrId);
      state = state.copyWith(
        status: CompareStatus.success,
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: CompareStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }
}

// ─── Provider final ───────────────────────────────────────────────────────

final compareProvider =
StateNotifierProvider<CompareNotifier, CompareState>((ref) {
  return CompareNotifier(ref.watch(compareUseCaseProvider));
});