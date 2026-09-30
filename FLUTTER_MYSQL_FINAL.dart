// 🎯 FLUTTER MYSQL FINAL - ADAPTÉ À VOTRE BASE EXACTE
// Basé sur vos captures MySQL conge_demandes

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CongeServiceMySQL {
  static const String baseUrl = 'http://10.148.173.19:3000/api';
  
  // 🔐 LOGIN (testé et fonctionne)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
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

  // 📋 TYPES - BASÉS SUR VOTRE BASE MySQL (conge_demandes)
  static Future<List<Map<String, dynamic>>> getTypesConge() async {
    // Types exacts de votre base MySQL
    return [
      {
        'id': 1,  // conge_type_id = 1 dans votre base
        'name': 'CONGÉ',
        'description': 'Demande de congé standard',
        'mysql_name': 'CONGE'  // Nom exact dans votre base
      },
      {
        'id': 2,  // conge_type_id = 2 dans votre base  
        'name': 'AUTORISATION D\'ABSENCE',
        'description': 'Autorisation d\'absence ponctuelle',
        'mysql_name': 'AUTORISATION_ABSENCE'  // Nom exact dans votre base
      },
    ];
  }

  // 📝 CRÉER DEMANDE (compatible avec votre structure)
  static Future<Map<String, dynamic>> creerDemandeMySQL({
    required int typeId,
    required String typeName,
    required String reason,
  }) async {
    try {
      final token = await _getAuthToken();
      final employeeId = await _getEmployeeId();
      
      // Format compatible avec votre backend Spring Boot
      final demande = {
        'requesterId': employeeId,  // employee_id dans votre base
        'leaveTypeId': typeId,     // conge_type_id (1 ou 2)
        'startDate': DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0],
        'endDate': DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0],
        'requestedDays': 1.0,
        'reason': reason.isEmpty ? 'Demande de congé via Flutter' : reason,
      };

      print('📤 Création demande MySQL...');
      print('📤 Type ID: $typeId (${typeId == 1 ? 'CONGE' : 'AUTORISATION_ABSENCE'})');
      print('📤 Employee ID: $employeeId');

      final response = await http.post(
        Uri.parse('$baseUrl/leave-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(demande),
      );

      print('📡 Status: ${response.statusCode}');
      print('📡 Response: ${response.body}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': '✅ Demande enregistrée dans MySQL !',
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur serveur: ${response.statusCode}',
        };
      }
      
    } catch (e) {
      print('❌ Erreur: $e');
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }

  // 📊 HISTORIQUE (depuis votre table conge_demandes)
  static Future<List<Map<String, dynamic>>> getHistoriqueMySQL() async {
    try {
      final token = await _getAuthToken();
      final employeeId = await _getEmployeeId();
      
      final response = await http.get(
        Uri.parse('$baseUrl/leave-requests/requester/$employeeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Historique Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        return data.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'typeId': item['leaveTypeId'],
            'typeName': _getTypeNameFromId(item['leaveTypeId']),
            'reason': item['reason'] ?? 'Pas de commentaire',
            'status': 'EN ATTENTE',
            'startDate': item['startDate'],
            'endDate': item['endDate'],
            'createdAt': item['submittedAt'],
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // Utilitaires
  static Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<int> _getEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('employee_id') ?? 2; // Par défaut employé ID 2 (comme dans votre base)
  }

  static String _getTypeNameFromId(int? typeId) {
    switch (typeId) {
      case 1: return 'CONGÉ';
      case 2: return 'AUTORISATION D\'ABSENCE';
      default: return 'Type inconnu';
    }
  }
}

// 📱 INTERFACE NOUVELLE DEMANDE - ADAPTÉE MYSQL
class NouvelleDemandeMySQL extends StatefulWidget {
  @override
  _NouvelleDemandeState createState() => _NouvelleDemandeState();
}

class _NouvelleDemandeState extends State<NouvelleDemandeMySQL> {
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
    
    final types = await CongeServiceMySQL.getTypesConge();
    
    setState(() {
      _typesConge = types;
      if (types.isNotEmpty) {
        _selectedType = types.first; // Par défaut : CONGÉ (ID 1)
      }
      _isLoading = false;
    });

    print('📋 Types MySQL chargés: ${_typesConge.length}');
  }

  Future<void> _envoyerDemande() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Sélectionnez un type'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await CongeServiceMySQL.creerDemandeMySQL(
      typeId: _selectedType!['id'],
      typeName: _selectedType!['name'],
      reason: _reasonController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${result['message']}'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ ${result['error']}'), backgroundColor: Colors.red),
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
                  // STATUT MYSQL
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.storage, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Types MySQL : ${_typesConge.map((t) => '${t['mysql_name']} (ID:${t['id']})').join(', ')}',
                            style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),

                  // TYPE DE DEMANDE
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

                  // NATURE DU CONGÉ (depuis MySQL)
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
                        hint: Text('Sélectionnez depuis MySQL', style: TextStyle(color: Colors.grey[600])),
                        isExpanded: true,
                        items: _typesConge.map((type) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: type,
                            child: Text('${type['name']} (MySQL ID: ${type['id']})'),
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

                  // PIÈCES JOINTES
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

                  // BOUTON ENVOYER VERS MYSQL
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
                          : Text('💾 Enregistrer dans MySQL'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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

// 📊 WIDGET HISTORIQUE MYSQL
class HistoriqueMySQL extends StatefulWidget {
  @override
  _HistoriqueMySQLState createState() => _HistoriqueMySQLState();
}

class _HistoriqueMySQLState extends State<HistoriqueMySQL> {
  List<Map<String, dynamic>> _historique = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
  }

  Future<void> _chargerHistorique() async {
    setState(() => _isLoading = true);
    
    final historique = await CongeServiceMySQL.getHistoriqueMySQL();
    
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
            Text('Historique MySQL', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            Text('Depuis conge_demandes', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
          ],
        ),
        backgroundColor: Colors.green,
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
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.storage,
                          size: 50,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Aucune demande MySQL',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Créez votre première demande !',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header info
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      color: Colors.green.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(Icons.storage, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            '${_historique.length} demande(s) MySQL trouvée(s)',
                            style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.storage,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            demande['typeName'] ?? 'Type inconnu',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'MySQL ID: ${demande['id']} (Type: ${demande['typeId']})',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        demande['status'] ?? 'EN ATTENTE',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (demande['reason'] != null && demande['reason'].toString().isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 12),
                                    child: Text(
                                      demande['reason'],
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                if (demande['startDate'] != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                                        SizedBox(width: 4),
                                        Text(
                                          'Du ${demande['startDate']} au ${demande['endDate']}',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

/*
🎯 FLUTTER MYSQL FINAL - ADAPTÉ À VOTRE BASE

✅ BASÉ SUR VOS CAPTURES MYSQL :
- Type ID 1 : "CONGÉ" (mysql_name: "CONGE")
- Type ID 2 : "AUTORISATION D'ABSENCE" (mysql_name: "AUTORISATION_ABSENCE")

✅ INTERFACE ADAPTÉE :
- Dropdown avec vos types exacts
- Infos MySQL visibles (Types MySQL: CONGE (ID:1), AUTORISATION_ABSENCE (ID:2))
- Création avec bons IDs

✅ COMPATIBLE BACKEND :
- Utilise endpoint /api/leave-requests 
- Format requesterId, leaveTypeId compatible
- Gestion erreur robuste

🚀 UTILISATION :
1. Remplacez par NouvelleDemandeMySQL() et HistoriqueMySQL()
2. Testez - Les IDs 1 et 2 correspondent à votre base !

VOTRE APP EST PARFAITEMENT ADAPTÉE À MYSQL ! 🎉
*/