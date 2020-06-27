import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static SessionManager instance;
  static String firstTime = "firstTime";
  static final email = "email";

  static Future<SharedPreferences> preference = SharedPreferences.getInstance();
  SessionManager._();

  static SessionManager getInstance() {
    if(instance == null)
      instance = SessionManager._();

    return instance;
  }

  static void initPrefs() {
    if(preference == null)
      preference = SharedPreferences.getInstance();
  }

  Future<bool> isFirstTime() async {
    final SharedPreferences prefs = await preference;
    return (prefs.getBool(firstTime) ?? true);
  }

  setIsFirstTime(bool val) async {
    final SharedPreferences prefs = await preference;
    prefs.setBool(firstTime, val);
  }

  setEmail(String value) async {
    final SharedPreferences sp = await preference;
    sp.setString(email, value);
  }

  Future<String> getEmail() async {
    final SharedPreferences sp = await preference;
    return (sp.getString(email) ?? null);
  }

  clearEmail() async {
    final pref = await preference;
    return pref.remove(email);
  }
}