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
    print('DEBUG SessionService: Setting token, length: ${token.length}');
    print('DEBUG SessionService: Token preview: ${token.substring(0, 20)}...');
    await _prefs?.setString('token', token);
    print('DEBUG SessionService: Token saved');
  }

  String getToken() {
    final token = _prefs?.getString('token') ?? '';
    print('DEBUG SessionService: Getting token, length: ${token.length}');
    if (token.isNotEmpty) {
      print(
          'DEBUG SessionService: Token preview: ${token.substring(0, 20)}...');
    } else {
      print('DEBUG SessionService: No token found');
    }
    return token;
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

  Future<void> setBreederId(int breederId) async {
    print('DEBUG SessionService: Setting breederId: $breederId');
    await _prefs?.setInt('breederId', breederId);
  }

  int getBreederId() {
    final breederId = _prefs?.getInt('breederId') ?? 0;
    print('DEBUG SessionService: Getting breederId: $breederId');
    return breederId;
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}
