import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {

  static const String keyGender = "gender";
  static const String keyAge = "age";
  static const String keyName = "name";

  /// SAVE
  static Future<void> saveUser({
    required String name,
    required String gender,
    required int age,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(keyName, name);
    await prefs.setString(keyGender, gender);
    await prefs.setInt(keyAge, age);
  }

  /// GET
  static Future<Map<String, dynamic>> getUser() async {

    final prefs = await SharedPreferences.getInstance();

    return {
      "name": prefs.getString(keyName),
      "gender": prefs.getString(keyGender),
      "age": prefs.getInt(keyAge),
    };
  }

  /// CHECK
  static Future<bool> isUserConfigured() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.containsKey(keyName) &&
        prefs.containsKey(keyGender) &&
        prefs.containsKey(keyAge);
  }

  /// RESET
  static Future<void> clear() async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(keyGender);
    await prefs.remove(keyAge);
  }
}