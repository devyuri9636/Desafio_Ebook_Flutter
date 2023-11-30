import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const _key = 'favorite_books';

  Future<void> saveFavorites(List<String> favoriteBooks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, favoriteBooks);
  }

  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}