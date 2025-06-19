import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/expenses/data/models/gasto.dart';

class SharedGastoService {
  final String key = "gastos";

  Future<List<Gasto>> getGastos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString);
    return decoded.map((e) => Gasto.fromJson(e)).toList();
  }

  Future<void> saveGastos(List<Gasto> gastos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(gastos.map((g) => g.toJson()).toList());
    await prefs.setString(key, jsonString);
  }
}
