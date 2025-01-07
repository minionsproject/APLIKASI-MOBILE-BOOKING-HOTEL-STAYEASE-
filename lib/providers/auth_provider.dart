import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stay_ease/helpers/mongodb_helper.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _userId;
  String? _username;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get userId => _userId;
  String? get username => _username;
  String? get email => _email;

  Future<void> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email dan password harus diisi');
      }

      final mongoHelper = MongoDBHelper();
      final user = await mongoHelper.authenticateUser(email, password);

      _isAuthenticated = true;
      _token = user.id;
      _userId = user.id;
      _username = user.username;
      _email = user.email;

      await _saveToPrefs();
      notifyListeners();
    } catch (error) {
      await _resetState();
      notifyListeners();
      throw Exception(error.toString());
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        throw Exception('Semua field harus diisi');
      }

      final mongoHelper = MongoDBHelper();
      final user = await mongoHelper.registerUser(email, password, username);

      _isAuthenticated = true;
      _token = user.id;
      _userId = user.id;
      _username = user.username;
      _email = user.email;

      await _saveToPrefs();
      notifyListeners();
    } catch (error) {
      await _resetState();
      notifyListeners();
      throw Exception(error.toString());
    }
  }

  Future<void> logout() async {
    await _resetState();
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;

    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _username = prefs.getString('username');
    _email = prefs.getString('email');
    _isAuthenticated = true;

    notifyListeners();
    return true;
  }

  Future<void> _resetState() async {
    _isAuthenticated = false;
    _token = null;
    _userId = null;
    _username = null;
    _email = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', _token!);
    await prefs.setString('userId', _userId!);
    await prefs.setString('username', _username!);
    await prefs.setString('email', _email!);
  }
}
