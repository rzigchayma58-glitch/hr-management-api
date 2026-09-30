// 🔍 FLUTTER DEBUG - VOIR CE QUI SE PASSE EXACTEMENT
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DebugService {
  static const String baseUrl = 'http://10.148.173.19:3000/api';
  
  // 🔍 DEBUG COMPLET
  static Future<void> debugComplet() async {
    print('🔍 =================================');
    print('🔍 DEBUG DEMANDES DE CONGÉ COMPLET');
    print('🔍 =================================');
    
    // 1. Vérifier le token
    final token = await _getAuthToken();
    final userId = await _getEmployeeId();
    
    print('🔍 Token: ${token?.substring(0, 50) ?? 'NULL'}...');
    print('🔍 User ID local: $userId');
    
    // 2. Test login pour récupérer les vraies infos
    await _testLogin();
    
    // 3. Test historique
    await _testHistorique();
    
    // 4. Test création demande
    await _testCreerDemande();
    
    // 5. Test re-lecture historique
    await _testHistoriqueApres();
    
    print('🔍 =================================');
    print('🔍 DEBUG TERMINÉ');
    print('🔍 =================================');
  }
  
  static Future<void> _testLogin() async {
    print('\n🔍 --- TEST LOGIN ---');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': 'aa.bb@xtensus.com',
          'password': '123456',
        }),
      );
      
      print('🔍 Login Status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🔍 User ID du serveur: ${data['user']['id']}');
        print('🔍 User Email: ${data['user']['email']}');
        print('🔍 User Role: ${data['user']['role']}');
        
        // Sauver les bonnes infos
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['accessToken']);
        await prefs.setInt('employee_id', data['user']['id']);
      } else {
        print('❌ Login failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Login error: $e');
    }
  }
  
  static Future<void> _testHistorique() async {
    print('\n🔍 --- TEST HISTORIQUE ---');
    
    final token = await _getAuthToken();
    final userId = await _getEmployeeId();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/leave-requests/requester/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('🔍 Historique Status: ${response.statusCode}');
      print('🔍 Historique URL: $baseUrl/leave-requests/requester/$userId');
      print('🔍 Historique Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('🔍 Nombre de demandes trouvées: ${data.length}');
        
        for (int i = 0; i < data.length && i < 3; i++) {
          final demande = data[i];
          print('🔍 Demande $i: ID=${demande['id']}, Type=${demande['leaveTypeId']}, Status=${demande['status']}');
        }
      }
    } catch (e) {
      print('❌ Historique error: $e');
    }
  }
  
  static Future<void> _testCreerDemande() async {
    print('\n🔍 --- TEST CRÉER DEMANDE ---');
    
    final token = await _getAuthToken();
    final userId = await _getEmployeeId();
    
    final demande = {
      'requesterId': userId,
      'leaveTypeId': 1, // Congé annuel
      'startDate': DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0],
      'endDate': DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0],
      'requestedDays': 1.0,
      'reason': 'Test DEBUG Flutter - ${DateTime.now()}',
    };
    
    print('🔍 Demande à créer: $demande');
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/leave-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(demande),
      );
      
      print('🔍 Création Status: ${response.statusCode}');
      print('🔍 Création Response: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Demande créée ! ID: ${data['id']}');
      }
    } catch (e) {
      print('❌ Création error: $e');
    }
  }
  
  static Future<void> _testHistoriqueApres() async {
    print('\n🔍 --- TEST HISTORIQUE APRÈS CRÉATION ---');
    
    // Attendre 2 secondes
    await Future.delayed(Duration(seconds: 2));
    
    await _testHistorique();
  }
  
  // Utilitaires
  static Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<int> _getEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('employee_id') ?? 15;
  }
}

// 🔍 WIDGET DEBUG SIMPLE
class DebugScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔍 Debug Demandes'),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                '🔍 DEBUG MODE\n\nCe test va vérifier :\n• Login\n• Récupération historique\n• Création demande\n• Re-vérification\n\nVoir la console pour les détails !',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                print('🔍 DÉBUT DU DEBUG...');
                await DebugService.debugComplet();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Debug terminé ! Vérifiez la console'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('🔍 LANCER DEBUG COMPLET'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await DebugService._testLogin();
                await DebugService._testHistorique();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Test rapide terminé ! Vérifiez la console'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              child: Text('🔍 TEST RAPIDE HISTORIQUE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
🔍 UTILISATION :

1. Ajoutez DebugScreen() à votre navigation Flutter
2. Lancez le debug complet
3. Regardez la console de votre IDE Flutter
4. Vous verrez EXACTEMENT ce qui se passe :
   - L'ID utilisateur réel
   - Les demandes trouvées (ou pas)
   - Les erreurs éventuelles
   
🎯 RÉSULTAT ATTENDU :
- User ID : 15
- Historique : [] (vide) ou [demandes...]
- Après création : nouvelle demande visible

Cela va nous dire EXACTEMENT pourquoi vous ne voyez pas vos demandes !
*/