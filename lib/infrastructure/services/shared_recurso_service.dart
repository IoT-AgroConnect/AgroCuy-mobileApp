import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrocuy/features/resources/data/models/recurso.dart';

class SharedRecursoService {
  static const _key = 'recursos';

  Future<void> saveRecursos(List<Recurso> recursos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = recursos.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_key, jsonList);
  }

  Future<List<Recurso>> loadRecursos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key);
    if (jsonList == null) return [];
    return jsonList.map((j) => Recurso.fromJson(jsonDecode(j))).toList();
  }

  Future<void> clearRecursos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
