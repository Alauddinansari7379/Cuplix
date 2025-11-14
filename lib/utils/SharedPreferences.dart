import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserData {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _keyToken = 'user_token';
  static const String _keyName = 'user_name';
  static const String _keyEmail = 'user_email';
  static const String _keyNumber = 'user_number';

  /// Save user data securely
  static Future<void> saveUserData({
    required String token,
    required String name,
    required String email,
    required String number,
  }) async {
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyName, value: name);
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyNumber, value: number);
  }

  /// Get all user data as a map
  static Future<Map<String, String?>> getUserData() async {
    final token = await _storage.read(key: _keyToken);
    final name = await _storage.read(key: _keyName);
    final email = await _storage.read(key: _keyEmail);
    final number = await _storage.read(key: _keyNumber);

    return {
      'token': token,
      'name': name,
      'email': email,
      'number': number,
    };
  }

  /// Individual getters
  static Future<String?> getToken() async =>
      await _storage.read(key: _keyToken);

  static Future<String?> getName() async =>
      await _storage.read(key: _keyName);

  static Future<String?> getEmail() async =>
      await _storage.read(key: _keyEmail);

  static Future<String?> getNumber() async =>
      await _storage.read(key: _keyNumber);

  /// Clear all stored data (use on logout)
  static Future<void> clearUserData() async {
    await _storage.deleteAll();
  }
}
