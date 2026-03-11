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
    final response = await http.post(
      Uri.parse('${baseAPIPath}login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    debugPrint("LOGIN RESPONSE BODY: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Error! Login failed');
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
    await _storage.write(key: 'name', value: user['fullname']);
    await _storage.write(key: 'mobile', value: user['mobile']);
    await _storage.write(key: 'email', value: user['email']);
    await _storage.write(key: 'location', value: user['location']);
    await _storage.write(key: 'profilePic', value: user['profile_pic']);
    await _storage.write(key: 'role', value: user['role']);
    await _storage.write(key: 'status', value: user['status']);
    await _storage.write(key: 'createdAt', value: user['created_at']);
    await _storage.write(key: 'accessLevel', value: user['access_level']);
    await _storage.write(key: 'designation', value: user['designation']);

    return true;
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
    final name = await _storage.read(key: 'name');
    final mobile = await _storage.read(key: 'mobile');
    final email = await _storage.read(key: 'email');
    final location = await _storage.read(key: 'location');
    final profilePic = await _storage.read(key: 'profilePic');
    final role = await _storage.read(key: 'role');
    final status = await _storage.read(key: 'status');
    final createdAt = await _storage.read(key: 'createdAt');
    final accessLevel = await _storage.read(key: 'accessLevel');
    final designation = await _storage.read(key: 'designation');

    // Debug stored values
    debugPrint("""
    USER STORAGE DEBUG
    id: $id
    name: $name
    mobile: $mobile
    email: $email
    location: $location
    profilePic: $profilePic
    role: $role
    status: $status
    createdAt: $createdAt
    accessLevel: $accessLevel
    designation: $designation
    """);

    if (id == null || id.isEmpty) return null;

    return UserAccessDetailModel(
      id: id,
      name: name,
      mobile: mobile,
      email: email,
      location: location,
      profilePic: profilePic,
      role: role,
      status: status,
      createdAt: createdAt,
      accessLevel: accessLevel,
      designation: designation,
    );
  }
}