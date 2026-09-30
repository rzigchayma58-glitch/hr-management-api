// 📱 MODÈLES FLUTTER - COPIER-COLLER DIRECT
// Créer ces fichiers dans votre projet Flutter

// ==============================
// lib/config/api_config.dart
// ==============================
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode;

class ApiConfig {
  // URLs par environnement
  static const String devUrlAndroid = 'http://10.0.2.2:8080/api';
  static const String devUrlIOS = 'http://127.0.0.1:8080/api';
  static const String prodUrl = 'https://api.xconges.com/api';
  
  static String get baseUrl {
    if (kDebugMode) {
      return Platform.isAndroid ? devUrlAndroid : devUrlIOS;
    }
    return prodUrl;
  }
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}

// ==============================
// lib/models/login_response.dart
// ==============================
import 'user_profile.dart';

class LoginResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final UserProfile user;

  LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'],
      tokenType: json['tokenType'],
      expiresIn: json['expiresIn'],
      user: UserProfile.fromJson(json['user']),
    );
  }
}

// ==============================
// lib/models/user_profile.dart
// ==============================
class UserProfile {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? status;
  final bool? enabled;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.status,
    this.enabled,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      status: json['status'],
      enabled: json['enabled'],
    );
  }

  String get fullName => '$firstName $lastName';
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'role': role,
    'status': status,
    'enabled': enabled,
  };
}

// ==============================
// lib/models/leave_request.dart
// ==============================
class LeaveRequest {
  final int? id;
  final RequesterInfo? requester;
  final LeaveTypeInfo leaveType;
  final String startDate;
  final String endDate;
  final double? requestedDays;
  final String? reason;
  final String status;
  final DateTime? submittedAt;
  final String? decisionComment;

  LeaveRequest({
    this.id,
    this.requester,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.requestedDays,
    this.reason,
    required this.status,
    this.submittedAt,
    this.decisionComment,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      requester: json['requester'] != null 
          ? RequesterInfo.fromJson(json['requester']) 
          : null,
      leaveType: LeaveTypeInfo.fromJson(json['leaveType']),
      startDate: json['startDate'],
      endDate: json['endDate'],
      requestedDays: json['requestedDays']?.toDouble(),
      reason: json['reason'],
      status: json['status'],
      submittedAt: json['submittedAt'] != null 
          ? DateTime.parse(json['submittedAt']) 
          : null,
      decisionComment: json['decisionComment'],
    );
  }

  Map<String, dynamic> toCreateJson(int requesterId) => {
    'requesterId': requesterId,
    'leaveTypeId': leaveType.id,
    'startDate': startDate,
    'endDate': endDate,
    'reason': reason,
  };
}

class RequesterInfo {
  final int id;
  final String firstName;
  final String lastName;
  final String email;

  RequesterInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory RequesterInfo.fromJson(Map<String, dynamic> json) {
    return RequesterInfo(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class LeaveTypeInfo {
  final int id;
  final String name;

  LeaveTypeInfo({
    required this.id,
    required this.name,
  });

  factory LeaveTypeInfo.fromJson(Map<String, dynamic> json) {
    return LeaveTypeInfo(
      id: json['id'],
      name: json['name'],
    );
  }
}

// ==============================
// lib/models/leave_balance.dart
// ==============================
class LeaveBalance {
  final int id;
  final UserBalanceInfo user;
  final LeaveTypeInfo leaveType;
  final int year;
  final double totalDays;
  final double usedDays;
  final double remainingDays;

  LeaveBalance({
    required this.id,
    required this.user,
    required this.leaveType,
    required this.year,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    return LeaveBalance(
      id: json['id'],
      user: UserBalanceInfo.fromJson(json['user']),
      leaveType: LeaveTypeInfo.fromJson(json['leaveType']),
      year: json['year'],
      totalDays: (json['totalDays'] as num).toDouble(),
      usedDays: (json['usedDays'] as num).toDouble(),
      remainingDays: (json['remainingDays'] as num).toDouble(),
    );
  }
}

class UserBalanceInfo {
  final int id;
  final String firstName;
  final String lastName;

  UserBalanceInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
  });

  factory UserBalanceInfo.fromJson(Map<String, dynamic> json) {
    return UserBalanceInfo(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
    );
  }
}

// ==============================
// lib/services/auth_service.dart
// ==============================
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/login_response.dart';
import '../models/user_profile.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_data';
  
  Future<LoginResponse?> login(String emailOrUsername, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'usernameOrEmail': emailOrUsername,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);
        await _saveAuthData(loginResponse);
        return loginResponse;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<UserProfile?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/auth/me'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final user = UserProfile.fromJson(jsonDecode(response.body));
        await _saveUser(user);
        return user;
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  Future<void> _saveAuthData(LoginResponse loginResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, loginResponse.accessToken);
    await prefs.setString(_userKey, jsonEncode(loginResponse.user.toJson()));
  }

  Future<void> _saveUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserProfile?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      return UserProfile.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    return await getToken() != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/flutter/test'),
        headers: ApiConfig.headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

// ==============================
// lib/services/leave_service.dart
// ==============================
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/leave_request.dart';
import '../models/leave_balance.dart';
import 'auth_service.dart';

class LeaveService {
  final AuthService _authService = AuthService();

  Future<List<LeaveRequest>> getUserRequests(int userId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Non connecté');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests/requester/$userId'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaveRequest.fromJson(json)).toList();
      }
      throw Exception('Erreur ${response.statusCode}');
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  Future<bool> createRequest(LeaveRequest request, int requesterId) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(request.toCreateJson(requesterId)),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<LeaveBalance>> getUserBalances(int userId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Non connecté');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leave-balances/user/$userId'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaveBalance.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserDashboard() async {
    final token = await _authService.getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/flutter/user/dashboard'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

// ==============================
// lib/screens/login_screen.dart
// ==============================
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result != null) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        _showError('Email ou mot de passe incorrect');
      }
    } catch (e) {
      _showError('Erreur de connexion: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XCongés - Connexion'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work, size: 80, color: Colors.blue),
              SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email ou nom d\'utilisateur',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => 
                    value?.isEmpty == true ? 'Champ requis' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) => 
                    value?.isEmpty == true ? 'Champ requis' : null,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading 
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Se connecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}