import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/pokemon_compare_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PokemonApp(),
    ),
  );
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'REST vs GraphQL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD54F),
          surface: Color(0xFF1C1F2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        useMaterial3: true,
      ),
      home: const PokemonCompareScreen(),
    );
  }
}