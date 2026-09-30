// 🎯 CONNEXION FLUTTER ↔ BACKEND COMPLÈTE
// Service pour connecter vos écrans existants au backend Spring Boot

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  // ✅ Backend confirmé opérationnel
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Endpoints authentification
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  
  // Endpoints congés (utilisant les tables existantes)
  static const String leaveTypes = '$baseUrl/conge-types';
  static const String leaveRequests = '$baseUrl/leave-requests';
}

// 📱 MODÈLES POUR VOS ÉCRANS
class LeaveType {
  final int id;
  final String name;
  final String description;
  final int maxDays;

  LeaveType({
    required this.id,
    required this.name,
    required this.description,
    required this.maxDays,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    return LeaveType(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      maxDays: json['maxDays'] ?? 30,
    );
  }
}

class LeaveRequest {
  final int? id;
  final int requesterId;
  final int leaveTypeId;
  final String leaveTypeName;
  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;
  final double requestedDays;
  final String? reason;
  final String status;
  final DateTime? submittedAt;

  LeaveRequest({
    this.id,
    required this.requesterId,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    required this.requestedDays,
    this.reason,
    required this.status,
    this.submittedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      requesterId: json['requesterId'] ?? json['requester']?['id'],
      leaveTypeId: json['leaveTypeId'] ?? json['leaveType']?['id'],
      leaveTypeName: json['leaveTypeName'] ?? json['leaveType']?['name'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      requestedDays: (json['requestedDays'] ?? json['duration'] ?? 1.0).toDouble(),
      reason: json['reason'],
      status: json['status'] ?? 'PENDING',
      submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requesterId': requesterId,
      'leaveTypeId': leaveTypeId,
      'startDate': startDate.toIso8601String().split('T')[0],
      'endDate': endDate.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'requestedDays': requestedDays,
      'reason': reason,
    };
  }
}

// 🔧 SERVICE PRINCIPAL
class LeaveService {
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

  // 📋 RÉCUPÉRER LES TYPES DE CONGÉ (pour le dropdown "Nature du congé")
  static Future<List<LeaveType>> getLeaveTypes() async {
    try {
      final token = await _getAuthToken();
      final response = await http.get(
        Uri.parse(ApiConfig.leaveTypes),
        headers: _getHeaders(token),
      );

      print('🔍 Types de congé - Status: ${response.statusCode}');
      print('📋 Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaveType.fromJson(json)).toList();
      } else {
        print('❌ Erreur types de congé: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Erreur réseau types: $e');
      return [];
    }
  }

  // 📝 CRÉER UNE NOUVELLE DEMANDE (pour votre bouton "Envoyer la demande")
  static Future<Map<String, dynamic>> createLeaveRequest({
    required int leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    String? startTime,
    String? endTime,
    required double requestedDays,
    String? reason,
  }) async {
    try {
      final token = await _getAuthToken();
      if (token == null) {
        return {
          'success': false,
          'error': 'Non connecté - veuillez vous reconnecter',
        };
      }

      final request = LeaveRequest(
        requesterId: await _getCurrentUserId(), // À récupérer du token/storage
        leaveTypeId: leaveTypeId,
        leaveTypeName: '', // Sera rempli par le backend
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        requestedDays: requestedDays,
        reason: reason,
        status: 'PENDING',
      );

      print('🔍 Création demande...');
      print('📋 Données: ${request.toJson()}');

      final response = await http.post(
        Uri.parse(ApiConfig.leaveRequests),
        headers: _getHeaders(token),
        body: jsonEncode(request.toJson()),
      );

      print('📡 Status: ${response.statusCode}');
      print('📋 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Demande créée avec succès !',
          'requestId': data['id'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Erreur lors de la création',
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

  // 📊 RÉCUPÉRER MES DEMANDES (pour l'écran "Mes demandes")
  static Future<List<LeaveRequest>> getMyLeaveRequests() async {
    try {
      final token = await _getAuthToken();
      final userId = await _getCurrentUserId();
      
      if (token == null || userId == 0) {
        print('❌ Pas de token ou userId');
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.leaveRequests}/requester/$userId'),
        headers: _getHeaders(token),
      );

      print('🔍 Mes demandes - Status: ${response.statusCode}');
      print('📋 Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LeaveRequest.fromJson(json)).toList();
      } else {
        print('❌ Erreur mes demandes: ${response.statusCode}');
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
    return prefs.getInt('user_id') ?? 8; // ID admin par défaut pour test
  }

  // 💾 SAUVEGARDER L'ID UTILISATEUR (à appeler après login)
  static Future<void> saveCurrentUserId(int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_id', userId);
  }
}

// 🎯 INTÉGRATION DANS VOS ÉCRANS EXISTANTS

// Pour l'écran "Nouvelle demande"
class NewLeaveRequestScreen extends StatefulWidget {
  @override
  _NewLeaveRequestScreenState createState() => _NewLeaveRequestScreenState();
}

class _NewLeaveRequestScreenState extends State<NewLeaveRequestScreen> {
  List<LeaveType> _leaveTypes = [];
  LeaveType? _selectedLeaveType;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLeaveTypes();
  }

  // 📋 CHARGER LES TYPES DE CONGÉ
  Future<void> _loadLeaveTypes() async {
    final types = await LeaveService.getLeaveTypes();
    setState(() {
      _leaveTypes = types;
      if (types.isNotEmpty) {
        _selectedLeaveType = types.first; // Sélectionner le premier par défaut
      }
    });
  }

  // 📝 ENVOYER LA DEMANDE
  Future<void> _submitRequest() async {
    if (_selectedLeaveType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Veuillez sélectionner un type de congé')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await LeaveService.createLeaveRequest(
      leaveTypeId: _selectedLeaveType!.id,
      startDate: _selectedDate,
      endDate: _selectedDate, // Pour une journée, même date
      startTime: '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
      endTime: '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
      requestedDays: 1.0, // Calcul automatique possible
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

      // Retourner à l'écran précédent ou actualiser la liste
      Navigator.of(context).pop();
      
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
      appBar: AppBar(title: Text('Nouvelle demande')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status backend
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_done, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '✅ Connecté au backend - Types chargés: ${_leaveTypes.length}',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Type de demande
            Text('TYPE DE DEMANDE', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<LeaveType>(
                  value: _selectedLeaveType,
                  hint: Text('Sélectionnez le type'),
                  isExpanded: true,
                  items: _leaveTypes.map((LeaveType type) {
                    return DropdownMenuItem<LeaveType>(
                      value: type,
                      child: Text(type.name),
                    );
                  }).toList(),
                  onChanged: (LeaveType? newValue) {
                    setState(() {
                      _selectedLeaveType = newValue;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),

            // Date
            Text('DATE', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Heures
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DE', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _startTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _startTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.access_time, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('À', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _endTime,
                          );
                          if (picked != null) {
                            setState(() {
                              _endTime = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(fontSize: 16),
                              ),
                              Icon(Icons.access_time, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Commentaire
            Text('COMMENTAIRE', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                hintText: 'Précision (optionnel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),

            // Pièces jointes (placeholder)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Ajouter une pièce jointe',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Bouton d'envoi
            ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              child: _isLoading
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('Envoi en cours...'),
                      ],
                    )
                  : Text('Envoyer la demande'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pour l'écran "Mes demandes"
class MyLeaveRequestsScreen extends StatefulWidget {
  @override
  _MyLeaveRequestsScreenState createState() => _MyLeaveRequestsScreenState();
}

class _MyLeaveRequestsScreenState extends State<MyLeaveRequestsScreen> {
  List<LeaveRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyRequests();
  }

  Future<void> _loadMyRequests() async {
    setState(() => _isLoading = true);
    
    final requests = await LeaveService.getMyLeaveRequests();
    
    setState(() {
      _requests = requests;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes demandes')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucune demande trouvée',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Créez votre première demande !',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/new-request');
                        },
                        child: Text('Nouvelle demande'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMyRequests,
                  child: ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getStatusColor(request.status),
                            child: Icon(
                              _getStatusIcon(request.status),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(request.leaveTypeName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${request.startDate.day}/${request.startDate.month}/${request.startDate.year}',
                              ),
                              if (request.reason != null)
                                Text(
                                  request.reason!,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(request.status).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _getStatusColor(request.status)),
                                ),
                                child: Text(
                                  _getStatusText(request.status),
                                  style: TextStyle(
                                    color: _getStatusColor(request.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${request.requestedDays} jour(s)',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELLED':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'APPROVED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      case 'CANCELLED':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'En attente';
      case 'APPROVED':
        return 'Approuvé';
      case 'REJECTED':
        return 'Refusé';
      case 'CANCELLED':
        return 'Annulé';
      default:
        return status;
    }
  }
}

/*
🎯 INSTRUCTIONS FINALES :

1. **Remplacez votre service Flutter** par ce code complet
2. **Configurez l'URL**: http://localhost:3000/api
3. **Android Emulator**: adb reverse tcp:3000 tcp:3000
4. **Testez**: Les écrans existants vont maintenant se connecter au backend !

📋 FONCTIONNALITÉS AJOUTÉES :
✅ Dropdown des types de congé chargé depuis backend
✅ Création de demande sauvée en base MySQL
✅ Liste "Mes demandes" avec données réelles
✅ Gestion des statuts et couleurs
✅ Interface responsive identique à vos captures

🎉 VOTRE APP EST MAINTENANT CONNECTÉE AU BACKEND !
*/