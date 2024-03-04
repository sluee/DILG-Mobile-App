import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyOpenedIssuances {
  static const _key = 'openedIssuances';

  static Future<void> addIssuance(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> issuances = prefs.getStringList(_key) ?? [];
    issuances.add(filePath);
    await prefs.setStringList(_key, issuances);
  }

  static Future<void> removeIssuance(String filePath) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> issuances = prefs.getStringList(_key) ?? [];
    issuances.remove(filePath);
    await prefs.setStringList(_key, issuances);
  }

  static Future<List<String>> get issuances async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }
}
