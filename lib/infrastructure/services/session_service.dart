import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setToken(String token) async {
    await _prefs?.setString('token', token);
  }

  String getToken() {
    return _prefs?.getString('token') ?? '';
  }

  Future<void> setUserId(int id) async {
    await _prefs?.setInt('userId', id);
  }

  int getUserId() {
    return _prefs?.getInt('userId') ?? -1;
  }

  Future<void> setRole(String role) async {
    await _prefs?.setString('role', role);
  }

  String getRole() {
    return _prefs?.getString('role') ?? '';
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
