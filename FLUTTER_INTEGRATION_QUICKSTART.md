# 🚀 Flutter Integration - QUICKSTART

## ✅ Backend Ready - Changements effectués

### 1. **CORS Configuration étendue** ✅
- Ajout support émulateurs Android/iOS
- URLs autorisées: `http://10.0.2.2:8080`, `http://127.0.0.1:*`, `http://localhost:*`

### 2. **AuthenticatedUserResponse étendu** ✅
- Ajout champs `status`, `enabled`
- Ajout objets `department`, `position`, `manager`
- Compatible format Flutter

### 3. **Controller de test Flutter** ✅
- Endpoint: `GET /api/flutter/test` (test connexion)
- Endpoint: `GET /api/flutter/user/dashboard` (dashboard complet)
- Endpoint: `GET /api/flutter/user/{userId}/summary` (résumé utilisateur)

---

## 📱 Code Flutter - Intégration Immédiate

### **1. Configuration API**
```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8080/api';  // Android
  // static const String baseUrl = 'http://127.0.0.1:8080/api';  // iOS
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
```

### **2. Service d'Authentification**
```dart
// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/login_response.dart';
import '../models/user_profile.dart';

class AuthService {
  static const String _tokenKey = 'access_token';
  
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
        await _saveToken(loginResponse.accessToken);
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
        return UserProfile.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    return await getToken() != null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Test connexion backend
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/flutter/test'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
```

### **3. Modèles Dart**
```dart
// lib/models/login_response.dart
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

// lib/models/user_profile.dart
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
}

// lib/models/leave_request.dart
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
```

### **4. Service des Congés**
```dart
// lib/services/leave_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/leave_request.dart';
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

  Future<bool> createRequest({
    required int requesterId,
    required int leaveTypeId,
    required String startDate,
    required String endDate,
    String? reason,
  }) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/leave-requests'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({
          'requesterId': requesterId,
          'leaveTypeId': leaveTypeId,
          'startDate': startDate,
          'endDate': endDate,
          'reason': reason,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // Dashboard rapide pour Flutter
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
```

### **5. Screen de Test Simple**
```dart
// lib/screens/test_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/leave_service.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final AuthService _authService = AuthService();
  final LeaveService _leaveService = LeaveService();
  
  String _status = 'Initialisation...';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testBackendConnection();
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Test de connexion backend...';
    });

    try {
      final connected = await _authService.testConnection();
      setState(() {
        _status = connected 
            ? '✅ Backend connecté!' 
            : '❌ Backend non accessible';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _status = 'Test login...';
    });

    try {
      final result = await _authService.login('admin@example.com', 'admin123');
      setState(() {
        _status = result != null 
            ? '✅ Login réussi: ${result.user.fullName}' 
            : '❌ Login échoué';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Erreur login: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('XCongés - Test Backend'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      _status.contains('✅') ? Icons.check_circle : Icons.error,
                      color: _status.contains('✅') ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _status,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (_isLoading) ...[
                      SizedBox(height: 16),
                      CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _testBackendConnection,
              child: Text('Test Connexion Backend'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testLogin,
              child: Text('Test Login'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🚀 **ÉTAPES FINALES**

### **1. Démarrer le Backend (2 minutes)**
```bash
cd c:\Users\msi\backend_leaveapp\hr-management-api
.\mvnw.cmd spring-boot:run
```

### **2. Tester avec Postman (1 minute)**
- Importer: `XConges_API_Tests.postman_collection.json`
- Exécuter: Collection "🔐 Authentification" 
- Vérifier: Login retourne `accessToken`

### **3. Intégrer dans Flutter (5 minutes)**
- Copier les fichiers Dart ci-dessus
- Ajouter dépendances: `http: ^1.1.0`, `shared_preferences: ^2.2.2`
- Lancer `TestScreen` pour vérifier

### **4. URLs de Test Rapide**
- **Backend**: http://localhost:8080/api/flutter/test
- **Login**: POST http://localhost:8080/api/auth/login
- **Dashboard**: GET http://localhost:8080/api/flutter/user/dashboard

**🎯 RÉSULTAT: App Flutter fonctionnelle avec votre backend en 10 minutes max !**