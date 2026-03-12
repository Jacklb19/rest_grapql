import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pokemon_preview.dart';
import '../providers/home_provider.dart';
import 'pokemon_compare_screen.dart';

const _bg = Color(0xFF0F1117);
const _card = Color(0xFF1C1F2E);
const _accent = Color(0xFFFFD54F);
const _favColor = Color(0xFFFF6B6B);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _scrollCtrl.addListener(() {
      // Scroll infinito: carga más al llegar al 80% de la lista
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent * 0.8) {
        ref.read(homeProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: const Text(
          '🔴 PokéDex',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        actions: [
          // Botón para ir a la pantalla de comparación REST vs GraphQL
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PokemonCompareScreen()),
              ),
              icon: const Icon(Icons.compare_arrows,
                  color: _accent, size: 18),
              label: const Text('REST vs GQL',
                  style: TextStyle(color: _accent, fontSize: 12)),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: _accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: [
            const Tab(text: 'Todos'),
            Tab(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.star, size: 14, color: _favColor),
                const SizedBox(width: 4),
                Text('Favoritos (${favorites.length})'),
              ]),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ── Tab 1: Todos ───────────────────────────────────────────────
          _buildAllTab(homeState),

          // ── Tab 2: Favoritos ──────────────────────────────────────────
          _buildFavoritesTab(homeState.items, favorites),
        ],
      ),
    );
  }

  // ─── Tab Todos ──────────────────────────────────────────────────────────

  Widget _buildAllTab(HomeState state) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: _accent));
    }

    if (state.error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(state.error!,
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(homeProvider.notifier).loadInitial(),
            style: ElevatedButton.styleFrom(backgroundColor: _accent),
            child: const Text('Reintentar',
                style: TextStyle(color: Colors.black)),
          ),
        ]),
      );
    }

    return GridView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: state.items.length + (state.isLoadingMore ? 2 : 0),
      itemBuilder: (_, i) {
        if (i >= state.items.length) {
          return const _SkeletonCard();
        }
        return _PokemonCard(pokemon: state.items[i]);
      },
    );
  }

  // ─── Tab Favoritos ──────────────────────────────────────────────────────

  Widget _buildFavoritesTab(List<PokemonPreview> all, Set<int> favIds) {
    final favs = all.where((p) => favIds.contains(p.id)).toList();

    if (favs.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('⭐', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            'Todavía no tienes favoritos.\nToca ⭐ en cualquier Pokémon.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
          ),
        ]),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: favs.length,
      itemBuilder: (_, i) => _PokemonCard(pokemon: favs[i]),
    );
  }
}

// ── Tarjeta de Pokémon ───────────────────────────────────────────────────

class _PokemonCard extends ConsumerWidget {
  final PokemonPreview pokemon;
  const _PokemonCard({required this.pokemon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesProvider).contains(pokemon.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PokemonCompareScreen(
              initialSearch: pokemon.name),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFav
                ? _favColor.withOpacity(0.5)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Stack(children: [
          // Contenido
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.network(
                    pokemon.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(
                        child: CircularProgressIndicator(
                            color: _accent, strokeWidth: 2)),
                    errorBuilder: (_, __, ___) => const Icon(
                        Icons.catching_pokemon,
                        size: 60,
                        color: Colors.grey),
                  ),
                ),
              ),
              // Nombre e ID
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(children: [
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 11),
                  ),
                  Text(
                    _capitalize(pokemon.name),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
              ),
            ],
          ),

          // Botón favorito
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () =>
                  ref.read(favoritesProvider.notifier).toggle(pokemon.id),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isFav ? Icons.star_rounded : Icons.star_border_rounded,
                  key: ValueKey(isFav),
                  color: isFav ? _favColor : Colors.grey.shade700,
                  size: 22,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Skeleton mientras carga más ──────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 0.7).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_anim.value * 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}