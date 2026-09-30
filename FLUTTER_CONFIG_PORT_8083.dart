// 🚀 CONFIGURATION FLUTTER URGENTE - PORT 8083
// Copier ce code dans votre projet Flutter IMMÉDIATEMENT

// lib/config/api_config.dart
class ApiConfig {
  // ⚠️ URGENT: Backend maintenant sur port 8083
  static const String baseUrl = 'http://10.0.2.2:8083/api';  // Android emulator
  // static const String baseUrl = 'http://127.0.0.1:8083/api';  // iOS
  // static const String baseUrl = 'http://localhost:8083/api';  // PC Windows
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}

// TEST RAPIDE - Coller dans votre widget de test
Future<void> testNewBackend() async {
  try {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8083/api/flutter/test')
    );
    print('✅ Backend 8083: ${response.statusCode}');
  } catch (e) {
    print('❌ Erreur: $e');
  }
}

// LOGIN TEST
Future<void> testLogin() async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8083/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': 'admin@test.com',
        'password': 'password123'
      })
    );
    print('✅ Login 8083: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Token: ${data['accessToken'].substring(0, 20)}...');
    }
  } catch (e) {
    print('❌ Login error: $e');
  }
}