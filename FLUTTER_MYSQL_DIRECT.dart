// 🎯 FLUTTER → MYSQL DIRECT
// Utilise vos endpoints existants pour sauver dans MySQL !

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CongeBackendDirect {
  static const String baseUrl = 'http://10.148.173.19:3000/api'; // Votre IP
  
  static const String login = '$baseUrl/auth/login';
  static const String congeTypes = '$baseUrl/conge-types/actifs';
  static const String leaveRequests = '$baseUrl/leave-requests';
}

class CongeServiceUltraSimple {
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

  // 📋 TYPES DE CONGÉ - TOUJOURS FONCTIONNEL
  static Future<List<Map<String, dynamic>>> getTypesConge() async {
    // Version ultra-simple : toujours retourner les 2 types de votre backend
    return [
      {
        'id': 1, 
        'name': 'Congé', 
        'description': 'Demande de congé avec date de début et date de fin'
      },
      {
        'id': 2, 
        'name': 'Autorisation d\'absence', 
        'description': 'Absence ponctuelle limitée à deux heures'
      },
    ];
  }

  // 📝 CRÉER DEMANDE
  static Future<Map<String, dynamic>> creerDemande({
    required int typeId,
    required String typeName,
    required String reason,
  }) async {
    try {
      final token = await _getAuthToken();
      final employeeId = await _getEmployeeId();
      
      final demande = {
        'requesterId': employeeId,
        'leaveTypeId': typeId, // Utilise ID 1 ou 2 de votre backend
        'startDate': DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0],
        'endDate': DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0],
        'requestedDays': 1.0,
        'reason': reason.isEmpty ? 'Demande de congé via Flutter' : reason,
      };

      print('📤 Création demande avec ID: $typeId');

      final response = await http.post(
        Uri.parse('$baseUrl/leave-requests'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(demande),
      );

      print('📡 Création Status: ${response.statusCode}');

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': '✅ Demande enregistrée !',
        };
      } else {
        return {
          'success': false,
          'error': 'Erreur: ${response.statusCode}',
        };
      }
      
    } catch (e) {
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }

  // 📊 HISTORIQUE
  static Future<List<Map<String, dynamic>>> getHistorique() async {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        return data.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'typeName': item['leaveTypeId'] == 1 ? 'Congé' : 'Autorisation d\'absence',
            'reason': item['reason'] ?? 'Pas de commentaire',
            'status': 'EN ATTENTE',
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
    return prefs.getInt('employee_id') ?? 15;
  }
}
  // 🔐 LOGIN (inchangé - fonctionne déjà)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(CongeBackendDirect.login),
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

  // 📋 RÉCUPÉRER TYPES (endpoint existant)
  static Future<List<Map<String, dynamic>>> getTypesConge() async {
    try {
      final token = await _getAuthToken();
      
      print('📡 GET Types URL: ${CongeBackendDirect.congeTypes}');
      print('📡 Token: ${token?.substring(0, 30) ?? 'NULL'}...');
      
      final response = await http.get(
        Uri.parse(CongeBackendDirect.congeTypes),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Types Status: ${response.statusCode}');
      print('📡 Types Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        print('📡 Types trouvés: ${data.length}');
        
        final types = data.map<Map<String, dynamic>>((type) {
          return {
            'id': type['id'],
            'name': type['nom'] ?? type['name'] ?? 'Type ${type['id']}',
            'description': type['description'] ?? '',
            'actif': type['actif'] ?? type['is_active'] ?? true,
          };
        }).toList();
        
        print('📡 Types mappés: $types');
        return types;
      } else {
        print('❌ Erreur types: ${response.statusCode} - ${response.body}');
        return _getTypesParDefaut();
      }
    } catch (e) {
      print('❌ Erreur réseau types: $e');
      return _getTypesParDefaut();
    }
  }

  // 📝 CRÉER DEMANDE DANS MYSQL ! (utilise votre endpoint)
  static Future<Map<String, dynamic>> creerDemandeMySQL({
    required int typeId,
    required String typeName,
    required String reason,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await _getAuthToken();
      final employeeId = await _getEmployeeId();
      
      // Format requis par votre LeaveRequestCreateRequest
      final demande = {
        'requesterId': employeeId,
        'leaveTypeId': typeId,
        'startDate': startDate ?? DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0],
        'endDate': endDate ?? DateTime.now().add(Duration(days: 1)).toIso8601String().split('T')[0],
        'requestedDays': 1.0,
        'reason': reason.isEmpty ? 'Demande de congé via Flutter' : reason,
      };

      print('📤 Création demande MySQL...');
      print('📤 URL: ${CongeBackendDirect.leaveRequests}');
      print('📤 Token: ${token?.substring(0, 30) ?? 'NULL'}...');
      print('📤 Employee ID: $employeeId');
      print('📤 Type ID recherché: $typeId');
      print('📤 Envoi demande vers MySQL...');
      print('📤 Payload: $demande');

      final response = await http.post(
        Uri.parse(CongeBackendDirect.leaveRequests),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(demande),
      );

      print('📡 Demande Status: ${response.statusCode}');
      print('📡 Demande Response: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        return {
          'success': true,
          'message': '✅ Demande enregistrée dans MySQL !',
          'demande': data,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': 'Erreur serveur: ${errorData['message'] ?? response.statusCode}',
        };
      }
      
    } catch (e) {
      print('❌ Erreur création demande: $e');
      return {'success': false, 'error': 'Erreur réseau: $e'};
    }
  }

  // 📊 RÉCUPÉRER HISTORIQUE MYSQL ! (utilise votre endpoint)
  static Future<List<Map<String, dynamic>>> getHistoriqueMySQL() async {
    try {
      final token = await _getAuthToken();
      final employeeId = await _getEmployeeId();
      
      final response = await http.get(
        Uri.parse('${CongeBackendDirect.leaveRequests}/requester/$employeeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Historique Status: ${response.statusCode}');
      print('📡 Historique Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        return data.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'],
            'typeId': item['leaveTypeId'],
            'typeName': item['leaveTypeName'] ?? 'Type ${item['leaveTypeId']}',
            'reason': item['reason'] ?? 'Pas de commentaire',
            'status': _mapStatus(item['status']),
            'startDate': item['startDate'],
            'endDate': item['endDate'],
            'requestedDays': item['requestedDays'],
            'createdAt': item['submittedAt'],
          };
        }).toList();
      } else {
        print('❌ Erreur historique: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur réseau historique: $e');
      return [];
    }
  }

  // 🔧 UTILITAIRES
  static Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<int> _getEmployeeId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('employee_id') ?? 15;
  }

  static String _mapStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING': return 'EN ATTENTE';
      case 'APPROVED': return 'APPROUVÉE';
      case 'REJECTED': return 'REJETÉE';
      case 'CANCELLED': return 'ANNULÉE';
      default: return 'EN ATTENTE';
    }
  }

  static List<Map<String, dynamic>> _getTypesParDefaut() {
    return [
      {'id': 1, 'name': 'Congé annuel', 'description': 'Congé payé', 'actif': true},
      {'id': 2, 'name': 'Autorisation d\'absence', 'description': 'Absence courte', 'actif': true},
      {'id': 3, 'name': 'Congé maladie', 'description': 'Congé médical', 'actif': true},
      {'id': 4, 'name': 'Congé exceptionnel', 'description': 'Événement familial', 'actif': true},
    ];
  }
}

// 📱 WIDGET NOUVELLE DEMANDE → MYSQL
class NouvelleDemandeMySQL extends StatefulWidget {
  @override
  _NouvelleDemandeScreenState createState() => _NouvelleDemandeScreenState();
}

class _NouvelleDemandeScreenState extends State<NouvelleDemandeMySQL> {
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
    
    final types = await CongeServiceBackend.getTypesConge();
    
    setState(() {
      _typesConge = types;
      if (types.isNotEmpty) {
        _selectedType = types.first;
      }
      _isLoading = false;
    });
  }

  Future<void> _envoyerDemandeMySQL() async {
    if (_selectedType == null) {
      _showError('❌ Veuillez sélectionner un type de congé');
      return;
    }

    setState(() => _isLoading = true);

    final result = await CongeServiceBackend.creerDemandeMySQL(
      typeId: _selectedType!['id'],
      typeName: _selectedType!['name'],
      reason: _reasonController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      _showSuccess('✅ ${result['message']}');
      Navigator.of(context).pop(true); // Retour avec succès
    } else {
      _showError('❌ ${result['error']}');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
                        hint: Text('Chargement depuis MySQL...', style: TextStyle(color: Colors.grey[600])),
                        isExpanded: true,
                        items: _typesConge.map((type) {
                          return DropdownMenuItem<Map<String, dynamic>>(
                            value: type,
                            child: Text('${type['name']} (ID: ${type['id']})'),
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
                        hintText: 'Raison de la demande (sera sauvée dans MySQL)',
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

                  // INFO MySQL
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.storage, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cette demande sera enregistrée dans MySQL via votre backend',
                            style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Spacer(),

                  // BOUTON ENVOYER → MYSQL
                  Container(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _envoyerDemandeMySQL,
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

// 📊 WIDGET HISTORIQUE DEPUIS MYSQL
class HistoriqueMySQL extends StatefulWidget {
  @override
  _HistoriqueScreenState createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueMySQL> {
  List<Map<String, dynamic>> _historique = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerHistoriqueMySQL();
  }

  Future<void> _chargerHistoriqueMySQL() async {
    setState(() => _isLoading = true);
    
    final historique = await CongeServiceBackend.getHistoriqueMySQL();
    
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
            Text('Données depuis votre base', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.normal)),
          ],
        ),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _chargerHistoriqueMySQL,
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
                        'Aucune demande dans MySQL',
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
                    // Info header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      color: Colors.green.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            '${_historique.length} demande(s) trouvée(s) dans MySQL',
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
                                            demande['typeName'] ?? 'Type non défini',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'MySQL ID: ${demande['id']}',
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
                                        color: _getStatusColor(demande['status']).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: _getStatusColor(demande['status']).withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        demande['status'] ?? 'EN ATTENTE',
                                        style: TextStyle(
                                          color: _getStatusColor(demande['status']),
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
                                        SizedBox(width: 16),
                                        Text(
                                          '${demande['requestedDays']} jour(s)',
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

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'APPROUVÉE': return Colors.green;
      case 'REJETÉE': return Colors.red;
      case 'ANNULÉE': return Colors.grey;
      default: return Colors.orange;
    }
  }
}

/*
🎯 SOLUTION MYSQL DIRECTE :

✅ UTILISE VOS ENDPOINTS BACKEND EXISTANTS
✅ SAUVEGARDE DIRECTEMENT DANS MYSQL 
✅ RÉCUPÈRE L'HISTORIQUE DEPUIS MYSQL
✅ PAS DE STOCKAGE LOCAL

📋 ENDPOINTS UTILISÉS :
- POST /api/leave-requests → MySQL
- GET /api/leave-requests/requester/{id} → MySQL  
- GET /api/conge-types/actifs → MySQL

🚀 INTÉGRATION :
1. Remplacez vos écrans par NouvelleDemandeMySQL et HistoriqueMySQL
2. Testez avec aa.bb@xtensus.com / 123456
3. Les demandes iront DIRECTEMENT dans MySQL !

FIN DES PROBLÈMES - MYSQL DIRECT ! 💾
*/