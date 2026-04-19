import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUid = 'uid';
  static const String _keyPhone = 'phone';
  static const String _keyName = 'display_name';
  static const String _keyLoggedIn = 'is_logged_in';

  static SessionManager? _instance;
  static SessionManager get instance => _instance ??= SessionManager._();
  SessionManager._();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveSession({
    required String uid,
    required String phone,
    required String name,
  }) async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.setString(_keyUid, uid);
    await _prefs.setString(_keyPhone, phone);
    await _prefs.setString(_keyName, name);
    await _prefs.setBool(_keyLoggedIn, true);
  }

  Future<String> getUid() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(_keyUid) ?? '';
  }

  Future<String> getPhone() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(_keyPhone) ?? '';
  }

  Future<String> getName() async {
    _prefs = await SharedPreferences.getInstance();
    return _prefs.getString(_keyName) ?? '';
  }

  Future<void> clear() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.clear();
  }
}
