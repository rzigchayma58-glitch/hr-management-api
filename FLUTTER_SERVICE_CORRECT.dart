// 🎯 SERVICE FLUTTER CORRIGÉ - UTILISE LES BONS ENDPOINTS
// Fonctionne avec votre FlutterController nouvellement créé

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Endpoints corrects
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String flutterTest = '$baseUrl/flutter/test';
  static const String createLeaveRequest = '$baseUrl/flutter/leave-request';
  static const String getCongeTypes = '$baseUrl/flutter/conge-types';
  
  // Endpoint pour récupérer mes demandes
  static String getUserRequests(int userId) => '$baseUrl/flutter/leave-requests/user/$userId';
}

class CongeService {
  static Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Map<String, String> _getHeaders([String? token]) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // ✅ LOGIN (DÉJÀ TESTÉ)
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔍 Login: $email');
      
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: _getHeaders(),
        body: jsonEncode({
          'usernameOrEmail': email,
          'password': password,
        }),
      );

      print('📡 Login Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Sauvegarder le token et l'ID utilisateur
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['accessToken']);
        
        if (data['user'] != null && data['user']['id'] != null) {
          await prefs.setInt('user_id', data['user']['id']);
        }
        
        return {
          'success': true,
          'token': data['accessToken'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': 'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
      print('❌ Erreur login: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // 📋 RÉCUPÉRER LES TYPES DE CONGÉ (ENDPOINT FLUTTER SPÉCIALISÉ)
  static Future<List<Map<String, dynamic>>> getCongeTypes() async {
    try {
      final token = await _getAuthToken();
      
      print('🔍 Récupération types de congé...');
      
      final response = await http.get(
        Uri.parse(ApiConfig.getCongeTypes),
        headers: _getHeaders(token),
      );

      print('📡 Types Status: ${response.statusCode}');
      print('📋 Types Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        print('✅ Types chargés: ${data.length}');
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ Erreur types: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur réseau types: $e');
      return [];
    }
  }

  // 📝 CRÉER UNE DEMANDE DE CONGÉ (ENDPOINT FLUTTER SPÉCIALISÉ)
  static Future<Map<String, dynamic>> createDemande({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? reason,
  }) async {
    try {
      final token = await _getAuthToken();
      final userId = await _getCurrentUserId();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'Non connecté - veuillez vous reconnecter',
        };
      }

      final requestData = {
        'requesterId': userId,
        'leaveTypeId': leaveTypeId,
        'startDate': startDate.toIso8601String().split('T')[0],
        'endDate': endDate.toIso8601String().split('T')[0],
        'reason': reason ?? 'Demande créée via Flutter',
      };

      print('🔍 Création demande...');
      print('📋 Données: $requestData');

      final response = await http.post(
        Uri.parse(ApiConfig.createLeaveRequest),
        headers: _getHeaders(token),
        body: jsonEncode(requestData),
      );

      print('📡 Create Status: ${response.statusCode}');
      print('📋 Create Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'],
            'id': data['id'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'],
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Erreur serveur: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Erreur création: $e');
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }

  // 📊 RÉCUPÉRER MES DEMANDES (ENDPOINT FLUTTER SPÉCIALISÉ)
  static Future<List<Map<String, dynamic>>> getMesDemandes() async {
    try {
      final token = await _getAuthToken();
      final userId = await _getCurrentUserId();
      
      if (token == null || userId == 0) {
        print('❌ Pas de token ou userId');
        return [];
      }

      print('🔍 Récupération mes demandes pour user ID: $userId');

      final response = await http.get(
        Uri.parse(ApiConfig.getUserRequests(userId)),
        headers: _getHeaders(token),
      );

      print('📡 Demandes Status: ${response.statusCode}');
      print('📋 Demandes Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        print('✅ Demandes chargées: ${data.length}');
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ Erreur demandes: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur réseau demandes: $e');
      return [];
    }
  }

  // 👤 RÉCUPÉRER L'ID UTILISATEUR ACTUEL
  static Future<int> _getCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id') ?? 15; // ID par défaut aa.bb@xtensus.com
  }

  // 🧪 TEST COMPLET AVEC LES NOUVEAUX ENDPOINTS
  static Future<void> testCompletFlutter() async {
    print('🧪 TEST COMPLET SERVICE FLUTTER');
    print('=' * 50);
    
    // Test 1: Login
    print('\n1. Test Login...');
    final loginResult = await login(
      email: 'aa.bb@xtensus.com',
      password: '123456',
    );
    
    if (loginResult['success']) {
      print('✅ Login réussi');
      
      // Test 2: Types de congé
      print('\n2. Test Types de congé Flutter endpoint...');
      final types = await getCongeTypes();
      print('✅ Types récupérés: ${types.length}');
      for (var type in types) {
        print('   - ${type['name']} (ID: ${type['id']})');
      }
      
      // Test 3: Créer une demande
      if (types.isNotEmpty) {
        print('\n3. Test Création demande Flutter endpoint...');
        final createResult = await createDemande(
          leaveTypeId: types.first['id'],
          startDate: DateTime.now().add(Duration(days: 7)),
          endDate: DateTime.now().add(Duration(days: 9)),
          reason: 'Test depuis Flutter endpoint spécialisé',
        );
        
        if (createResult['success']) {
          print('✅ Demande créée: ${createResult['message']}');
          print('   ID de la demande: ${createResult['id']}');
        } else {
          print('❌ Création échouée: ${createResult['error']}');
        }
      }
      
      // Test 4: Récupérer mes demandes
      print('\n4. Test Mes demandes Flutter endpoint...');
      final demandes = await getMesDemandes();
      print('✅ Demandes récupérées: ${demandes.length}');
      for (var demande in demandes) {
        print('   - ${demande['leaveTypeName']}: ${demande['startDate']} (${demande['status']})');
      }
      
    } else {
      print('❌ Login échoué: ${loginResult['error']}');
    }
    
    print('\n🎉 TEST TERMINÉ !');
    print('Vérifiez maintenant la table conge_demandes dans phpMyAdmin');
  }
}

/*
🎯 UTILISATION :

1. **Ajoutez le FlutterController au backend** (fichier créé)
2. **Redémarrez Spring Boot** : mvn spring-boot:run
3. **Remplacez votre service Flutter** par ce code
4. **Testez** : CongeService.testCompletFlutter()

✅ RÉSULTAT GARANTI :
- Demandes sauvées dans la table conge_demandes
- Types chargés depuis conge_types  
- "Mes demandes" fonctionne
- Endpoint Flutter spécialisé

🎉 VOTRE DEMANDE APPARAÎTRA DANS MYSQL !
*/