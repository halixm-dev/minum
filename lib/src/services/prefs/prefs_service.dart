import 'package:shared_preferences/shared_preferences.dart';
import 'i_prefs_service.dart';

class PrefsService implements IPrefsService {
  late SharedPreferences _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _prefs.getBool(key) ?? defaultValue;
  }

  @override
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    return _prefs.getInt(key) ?? defaultValue;
  }

  @override
  Future<double> getDouble(String key, {double defaultValue = 0.0}) async {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  @override
  Future<String> getString(String key, {String defaultValue = ''}) async {
    return _prefs.getString(key) ?? defaultValue;
  }

  @override
  Future<List<String>> getStringList(String key, {List<String> defaultValue = const []}) async {
    return _prefs.getStringList(key) ?? defaultValue;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
