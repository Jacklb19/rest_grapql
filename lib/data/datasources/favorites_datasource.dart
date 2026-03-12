import 'package:shared_preferences/shared_preferences.dart';

class FavoritesDatasource {
  static const _key = 'favorite_ids';

  Future<List<int>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map(int.parse).toList();
  }

  Future<void> add(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    if (!current.contains('$id')) {
      current.add('$id');
      await prefs.setStringList(_key, current);
    }
  }

  Future<void> remove(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    current.remove('$id');
    await prefs.setStringList(_key, current);
  }

  Future<bool> contains(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];
    return current.contains('$id');
  }
}