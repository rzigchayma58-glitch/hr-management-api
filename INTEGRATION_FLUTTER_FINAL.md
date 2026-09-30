# 📱 Guide d'Intégration Flutter XCongés ↔ Backend Spring Boot

## 🎯 Vue d'ensemble

**Backend déployé** : API Spring Boot HR Management (`http://localhost:8080`)  
**Frontend** : Application Flutter XCongés (adaptation aux endpoints existants)  
**Approche** : Le frontend Flutter s'adapte aux formats JSON du backend existant  

---

## 🔐 Authentification JWT - Formats Réels

### **POST /api/auth/login** ✅ Endpoint existant

**Request Body (format requis par le backend)** :
```json
{
  "usernameOrEmail": "john.doe@company.com",
  "password": "motdepasse123"
}
```

**Response Success (200) - Format exact du backend** :
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 3600000,
  "user": {
    "id": 1,
    "username": "john.doe",
    "email": "john.doe@company.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "EMPLOYEE"
  }
}
```

**🎨 Modèle Flutter adapté** :
```dart
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

class UserProfile {
  final int id;                    // Long du backend → int Flutter
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: _parseRole(json['role']),
    );
  }

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'EMPLOYEE': return UserRole.employee;
      case 'MANAGER': return UserRole.manager;
      case 'HR': return UserRole.hr;
      case 'ADMIN': return UserRole.admin;
      default: return UserRole.employee;
    }
  }
}

enum UserRole { employee, manager, hr, admin }
```

### **GET /api/auth/me** ✅ Endpoint existant

**Response (200) - Format exact du backend** :
```json
{
  "id": 1,
  "username": "john.doe", 
  "email": "john.doe@company.com",
  "firstName": "John",
  "lastName": "Doe",
  "role": "EMPLOYEE"
}
```

---

## 📝 Gestion des Demandes de Congé - Formats Réels

### **POST /api/leave-requests** ✅ Endpoint existant

**Request Body (format exact requis par le backend)** :
```json
{
  "requesterId": 1,
  "leaveTypeId": 2,
  "startDate": "2024-12-15",
  "endDate": "2024-12-19",
  "reason": "Vacances de fin d'année"
}
```

**🎨 Modèle Flutter pour création** :
```dart
class LeaveRequestCreateDto {
  final int requesterId;
  final int leaveTypeId;
  final String startDate;        // Format: "YYYY-MM-DD"
  final String endDate;          // Format: "YYYY-MM-DD"
  final String? reason;

  LeaveRequestCreateDto({
    required this.requesterId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'requesterId': requesterId,
      'leaveTypeId': leaveTypeId,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
    };
  }
}
```

### **GET /api/leave-requests/requester/{userId}** ✅ Endpoint existant

**Response Success (200) - Format exact du backend** :
```json
[
  {
    "id": 15,
    "requester": {
      "id": 1,
      "firstName": "John",
      "lastName": "Doe", 
      "email": "john.doe@company.com"
    },
    "approver": {
      "id": 5,
      "firstName": "Jane",
      "lastName": "Manager",
      "email": "jane.manager@company.com"
    },
    "leaveType": {
      "id": 2,
      "name": "Congé Annuel"
    },
    "startDate": "2024-12-15",
    "endDate": "2024-12-19",
    "requestedDays": 5.0,
    "reason": "Vacances de fin d'année",
    "status": "PENDING",
    "submittedAt": "2024-12-01T10:30:00",
    "decisionAt": null,
    "decisionComment": null
  }
]
```

**🎨 Modèle Flutter adapté** :
```dart
class LeaveRequestResponse {
  final int id;
  final RequesterInfo requester;
  final ApproverInfo? approver;
  final LeaveTypeInfo leaveType;
  final String startDate;
  final String endDate;
  final double requestedDays;
  final String? reason;
  final LeaveRequestStatus status;
  final DateTime submittedAt;
  final DateTime? decisionAt;
  final String? decisionComment;

  LeaveRequestResponse({
    required this.id,
    required this.requester,
    this.approver,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.requestedDays,
    this.reason,
    required this.status,
    required this.submittedAt,
    this.decisionAt,
    this.decisionComment,
  });

  factory LeaveRequestResponse.fromJson(Map<String, dynamic> json) {
    return LeaveRequestResponse(
      id: json['id'],
      requester: RequesterInfo.fromJson(json['requester']),
      approver: json['approver'] != null ? ApproverInfo.fromJson(json['approver']) : null,
      leaveType: LeaveTypeInfo.fromJson(json['leaveType']),
      startDate: json['startDate'],
      endDate: json['endDate'],
      requestedDays: (json['requestedDays'] as num).toDouble(),
      reason: json['reason'],
      status: _parseStatus(json['status']),
      submittedAt: DateTime.parse(json['submittedAt']),
      decisionAt: json['decisionAt'] != null ? DateTime.parse(json['decisionAt']) : null,
      decisionComment: json['decisionComment'],
    );
  }

  static LeaveRequestStatus _parseStatus(String status) {
    switch (status) {
      case 'PENDING': return LeaveRequestStatus.pending;
      case 'APPROVED': return LeaveRequestStatus.approved;
      case 'REJECTED': return LeaveRequestStatus.rejected;
      case 'CANCELLED': return LeaveRequestStatus.cancelled;
      default: return LeaveRequestStatus.pending;
    }
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

enum LeaveRequestStatus { pending, approved, rejected, cancelled }
```

---

## 💰 Soldes de Congé - Format Réel

### **GET /api/leave-balances/user/{userId}** ✅ Endpoint existant

**Response Success (200) - Format exact du backend** :
```json
[
  {
    "id": 123,
    "user": {
      "id": 1,
      "firstName": "John",
      "lastName": "Doe"
    },
    "leaveType": {
      "id": 2,
      "name": "Congé Annuel"
    },
    "year": 2024,
    "totalDays": 25.0,
    "usedDays": 8.0,
    "remainingDays": 17.0,
    "createdAt": "2024-01-01T00:00:00",
    "updatedAt": "2024-11-15T10:30:00"
  }
]
```

**🎨 Modèle Flutter adapté** :
```dart
class LeaveBalanceResponse {
  final int id;
  final UserBalanceInfo user;
  final LeaveTypeInfo leaveType;
  final int year;
  final double totalDays;
  final double usedDays;
  final double remainingDays;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LeaveBalanceResponse({
    required this.id,
    required this.user,
    required this.leaveType,
    required this.year,
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    required this.createdAt,
    this.updatedAt,
  });

  factory LeaveBalanceResponse.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceResponse(
      id: json['id'],
      user: UserBalanceInfo.fromJson(json['user']),
      leaveType: LeaveTypeInfo.fromJson(json['leaveType']),
      year: json['year'],
      totalDays: (json['totalDays'] as num).toDouble(),
      usedDays: (json['usedDays'] as num).toDouble(),
      remainingDays: (json['remainingDays'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
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
```

---

## 📁 Upload Fichiers - Format Réel

### **POST /api/medical-documents/upload/{leaveRequestId}** ✅ Endpoint existant

**Request Format** :
```http
POST /api/medical-documents/upload/15
Content-Type: multipart/form-data
Authorization: Bearer {token}

Form Data:
- file: [fichier binaire]
```

**🎨 Service Flutter pour upload** :
```dart
class FileUploadService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Future<bool> uploadMedicalDocument(int leaveRequestId, File file) async {
    final token = await AuthService.getStoredToken();
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/medical-documents/upload/$leaveRequestId'),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath('file', file.path),
    );

    final response = await request.send();
    return response.statusCode == 200 || response.statusCode == 201;
  }
}
```

---

## 👥 API Manager - Endpoints Existants

### **GET /api/leave-requests/approver/{managerId}** ✅ Endpoint existant

**Response (200)** : Même format que les demandes utilisateur avec requester différent

### **PATCH /api/leave-requests/{id}/approve** ✅ Endpoint existant

**Request Body** :
```json
{
  "comments": "Approuvé, bon voyage !"
}
```

### **PATCH /api/leave-requests/{id}/reject** ✅ Endpoint existant

**Request Body** :
```json
{
  "comments": "Refusé, période trop chargée",
  "reason": "WORKLOAD_CONFLICT"
}
```

---

## 🔧 Services Flutter Complets

### **Service d'Authentification** :
```dart
class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';  // Android emulator
  
  Future<LoginResponse?> login(String emailOrUsername, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': emailOrUsername,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        await _storeAuthData(loginResponse);
        return loginResponse;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<UserProfile?> getCurrentUser() async {
    final token = await getStoredToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  Future<void> _storeAuthData(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', response.accessToken);
    await prefs.setString('token_type', response.tokenType);
    await prefs.setInt('expires_in', response.expiresIn);
    await prefs.setString('user_data', jsonEncode(response.user.toJson()));
  }

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
```

### **Service de Gestion des Congés** :
```dart
class LeaveService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Future<List<LeaveRequestResponse>> getUserRequests(int userId) async {
    final token = await AuthService.getStoredToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/leave-requests/requester/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LeaveRequestResponse.fromJson(json)).toList();
    }
    throw Exception('Erreur de récupération des demandes');
  }

  Future<bool> createRequest(LeaveRequestCreateDto request) async {
    final token = await AuthService.getStoredToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/leave-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<LeaveBalanceResponse>> getUserBalance(int userId) async {
    final token = await AuthService.getStoredToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/leave-balances/user/$userId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => LeaveBalanceResponse.fromJson(json)).toList();
    }
    return [];
  }
}
```

---

## 🌐 Configuration Réseau

### **URLs par environnement** :
```dart
class ApiConfig {
  static const String devUrlAndroid = 'http://10.0.2.2:8080/api';      // Émulateur Android
  static const String devUrlIOS = 'http://127.0.0.1:8080/api';         // Émulateur iOS  
  static const String prodUrl = 'https://api.xconges.com/api';          // Production
  
  static String get baseUrl {
    if (kDebugMode) {
      return Platform.isAndroid ? devUrlAndroid : devUrlIOS;
    }
    return prodUrl;
  }
}
```

### **Gestion des erreurs globale** :
```dart
class ApiException implements Exception {
  final int statusCode;
  final String message;
  
  ApiException(this.statusCode, this.message);
  
  static ApiException fromResponse(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return ApiException(401, 'Token expiré, reconnexion requise');
      case 403:
        return ApiException(403, 'Accès refusé');
      case 404:
        return ApiException(404, 'Ressource non trouvée');
      case 422:
        return ApiException(422, 'Données invalides');
      default:
        return ApiException(response.statusCode, 'Erreur serveur');
    }
  }
}
```

---

## 📋 Checklist d'Intégration Flutter

### ✅ **Phase 1 - Authentification (Semaine 1)** :
- [ ] Implémenter `AuthService` avec formats backend
- [ ] Adapter modèle `UserProfile` 
- [ ] Stockage sécurisé des tokens
- [ ] Gestion expiration token (1h)
- [ ] Tests login/logout

### ✅ **Phase 2 - Demandes de Congé (Semaine 2)** :
- [ ] Implémenter `LeaveService`
- [ ] Adapter modèles `LeaveRequestResponse` et `LeaveRequestCreateDto`
- [ ] Formulaire de création avec format backend
- [ ] Liste des demandes avec status correct
- [ ] Tests CRUD complets

### ✅ **Phase 3 - Soldes et Fichiers (Semaine 3)** :
- [ ] Affichage soldes avec format `LeaveBalanceResponse`
- [ ] Upload certificats médicaux
- [ ] Gestion erreurs réseau
- [ ] Tests upload fichiers

### ✅ **Phase 4 - Fonctionnalités Manager (Semaine 4)** :
- [ ] Écrans d'approbation/refus
- [ ] Adaptation permissions par rôle
- [ ] Tests workflows complets

---

## 🚀 Points Clés d'Intégration

1. **🔐 Authentification** : Format `LoginResponse` exact avec `accessToken`, `tokenType`, `expiresIn`
2. **📝 Demandes** : Structure `LeaveRequestResponse` avec objets imbriqués `requester`, `approver`, `leaveType`
3. **💰 Soldes** : Array de `LeaveBalanceResponse` avec types de congé séparés
4. **📁 Fichiers** : Upload multipart sur `/medical-documents/upload/{id}`
5. **🌐 Réseau** : Gestion des URLs émulateur vs production

**Cette documentation reflète exactement les formats JSON de votre backend Spring Boot existant. L'application Flutter peut s'intégrer immédiatement avec ces structures de données.**