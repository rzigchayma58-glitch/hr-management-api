// 🔍 TEST SIMPLE SUR LOCALHOST - Backend Spring Boot
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  print('🔍 TEST LOCALHOST BACKEND');
  print('=' * 40);
  
  // Test sur localhost
  const localhostUrl = 'http://localhost:3000/api';
  print('\n📡 Test connexion localhost:3000...');
  
  try {
    final testResponse = await http.get(
      Uri.parse('http://localhost:3000/api/flutter/test')
    ).timeout(Duration(seconds: 5));
    
    if (testResponse.statusCode == 200) {
      print('✅ Backend accessible sur localhost !');
      print('   Réponse: ${testResponse.body}');
      
      // Test authentification
      await testAuth(localhostUrl);
    } else {
      print('❌ Backend localhost - Status: ${testResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Backend localhost inaccessible: $e');
    print('\n💡 Solutions:');
    print('   1. Vérifiez que Spring Boot est démarré');
    print('   2. Regardez les logs: "Started Application on port 3000"');  
    print('   3. Testez dans le navigateur: http://localhost:3000/api/flutter/test');
  }
}

Future<void> testAuth(String baseUrl) async {
  print('\n🔐 Test authentification...');
  try {
    final authResponse = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': 'admin@test.com',
        'password': 'password123'
      }),
    );
    
    print('   Status: ${authResponse.statusCode}');
    if (authResponse.statusCode == 200) {
      final data = jsonDecode(authResponse.body);
      print('✅ Authentification OK !');
      print('   Token reçu de longueur: ${data['accessToken'].length}');
      
      // Test création demande
      await testCreateLeave(baseUrl, data['accessToken'], 8); // ID admin = 8
    } else {
      print('❌ Erreur auth: ${authResponse.body}');
    }
  } catch (e) {
    print('❌ Erreur auth: $e');
  }
}

Future<void> testCreateLeave(String baseUrl, String token, int userId) async {
  print('\n🚀 Test création demande congé...');
  
  // D'abord récupérer les types disponibles
  try {
    final typesResponse = await http.get(
      Uri.parse('$baseUrl/conge-types'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (typesResponse.statusCode == 200) {
      final types = jsonDecode(typesResponse.body);
      print('✅ Types de congé trouvés: ${types.length}');
      for (var type in types) {
        print('   - ID: ${type['id']}, Nom: ${type['name']}');
      }
      
      // Essayer de créer une demande avec le premier type
      if (types.isNotEmpty) {
        await attemptCreateRequest(baseUrl, token, userId, types[0]['id']);
      }
    } else {
      print('❌ Types de congé non trouvés: ${typesResponse.body}');
    }
  } catch (e) {
    print('❌ Erreur types: $e');
  }
}

Future<void> attemptCreateRequest(String baseUrl, String token, int userId, int leaveTypeId) async {
  print('\n📝 Tentative création avec leaveTypeId: $leaveTypeId...');
  
  try {
    final tomorrow = DateTime.now().add(Duration(days: 7));
    final dayAfter = tomorrow.add(Duration(days: 1));
    
    final requestData = {
      'requesterId': userId,
      'leaveTypeId': leaveTypeId,
      'startDate': formatDate(tomorrow),
      'endDate': formatDate(dayAfter),
      'reason': 'Test création depuis Flutter - ${DateTime.now()}',
    };
    
    print('   Données: $requestData');
    
    final response = await http.post(
      Uri.parse('$baseUrl/leave-requests'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestData),
    );
    
    print('   Status: ${response.statusCode}');
    print('   Réponse: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('🎉 SUCCÈS ! Demande créée !');
      
      // Vérifier en BD
      final checkResponse = await http.get(
        Uri.parse('$baseUrl/leave-requests/requester/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (checkResponse.statusCode == 200) {
        final requests = jsonDecode(checkResponse.body);
        print('✅ Demandes en BD: ${requests.length}');
        if (requests.isNotEmpty) {
          print('🎉 MYSQL FONCTIONNE ! La demande est sauvée !');
          for (var req in requests) {
            print('   📄 ID: ${req['id']}, Status: ${req['status']}');
          }
        }
      }
    } else {
      print('❌ Échec création: ${response.body}');
    }
  } catch (e) {
    print('❌ Erreur création: $e');
  }
}

String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}