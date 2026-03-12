import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/compare_result.dart';
import '../providers/compare_provider.dart';

const _bg = Color(0xFF0F1117);
const _card = Color(0xFF1C1F2E);
const _restColor = Color(0xFF4FC3F7);
const _graphqlColor = Color(0xFFE040FB);
const _accent = Color(0xFFFFD54F);
const _used = Color(0xFF4ADE80);
const _wasted = Color(0xFF475569);

class PokemonCompareScreen extends ConsumerStatefulWidget {
  const PokemonCompareScreen({super.key});

  @override
  ConsumerState<PokemonCompareScreen> createState() =>
      _PokemonCompareScreenState();
}

class _PokemonCompareScreenState extends ConsumerState<PokemonCompareScreen> {
  final _controller = TextEditingController();
  final _suggestions = ['pikachu', 'charizard', 'mewtwo', 'gengar', 'lucario', 'eevee'];

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
        title: const Text('REST  vs  GraphQL',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(children: [
              _Badge(label: 'REST', color: _restColor),
              const SizedBox(width: 6),
              _Badge(label: 'GraphQL', color: _graphqlColor),
            ]),
          ),
        ],
      ),
      body: Column(children: [
        // ── Buscador ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Nombre del Pokémon (ej: pikachu)',
                  hintStyle: TextStyle(color: Colors.grey.shade600),
                  filled: true,
                  fillColor: _card,
                  prefixIcon: const Icon(Icons.catching_pokemon, color: _accent),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: state.status == CompareStatus.loading ? null : () => _search(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),
        ),

        // ── Sugerencias ──────────────────────────────────────────────────
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade800),
                ),
                child: Text(_suggestions[i],
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ),
            ),
          ),
        ),

        // ── Contenido ────────────────────────────────────────────────────
        Expanded(
          child: switch (state.status) {
            CompareStatus.initial => _buildInitial(),
            CompareStatus.loading => _buildLoading(),
            CompareStatus.error => _buildError(state.errorMessage ?? ''),
            CompareStatus.success => _buildResults(state.result!),
          },
        ),
      ]),
    );
  }

  Widget _buildInitial() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('⚡', style: TextStyle(fontSize: 64)),
      const SizedBox(height: 12),
      Text('Busca un Pokémon para ver la diferencia\nentre REST y GraphQL lado a lado',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
    ]),
  );

  Widget _buildLoading() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisSize: MainAxisSize.min, children: [
        _Pulse(color: _restColor),
        const SizedBox(width: 16),
        const Text('⚡', style: TextStyle(fontSize: 24, color: Colors.grey)),
        const SizedBox(width: 16),
        _Pulse(color: _graphqlColor),
      ]),
      const SizedBox(height: 16),
      Text('Consultando REST y GraphQL en paralelo...',
          style: TextStyle(color: Colors.grey.shade400)),
    ]),
  );

  Widget _buildError(String msg) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('😵', style: TextStyle(fontSize: 48)),
        const SizedBox(height: 12),
        Text(msg, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _search(),
          style: ElevatedButton.styleFrom(backgroundColor: _accent),
          child: const Text('Reintentar', style: TextStyle(color: Colors.black)),
        ),
      ]),
    ),
  );

  Widget _buildResults(CompareResult result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // 1. Velocidad
        _SpeedBanner(result: result),
        const SizedBox(height: 12),

        // 2. ★ LA TARJETA CLAVE: Payload + campos usados vs desperdiciados
        _PayloadCompareCard(rest: result.restPokemon, graphql: result.graphqlPokemon),
        const SizedBox(height: 12),

        // 3. ★ Lista visual de campos: usados vs desperdiciados
        _FieldsBreakdownCard(rest: result.restPokemon, graphql: result.graphqlPokemon),
        const SizedBox(height: 12),

        // 4. Info del Pokémon
        _PokemonHeader(pokemon: result.restPokemon),
        const SizedBox(height: 12),

        // 5. Stats duales
        _SectionTitle(title: '📊 Stats base'),
        const SizedBox(height: 8),
        _StatsComparison(
            restStats: result.restPokemon.stats,
            graphqlStats: result.graphqlPokemon.stats),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// ★ TARJETA DE PAYLOAD — la más importante
// ══════════════════════════════════════════════════════════════════════════

class _PayloadCompareCard extends StatelessWidget {
  final Pokemon rest;
  final Pokemon graphql;
  const _PayloadCompareCard({required this.rest, required this.graphql});

  String _kb(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

  @override
  Widget build(BuildContext context) {
    final restKb = rest.payloadBytes;
    final gqlKb = graphql.payloadBytes;
    final saved = restKb - gqlKb;
    final pct = restKb > 0 ? ((saved / restKb) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.data_object, color: Colors.grey, size: 16),
          SizedBox(width: 6),
          Text('Tamaño del payload recibido',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
        const SizedBox(height: 16),

        // Números grandes
        Row(children: [
          Expanded(child: _PayloadBlock(
            label: 'REST',
            color: _restColor,
            sizeLabel: _kb(restKb),
            fields: rest.allFieldsReceived.length,
            usedFields: rest.fieldsUsed.length,
          )),
          const SizedBox(width: 12),
          Expanded(child: _PayloadBlock(
            label: 'GraphQL',
            color: _graphqlColor,
            sizeLabel: _kb(gqlKb),
            fields: graphql.allFieldsReceived.length,
            usedFields: graphql.fieldsUsed.length,
          )),
        ]),

        const SizedBox(height: 16),

        // Barra de comparación visual
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: 1.0,
                  backgroundColor: _restColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation(_restColor.withOpacity(0.7)),
                  minHeight: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('REST ${_kb(restKb)}',
                style: const TextStyle(color: _restColor, fontSize: 11)),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: restKb > 0 ? gqlKb / restKb : 0,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation(_graphqlColor.withOpacity(0.8)),
                  minHeight: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('GQL ${_kb(gqlKb)}',
                style: const TextStyle(color: _graphqlColor, fontSize: 11)),
          ]),
        ]),

        const SizedBox(height: 14),

        // Resumen
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _graphqlColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _graphqlColor.withOpacity(0.25)),
          ),
          child: Text(
            'GraphQL ahorró ${_kb(saved)} ($pct% menos datos transferidos)',
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: _graphqlColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ]),
    );
  }
}

class _PayloadBlock extends StatelessWidget {
  final String label;
  final Color color;
  final String sizeLabel;
  final int fields;
  final int usedFields;

  const _PayloadBlock({
    required this.label,
    required this.color,
    required this.sizeLabel,
    required this.fields,
    required this.usedFields,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.07),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Column(children: [
      Text(label, style: TextStyle(
          color: color, fontWeight: FontWeight.bold, fontSize: 12)),
      const SizedBox(height: 6),
      Text(sizeLabel, style: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('$fields campos recibidos',
          style: const TextStyle(color: Colors.grey, fontSize: 10)),
      Text('$usedFields campos usados',
          style: TextStyle(color: color, fontSize: 10,
              fontWeight: FontWeight.bold)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════════════════
// ★ LISTA DE CAMPOS — usados vs desperdiciados
// ══════════════════════════════════════════════════════════════════════════

class _FieldsBreakdownCard extends StatelessWidget {
  final Pokemon rest;
  final Pokemon graphql;
  const _FieldsBreakdownCard({required this.rest, required this.graphql});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.compare_arrows, color: Colors.grey, size: 16),
          SizedBox(width: 6),
          Text('Campos recibidos vs usados',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
        const SizedBox(height: 6),
        // Leyenda
        Row(children: [
          _LegendDot(color: _used, label: 'Usado por la app'),
          const SizedBox(width: 16),
          _LegendDot(color: _wasted, label: 'Recibido pero ignorado'),
        ]),
        const SizedBox(height: 14),

        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Columna REST
          Expanded(child: _FieldColumn(
            label: 'REST',
            color: _restColor,
            allFields: rest.allFieldsReceived,
            usedFields: rest.fieldsUsed,
          )),
          const SizedBox(width: 12),
          // Columna GraphQL
          Expanded(child: _FieldColumn(
            label: 'GraphQL',
            color: _graphqlColor,
            allFields: graphql.allFieldsReceived,
            usedFields: graphql.fieldsUsed,
          )),
        ]),
      ]),
    );
  }
}

class _FieldColumn extends StatelessWidget {
  final String label;
  final Color color;
  final List<String> allFields;
  final List<String> usedFields;

  const _FieldColumn({
    required this.label,
    required this.color,
    required this.allFields,
    required this.usedFields,
  });

  @override
  Widget build(BuildContext context) {
    final usedSet = usedFields.toSet();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text('$label — ${allFields.length} campos',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
      const SizedBox(height: 8),
      ...allFields.map((field) {
        final isUsed = usedSet.contains(field);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: isUsed ? _used : _wasted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                field,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUsed ? Colors.white : Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: isUsed ? FontWeight.w600 : FontWeight.normal,
                  decoration: isUsed ? null : TextDecoration.lineThrough,
                  decorationColor: Colors.grey.shade700,
                ),
              ),
            ),
          ]),
        );
      }),
    ]);
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
  ]);
}

// ══════════════════════════════════════════════════════════════════════════
// Resto de widgets
// ══════════════════════════════════════════════════════════════════════════

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.5)),
    ),
    child: Text(label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
  );
}

class _Pulse extends StatefulWidget {
  final Color color;
  const _Pulse({required this.color});
  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _a = Tween(begin: 0.3, end: 1.0).animate(_c);
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(width: 16, height: 16,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle)),
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
      child: Row(children: [
        Expanded(child: _TimeChip(
          label: 'REST',
          ms: result.restPokemon.fetchDuration.inMilliseconds,
          color: _restColor,
          isFaster: result.restWasFaster,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(children: [
            Text('⚡', style: TextStyle(fontSize: 20, color: fasterColor)),
            Text('$faster\n${diff}ms antes',
                textAlign: TextAlign.center,
                style: TextStyle(color: fasterColor, fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ]),
        ),
        Expanded(child: _TimeChip(
          label: 'GraphQL',
          ms: result.graphqlPokemon.fetchDuration.inMilliseconds,
          color: _graphqlColor,
          isFaster: !result.restWasFaster,
        )),
      ]),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String label;
  final int ms;
  final Color color;
  final bool isFaster;
  const _TimeChip({required this.label, required this.ms,
    required this.color, required this.isFaster});

  @override
  Widget build(BuildContext context) => Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      if (isFaster) ...[
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
              color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
          child: Text('más rápido', style: TextStyle(color: color, fontSize: 9)),
        ),
      ]
    ]),
    const SizedBox(height: 4),
    Text('${ms}ms', style: const TextStyle(
        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
  ]);
}

class _PokemonHeader extends StatelessWidget {
  final Pokemon pokemon;
  const _PokemonHeader({required this.pokemon});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (pokemon.imageUrl != null)
        Image.network(pokemon.imageUrl!, width: 100, height: 100,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.catching_pokemon, size: 80, color: _accent)),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('#${pokemon.id}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
        Text(
          pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
          style: const TextStyle(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Wrap(spacing: 6, children: pokemon.types.map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _restColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(t, style: const TextStyle(color: _restColor, fontSize: 11)),
        )).toList()),
      ]),
    ],
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(title, style: const TextStyle(
        color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
  );
}

class _StatsComparison extends StatelessWidget {
  final List<PokemonStat> restStats;
  final List<PokemonStat> graphqlStats;
  const _StatsComparison({required this.restStats, required this.graphqlStats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _card, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: restStats.map((stat) {
          final gStat = graphqlStats.firstWhere((s) => s.name == stat.name,
              orElse: () => PokemonStat(name: stat.name, value: 0));
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(stat.name,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(height: 4),
              _StatBar(value: stat.value, max: 255, color: _restColor,
                  label: 'REST ${stat.value}'),
              const SizedBox(height: 3),
              _StatBar(value: gStat.value, max: 255, color: _graphqlColor,
                  label: 'GQL ${gStat.value}'),
            ]),
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
  const _StatBar({required this.value, required this.max,
    required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 60,
        child: Text(label, style: TextStyle(color: color, fontSize: 10))),
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
  ]);
}