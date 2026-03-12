import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: PokeDexApp()));
}

class PokeDexApp extends StatelessWidget {
  const PokeDexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokéDex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD54F),
          surface: Color(0xFF1C1F2E),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}