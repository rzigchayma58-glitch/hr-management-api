import 'dart:convert';
import 'dart:io';

// 🧪 TEST COMPLET CRÉATION DE DEMANDE DE CONGÉ
// Vérifie l'intégration Flutter → Backend → MySQL

void main() async {
  print('🧪 TEST COMPLET - CRÉATION DEMANDE DE CONGÉ');
  print('=====================================\n');
  
  final client = HttpClient();
  
  try {
    // 📡 1. Test de connectivité backend
    print('1️⃣ Test connectivité backend...');
    final testRequest = await client.getUrl(Uri.parse('http://10.148.173.19:3000/api/flutter/test'));
    final testResponse = await testRequest.close();
    
    if (testResponse.statusCode == 200) {
      final testBody = await testResponse.transform(utf8.decoder).join();
      print('✅ Backend connecté - Status: ${testResponse.statusCode}');
      print('   Response: $testBody\n');
    } else {
      print('❌ Backend non accessible - Status: ${testResponse.statusCode}\n');
      return;
    }
    
    // 🔐 2. Authentification (login avec un utilisateur test)
    print('2️⃣ Test d\'authentification...');
    final loginRequest = await client.postUrl(Uri.parse('http://10.148.173.19:3000/api/auth/login'));
    loginRequest.headers.set('Content-Type', 'application/json');
    
    final loginData = {
      'usernameOrEmail': 'admin@test.com',
      'password': 'password123'
    };
    
    loginRequest.write(json.encode(loginData));
    final loginResponse = await loginRequest.close();
    final loginBody = await loginResponse.transform(utf8.decoder).join();
    
    if (loginResponse.statusCode != 200) {
      print('❌ Échec authentification - Status: ${loginResponse.statusCode}');
      print('   Response: $loginBody\n');
      return;
    }
    
    final loginResult = json.decode(loginBody);
    final token = loginResult['token'];
    final userId = loginResult['user']['id'];
    
    print('✅ Authentification réussie');
    print('   User ID: $userId');
    print('   Token: ${token.substring(0, 20)}...\n');
    
    // 📋 3. Récupération des types de congé
    print('3️⃣ Test récupération types de congé...');
    final typesRequest = await client.getUrl(Uri.parse('http://10.148.173.19:3000/api/conge-types'));
    typesRequest.headers.set('Authorization', 'Bearer $token');
    final typesResponse = await typesRequest.close();
    final typesBody = await typesResponse.transform(utf8.decoder).join();
    
    if (typesResponse.statusCode != 200) {
      print('❌ Échec récupération types - Status: ${typesResponse.statusCode}');
      print('   Response: $typesBody\n');
      return;
    }
    
    final types = json.decode(typesBody) as List;
    print('✅ Types de congé récupérés: ${types.length} types');
    for (var type in types) {
      print('   - ID: ${type['id']}, Nom: ${type['name']}');
    }
    print('');
    
    // 🆕 4. Création de demande de congé
    print('4️⃣ Test création de demande de congé...');
    final createRequest = await client.postUrl(Uri.parse('http://10.148.173.19:3000/api/leave-requests'));
    createRequest.headers.set('Content-Type', 'application/json');
    createRequest.headers.set('Authorization', 'Bearer $token');
    
    // Calculer des dates futures
    final now = DateTime.now();
    final startDate = now.add(Duration(days: 7));
    final endDate = startDate.add(Duration(days: 2));
    
    final demandData = {
      'leaveTypeId': types.first['id'], // Premier type disponible
      'startDate': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'endDate': '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
      'reason': 'Test création demande depuis Flutter - ${DateTime.now()}',
      'workingDays': 3
    };
    
    print('   Données envoyées: $demandData');
    
    createRequest.write(json.encode(demandData));
    final createResponse = await createRequest.close();
    final createBody = await createResponse.transform(utf8.decoder).join();
    
    print('   Status: ${createResponse.statusCode}');
    print('   Response: $createBody');
    
    if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
      final demandResult = json.decode(createBody);
      print('\n🎉 ✅ DEMANDE CRÉÉE AVEC SUCCÈS !');
      print('   ID: ${demandResult['id']}');
      print('   Status: ${demandResult['status']}');
      print('   Dates: ${demandResult['startDate']} → ${demandResult['endDate']}');
      print('   Type: ${demandResult['leaveType']['name']}');
    } else {
      print('\n❌ ÉCHEC CRÉATION DEMANDE');
      print('   Erreur: $createBody');
    }
    
    // 📊 5. Vérification des soldes (si disponible)
    print('\n5️⃣ Test soldes utilisateur...');
    final balancesRequest = await client.getUrl(Uri.parse('http://10.148.173.19:3000/api/leave-balances/user/$userId'));
    balancesRequest.headers.set('Authorization', 'Bearer $token');
    final balancesResponse = await balancesRequest.close();
    
    if (balancesResponse.statusCode == 200) {
      final balancesBody = await balancesResponse.transform(utf8.decoder).join();
      final balances = json.decode(balancesBody) as List;
      print('✅ Soldes récupérés: ${balances.length} types');
      for (var balance in balances) {
        print('   - ${balance['leaveType']['name']}: ${balance['remainingDays']}/${balance['totalDays']} jours');
      }
    } else {
      print('⚠️ Soldes non disponibles (endpoint peut ne pas exister)');
    }
    
  } catch (e) {
    print('❌ ERREUR LORS DU TEST: $e');
  } finally {
    client.close();
  }
  
  print('\n🏁 TEST TERMINÉ');
  print('=====================================');
  print('Si la demande a été créée avec succès, vérifiez dans MySQL:');
  print('   SELECT * FROM conge_demandes ORDER BY submittedAt DESC;');
}