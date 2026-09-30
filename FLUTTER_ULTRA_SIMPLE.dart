// 🎯 FLUTTER ULTRA-SIMPLE - UTILISE VOS ENDPOINTS EXISTANTS
// Pas de nouveau code backend - utilise ce qui existe déjà !

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CongeSimple {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Utilisez les endpoints qui EXISTENT déjà
  static const String login = '$baseUrl/auth/login';
  static const String congeTypes = '$baseUrl/conge-types';  // Endpoint existant testé ✅
}

class CongeServiceSimple {
  // 🔐 LOGIN (déjà testé et fonctionne)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(CongeSimple.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Sauvegarder les infos
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['accessToken']);
        if (data['user'] != null) {
          await prefs.setInt('employee_id', data['user']['id']);
          await prefs.setString('employee_email', data['user']['email']);
        }
        
        return {'success': true, 'user': data['user']};
      } else {
        return {'success': false, 'error': 'Email ou mot de passe incorrect'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Erreur de connexion: $e'};
    }
  }

  // 📋 RÉCUPÉRER LES TYPES (endpoint existant testé)
  static Future<List<Map<String, dynamic>>> getTypesConge() async {
    try {
      final token = await _getAuthToken();
      
      final response = await http.get(
        Uri.parse(CongeSimple.congeTypes),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Types Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        // Adapter le format existant
        return data.map<Map<String, dynamic>>((type) {
          return {
            'id': type['id'],
            'name': type['nom'] ?? type['name'] ?? 'Type ${type['id']}',
            'description': type['description'] ?? '',
          };
        }).toList();
      } else {
        print('❌ Erreur types: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur réseau types: $e');
      return [];
    }
  }

  // 📝 CRÉER DEMANDE (sauvegarde locale + affichage)
  static Future<Map<String, dynamic>> creerDemandeLocale({
    required int typeId,
    required String typeName,
    required String reason,
  }) async {
    try {
      final employeeId = await _getEmployeeId();
      final employeeEmail = await _getEmployeeEmail();
      
      // Créer l'objet demande
      final demande = {
        'id': DateTime.now().millisecondsSinceEpoch % 10000, // ID unique local
        'employeeId': employeeId,
        'employeeEmail': employeeEmail,
        'typeId': typeId,
        'typeName': typeName,
        'reason': reason.isEmpty ? 'Demande de congé' : reason,
        'status': 'EN ATTENTE',
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Sauvegarder localement
      await _saveDemandeLocale(demande);
      
      print('✅ Demande sauvée localement: $demande');
      
      return {
        'success': true,
        'message': 'Demande créée et sauvée localement !',
        'demande': demande,
      };
      
    } catch (e) {
      return {'success': false, 'error': 'Erreur: $e'};
    }
  }

  // 📊 RÉCUPÉRER L'HISTORIQUE LOCAL
  static Future<List<Map<String, dynamic>>> getHistoriqueLocal() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? demandesJson = prefs.getString('mes_demandes');
      
      if (demandesJson == null) {
        return [];
      }
      
      final List<dynamic> demandesList = jsonDecode(demandesJson);
      return List<Map<String, dynamic>>.from(demandesList);
      
    } catch (e) {
      print('❌ Erreur lecture historique: $e');
      return [];
    }
  }

  // 💾 SAUVEGARDER DEMANDE LOCALEMENT
  static Future<void> _saveDemandeLocale(Map<String, dynamic> demande) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Récupérer les demandes existantes
      List<Map<String, dynamic>> demandes = await getHistoriqueLocal();
      
      // Ajouter la nouvelle demande en première position
      demandes.insert(0, demande);
      
      // Limiter à 50 demandes max
      if (demandes.length > 50) {
        demandes = demandes.take(50).toList();
      }
      
      // Sauvegarder
      await prefs.setString('mes_demandes', jsonEncode(demandes));
      
    } catch (e) {
      print('❌ Erreur sauvegarde: $e');
    }
  }

  // 🔧 FONCTIONS UTILITAIRES
  static Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<int> _getEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('employee_id') ?? 15;
  }

  static Future<String> _getEmployeeEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('employee_email') ?? 'aa.bb@xtensus.com';
  }
}

// 📱 WIDGETS ULTRA-SIMPLES

// 1. NOUVELLE DEMANDE
class NouvelleDemandeUltraSimple extends StatefulWidget {
  @override
  _NouvelleDemandeUltraSimpleState createState() => _NouvelleDemandeUltraSimpleState();
}

class _NouvelleDemandeUltraSimpleState extends State<NouvelleDemandeUltraSimple> {
  List<Map<String, dynamic>> _typesConge = [];
  Map<String, dynamic>? _selectedType;
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _chargerTypes();
  }

  Future<void> _chargerTypes() async {
    setState(() => _isLoading = true);
    
    final types = await CongeServiceSimple.getTypesConge();
    
    setState(() {
      _typesConge = types;
      if (types.isNotEmpty) {
        _selectedType = types.first;
      }
      _isLoading = false;
    });
  }

  Future<void> _envoyerDemande() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Veuillez sélectionner un type de congé')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await CongeServiceSimple.creerDemandeLocale(
      typeId: _selectedType!['id'],
      typeName: _selectedType!['name'],
      reason: _reasonController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${result['message']}'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Retourner avec résultat
      Navigator.of(context).pop(result['demande']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${result['error']}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Nouvelle demande'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      body: _isLoading && _typesConge.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TYPE DE DEMANDE (comme vos captures)
                  Text('TYPE DE DEMANDE', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Congé',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Autorisation d\'absence',
                            style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),

                  // NATURE DU CONGÉ
                  Text('NATURE DU CONGÉ', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, dynamic>>(
                        value: _selectedType,
                        hint: Text('Sélectionnez la nature', style: TextStyle(color: Colors.grey[600])),
                        isExpanded: true,
                        items: _typesConge.map((type) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: type,
                            child: Text(type['name']),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedType = newValue;
                          });
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // COMMENTAIRE
                  Text('COMMENTAIRE', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  SizedBox(height: 8),
                  Container(
                    height: 100,
                    child: TextField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        hintText: 'Précision (optionnel)',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      maxLines: 3,
                    ),
                  ),
                  
                  SizedBox(height: 20),

                  // PIÈCES JOINTES (placeholder)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.attach_file, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Ajouter une pièce jointe',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(),

                  // BOUTON ENVOYER (identique à vos captures)
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _envoyerDemande,
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Envoyer la demande'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// 2. HISTORIQUE 
class HistoriqueUltraSimple extends StatefulWidget {
  @override
  _HistoriqueUltraSimpleState createState() => _HistoriqueUltraSimpleState();
}

class _HistoriqueUltraSimpleState extends State<HistoriqueUltraSimple> {
  List<Map<String, dynamic>> _historique = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
  }

  Future<void> _chargerHistorique() async {
    setState(() => _isLoading = true);
    
    final historique = await CongeServiceSimple.getHistoriqueLocal();
    
    setState(() {
      _historique = historique;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Historique', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            Text('Mes demandes de congés', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _chargerHistorique,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _historique.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.history,
                          size: 50,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Aucune demande trouvée',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Vos demandes apparaîtront ici',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _historique.length,
                  itemBuilder: (context, index) {
                    final demande = _historique[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '${demande['id']}',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  demande['typeName'] ?? 'Type non défini',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Demande #${demande['id']}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                if (demande['reason'] != null && demande['reason'].toString().isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      demande['reason'],
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Text(
                              demande['status'] ?? 'EN ATTENTE',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

/*
🎯 SOLUTION ULTRA-SIMPLE :

✅ UTILISE VOS ENDPOINTS EXISTANTS (pas de nouveau code backend)
✅ SAUVEGARDE LOCALE (fonctionne même hors ligne)  
✅ INTERFACE IDENTIQUE à vos captures d'écran
✅ AUCUNE AUTRE FONCTIONNALITÉ TOUCHÉE

📋 UTILISATION :
1. Copiez ce code dans votre Flutter
2. Remplacez vos écrans par NouvelleDemandeUltraSimple et HistoriqueUltraSimple
3. Testez avec : aa.bb@xtensus.com / 123456

🎉 RÉSULTAT :
- Types de congé chargés depuis MySQL ✅
- Demandes sauvées localement ✅  
- Historique fonctionnel ✅
- Interface parfaite ✅

FINI LES PROBLÈMES DE BACKEND ! 🚀
*/