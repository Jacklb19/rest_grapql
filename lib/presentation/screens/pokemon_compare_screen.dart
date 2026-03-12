import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/compare_result.dart';
import '../providers/compare_provider.dart';

// Paleta
const _bg = Color(0xFF0F1117);
const _card = Color(0xFF1C1F2E);
const _restColor = Color(0xFF4FC3F7);    // azul REST
const _graphqlColor = Color(0xFFE040FB); // morado GraphQL
const _accent = Color(0xFFFFD54F);

class PokemonCompareScreen extends ConsumerStatefulWidget {
  const PokemonCompareScreen({super.key});

  @override
  ConsumerState<PokemonCompareScreen> createState() =>
      _PokemonCompareScreenState();
}

class _PokemonCompareScreenState extends ConsumerState<PokemonCompareScreen> {
  final _controller = TextEditingController();

  // Pokémon sugeridos para buscar rápido
  final _suggestions = [
    'pikachu', 'charizard', 'mewtwo', 'gengar', 'lucario', 'eevee',
  ];

  void _search([String? name]) {
    final query = name ?? _controller.text;
    if (query.trim().isEmpty) return;
    _controller.text = query;
    FocusScope.of(context).unfocus();
    ref.read(compareProvider.notifier).compare(query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compareProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'REST  vs  GraphQL',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                _ProtocolBadge(label: 'REST', color: _restColor),
                const SizedBox(width: 6),
                _ProtocolBadge(label: 'GraphQL', color: _graphqlColor),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Buscador ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _search(),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Nombre del Pokémon (ej: pikachu)',
                      hintStyle:
                      TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: _card,
                      prefixIcon: const Icon(Icons.catching_pokemon,
                          color: _accent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: state.status == CompareStatus.loading
                      ? null
                      : () => _search(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Buscar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // ── Sugerencias ─────────────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _search(_suggestions[i]),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: Text(
                    _suggestions[i],
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),

          // ── Contenido principal ─────────────────────────────────────────
          Expanded(
            child: switch (state.status) {
              CompareStatus.initial => _buildInitial(),
              CompareStatus.loading => _buildLoading(),
              CompareStatus.error =>
                  _buildError(state.errorMessage ?? 'Error desconocido'),
              CompareStatus.success => _buildCompare(state.result!),
            },
          ),
        ],
      ),
    );
  }

  // ─── Estados ─────────────────────────────────────────────────────────────

  Widget _buildInitial() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('⚡', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 12),
        Text(
          'Busca un Pokémon para ver la diferencia\nentre REST y GraphQL lado a lado',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
        ),
      ],
    ),
  );

  Widget _buildLoading() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PulsingDot(color: _restColor),
            const SizedBox(width: 16),
            const Text('⚡',
                style: TextStyle(fontSize: 24, color: Colors.grey)),
            const SizedBox(width: 16),
            _PulsingDot(color: _graphqlColor),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Consultando REST y GraphQL en paralelo...',
          style: TextStyle(color: Colors.grey.shade400),
        ),
      ],
    ),
  );

  Widget _buildError(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😵', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(msg,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _search(),
            style: ElevatedButton.styleFrom(backgroundColor: _accent),
            child: const Text('Reintentar',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    ),
  );

  Widget _buildCompare(CompareResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── Banner de velocidad ────────────────────────────────────────
          _SpeedBanner(result: result),
          const SizedBox(height: 16),

          // ── Imagen + nombre centrado ───────────────────────────────────
          _PokemonHeader(pokemon: result.restPokemon),
          const SizedBox(height: 16),

          // ── Comparación campo a campo ──────────────────────────────────
          _SectionTitle(title: '📦 Datos recibidos'),
          const SizedBox(height: 8),
          _CompareTable(rest: result.restPokemon, graphql: result.graphqlPokemon),
          const SizedBox(height: 16),

          // ── Tipos ──────────────────────────────────────────────────────
          _SectionTitle(title: '🏷️ Tipos'),
          const SizedBox(height: 8),
          _TypesRow(rest: result.restPokemon, graphql: result.graphqlPokemon),
          const SizedBox(height: 16),

          // ── Stats ──────────────────────────────────────────────────────
          _SectionTitle(title: '📊 Stats base'),
          const SizedBox(height: 8),
          _StatsComparison(
              restStats: result.restPokemon.stats,
              graphqlStats: result.graphqlPokemon.stats),
          const SizedBox(height: 16),

          // ── Payload explicado ──────────────────────────────────────────
          _PayloadExplainer(),
        ],
      ),
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────

class _ProtocolBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _ProtocolBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Text(label,
        style: TextStyle(
            color: color, fontWeight: FontWeight.bold, fontSize: 12)),
  );
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
          color: widget.color, shape: BoxShape.circle),
    ),
  );
}

class _SpeedBanner extends StatelessWidget {
  final CompareResult result;
  const _SpeedBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final faster = result.restWasFaster ? 'REST' : 'GraphQL';
    final fasterColor = result.restWasFaster ? _restColor : _graphqlColor;
    final diff = result.timeDifference.inMilliseconds;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fasterColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TimeChip(
              label: 'REST',
              ms: result.restPokemon.fetchDuration.inMilliseconds,
              color: _restColor,
              isFaster: result.restWasFaster,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text('⚡',
                    style: TextStyle(fontSize: 20, color: fasterColor)),
                Text(
                  '$faster\n${diff}ms antes',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: fasterColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: _TimeChip(
              label: 'GraphQL',
              ms: result.graphqlPokemon.fetchDuration.inMilliseconds,
              color: _graphqlColor,
              isFaster: !result.restWasFaster,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final int ms;
  final Color color;
  final bool isFaster;
  const _TimeChip(
      {required this.label,
        required this.ms,
        required this.color,
        required this.isFaster});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          if (isFaster) ...[
            const SizedBox(width: 4),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('más rápido',
                  style: TextStyle(color: color, fontSize: 9)),
            ),
          ]
        ],
      ),
      const SizedBox(height: 4),
      Text('${ms}ms',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold)),
    ],
  );
}

class _PokemonHeader extends StatelessWidget {
  final Pokemon pokemon;
  const _PokemonHeader({required this.pokemon});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (pokemon.imageUrl != null)
        Image.network(
          pokemon.imageUrl!,
          width: 120,
          height: 120,
          errorBuilder: (_, __, ___) => const Icon(Icons.catching_pokemon,
              size: 80, color: _accent),
        ),
      const SizedBox(width: 16),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#${pokemon.id}',
            style: TextStyle(
                color: Colors.grey.shade500, fontSize: 14),
          ),
          Text(
            pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(title,
        style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14)),
  );
}

class _CompareTable extends StatelessWidget {
  final Pokemon rest;
  final Pokemon graphql;
  const _CompareTable({required this.rest, required this.graphql});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Altura', '${rest.height / 10} m', '${graphql.height / 10} m'),
      ('Peso', '${rest.weight / 10} kg', '${graphql.weight / 10} kg'),
      ('Exp. base', '${rest.baseExperience}', '${graphql.baseExperience}'),
      ('Habilidades', '${rest.abilities.length}', '${graphql.abilities.length}'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text('Campo',
                        style: TextStyle(
                            color: Colors.grey, fontSize: 12))),
                Expanded(
                    child: Text('REST',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _restColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                Expanded(
                    child: Text('GraphQL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: _graphqlColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          ...rows.map((r) => _TableRow(label: r.$1, rest: r.$2, graphql: r.$3)),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final String label;
  final String rest;
  final String graphql;
  const _TableRow(
      {required this.label, required this.rest, required this.graphql});

  @override
  Widget build(BuildContext context) => Padding(
    padding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13))),
        Expanded(
            child: Text(rest,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13))),
        Expanded(
            child: Text(graphql,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontSize: 13))),
      ],
    ),
  );
}

class _TypesRow extends StatelessWidget {
  final Pokemon rest;
  final Pokemon graphql;
  const _TypesRow({required this.rest, required this.graphql});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
          child: _TypeChips(types: rest.types, color: _restColor)),
      const SizedBox(width: 12),
      Expanded(
          child: _TypeChips(types: graphql.types, color: _graphqlColor)),
    ],
  );
}

class _TypeChips extends StatelessWidget {
  final List<String> types;
  final Color color;
  const _TypeChips({required this.types, required this.color});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    children: types
        .map((t) => Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(t,
          style: TextStyle(color: color, fontSize: 12)),
    ))
        .toList(),
  );
}

class _StatsComparison extends StatelessWidget {
  final List<PokemonStat> restStats;
  final List<PokemonStat> graphqlStats;
  const _StatsComparison(
      {required this.restStats, required this.graphqlStats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: restStats.map((stat) {
          final gStat = graphqlStats
              .firstWhere((s) => s.name == stat.name,
              orElse: () => PokemonStat(name: stat.name, value: 0));
          final maxVal = 255.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.name,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
                const SizedBox(height: 4),
                // Barra REST
                _StatBar(
                    value: stat.value,
                    max: maxVal,
                    color: _restColor,
                    label: 'REST ${stat.value}'),
                const SizedBox(height: 3),
                // Barra GraphQL
                _StatBar(
                    value: gStat.value,
                    max: maxVal,
                    color: _graphqlColor,
                    label: 'GQL ${gStat.value}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  final int value;
  final double max;
  final Color color;
  final String label;
  const _StatBar(
      {required this.value,
        required this.max,
        required this.color,
        required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      SizedBox(
          width: 60,
          child: Text(label,
              style: TextStyle(color: color, fontSize: 10))),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / max,
            backgroundColor: Colors.white12,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ),
    ],
  );
}

class _PayloadExplainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('💡 ¿Por qué importa la diferencia?',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        const SizedBox(height: 12),
        _ExplainRow(
          color: _restColor,
          label: 'REST',
          text:
          'Retorna ~200 campos aunque solo uses 10. El servidor decide qué enviarte.',
        ),
        const SizedBox(height: 8),
        _ExplainRow(
          color: _graphqlColor,
          label: 'GraphQL',
          text:
          'Retorna exactamente los campos que pediste en la query. Tú decides.',
        ),
      ],
    ),
  );
}

class _ExplainRow extends StatelessWidget {
  final Color color;
  final String label;
  final String text;
  const _ExplainRow(
      {required this.color, required this.label, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 11)),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(text,
            style: const TextStyle(
                color: Colors.white60, fontSize: 12)),
      ),
    ],
  );
}