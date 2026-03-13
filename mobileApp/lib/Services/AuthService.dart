import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Models/UserAccessDetailModel.dart';
import 'ServiceConstant.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  /// LOGIN USER AND STORE USER DATA
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseAPIPath}login_mobile.php'),
        headers: {
          "Content-Type": "application/json", // IMPORTANT
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Debug response
      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("LOGIN RESPONSE BODY: ${response.body}");

      if (response.statusCode != 200) {
        throw Exception('Error! Login failed with status ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 200) {
        throw Exception(data['message'] ?? 'Invalid email or password');
      }

      // Extract user object
      final user = data['user'];

      // Store all user fields in secure storage
      await _storage.write(key: 'auth_token', value: data['token']);
      await _storage.write(key: 'id', value: user['id']?.toString());
      await _storage.write(key: 'name', value: user['name'] ?? '');
      await _storage.write(key: 'mobile', value: user['mobile'] ?? '');
      await _storage.write(key: 'email', value: user['email'] ?? '');
      await _storage.write(key: 'location', value: user['location'] ?? '');
      await _storage.write(key: 'profilePic', value: user['profile_pic'] ?? '');
      await _storage.write(key: 'role', value: user['role'] ?? '');
      await _storage.write(key: 'status', value: user['status'] ?? '');
      await _storage.write(key: 'createdAt', value: user['created_at'] ?? '');
      await _storage.write(key: 'accessLevel', value: user['access_level'] ?? '');
      await _storage.write(key: 'designation', value: user['designation'] ?? '');

      return true;
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      rethrow;
    }
  }

  /// GET STORED TOKEN
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// LOGOUT USER
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// GET USER DETAILS FOR DASHBOARD / DRAWER
  Future<UserAccessDetailModel?> getUserAccessDetails() async {
    final id = await _storage.read(key: 'id');
    if (id == null || id.isEmpty) return null;

    return UserAccessDetailModel(
      id: id,
      name: await _storage.read(key: 'name'),
      mobile: await _storage.read(key: 'mobile'),
      email: await _storage.read(key: 'email'),
      location: await _storage.read(key: 'location'),
      profilePic: await _storage.read(key: 'profilePic'),
      role: await _storage.read(key: 'role'),
      status: await _storage.read(key: 'status'),
      createdAt: await _storage.read(key: 'createdAt'),
      accessLevel: await _storage.read(key: 'accessLevel'),
      designation: await _storage.read(key: 'designation'),
    );
  }
  
  Future<bool> register(
    String fullname,
    String email,
    String mobile,
    String password,
    String location,
  ) async {
  final response = await http.post(
    Uri.parse('${baseAPIPath}register.php'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      'fullname': fullname,
      'email': email,
      'mobile': mobile,
      'password': password,
      'location': location,
    }),
  );

  if (response.statusCode != 200) return false;

  final data = jsonDecode(response.body);
  return data['code'] == 200;
}
}