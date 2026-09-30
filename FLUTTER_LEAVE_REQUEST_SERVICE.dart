// 🎯 SERVICE FLUTTER POUR DEMANDES DE CONGÉ
// Connecté au Backend Spring Boot + Base de données MySQL

import 'dart:convert';
import 'package:http/http.dart' as http;

// 📋 CONFIGURATION API
class ApiConfig {
  static const String baseUrl = 'http://10.148.173.19:3000/api';
  
  // Endpoints pour demandes de congé
  static const String leaveRequests = '$baseUrl/leave-requests';
  static const String leaveTypes = '$baseUrl/leave-types';
  static const String congeTypes = '$baseUrl/conge-types';
  static const String userLeaveRequests = '$baseUrl/leave-requests/requester';
}

// 📋 MODÈLES DE DONNÉES
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
      name: json['name'],
      description: json['description'] ?? '',
      maxDays: json['maxDays'] ?? 30,
    );
  }
}

class LeaveRequest {
  final int? id;
  final int requesterId;
  final int leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final String? reason;
  final String? status;
  
  LeaveRequest({
    this.id,
    required this.requesterId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    this.reason,
    this.status,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'requesterId': requesterId,
      'leaveTypeId': leaveTypeId,
      'startDate': startDate.toIso8601String().split('T')[0], // Format: 2026-09-26
      'endDate': endDate.toIso8601String().split('T')[0],
      'reason': reason,
    };
  }
  
  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'],
      requesterId: json['requesterId'],
      leaveTypeId: json['leaveTypeId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'],
      status: json['status'],
    );
  }
}

// 🔗 SERVICE API POUR DEMANDES DE CONGÉ
class LeaveRequestService {
  
  // Récupérer les types de congé disponibles
  static Future<List<LeaveType>> getLeaveTypes() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.leaveTypes),
        headers: {'Accept': 'application/json'},
      );
      
      print('🔍 Leave Types Response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => LeaveType.fromJson(item)).toList();
      } else {
        throw Exception('Erreur lors du chargement des types de congé');
      }
    } catch (e) {
      print('🔍 Erreur getLeaveTypes: $e');
      // Types par défaut si erreur
      return [
        LeaveType(id: 1, name: 'Congé annuel', description: 'Congé payé annuel', maxDays: 30),
        LeaveType(id: 2, name: 'Congé maladie', description: 'Congé pour maladie', maxDays: 90),
        LeaveType(id: 3, name: 'Congé maternité', description: 'Congé maternité', maxDays: 120),
      ];
    }
  }
  
  // Créer une nouvelle demande de congé
  static Future<Map<String, dynamic>> createLeaveRequest(LeaveRequest leaveRequest) async {
    try {
      final requestData = leaveRequest.toJson();
      
      print('🔍 Création demande - URL: ${ApiConfig.leaveRequests}');
      print('🔍 Création demande - Data: $requestData');
      
      final response = await http.post(
        Uri.parse(ApiConfig.leaveRequests),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );
      
      print('🔍 Response Status: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Demande de congé créée avec succès !',
          'data': json.decode(response.body),
        };
      } else {
        return {
          'success': false,
          'message': 'Erreur lors de la création (${response.statusCode})',
          'error': response.body,
        };
      }
    } catch (e) {
      print('🔍 Erreur createLeaveRequest: $e');
      return {
        'success': false,
        'message': 'Erreur de connexion: $e',
      };
    }
  }
  
  // Récupérer les demandes d'un utilisateur
  static Future<List<LeaveRequest>> getUserLeaveRequests(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.userLeaveRequests}/$userId'),
        headers: {'Accept': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => LeaveRequest.fromJson(item)).toList();
      } else {
        throw Exception('Erreur lors du chargement des demandes');
      }
    } catch (e) {
      print('🔍 Erreur getUserLeaveRequests: $e');
      return [];
    }
  }
  
  // Calculer le nombre de jours ouvrés entre deux dates
  static int calculateWorkingDays(DateTime startDate, DateTime endDate) {
    int workingDays = 0;
    DateTime current = startDate;
    
    while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
      // Exclure samedi (6) et dimanche (7)
      if (current.weekday != 6 && current.weekday != 7) {
        workingDays++;
      }
      current = current.add(Duration(days: 1));
    }
    
    return workingDays;
  }
}

// 🎯 WIDGET FLUTTER POUR CRÉATION DE DEMANDE DE CONGÉ
class CreateLeaveRequestPage extends StatefulWidget {
  final int userId; // ID de l'utilisateur connecté
  
  const CreateLeaveRequestPage({Key? key, required this.userId}) : super(key: key);
  
  @override
  _CreateLeaveRequestPageState createState() => _CreateLeaveRequestPageState();
}

class _CreateLeaveRequestPageState extends State<CreateLeaveRequestPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs de formulaire
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  int? _selectedLeaveTypeId;
  List<LeaveType> _leaveTypes = [];
  bool _isLoading = false;
  
  // Type de demande sélectionné
  String _requestType = 'Congé'; // 'Congé' ou 'Autorisation d'absence'
  
  @override
  void initState() {
    super.initState();
    _loadLeaveTypes();
  }
  
  // Charger les types de congé depuis le backend
  Future<void> _loadLeaveTypes() async {
    setState(() => _isLoading = true);
    
    try {
      final leaveTypes = await LeaveRequestService.getLeaveTypes();
      setState(() {
        _leaveTypes = leaveTypes;
        if (leaveTypes.isNotEmpty) {
          _selectedLeaveTypeId = leaveTypes.first.id;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Sélectionner une date
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Reset end date if it's before start date
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
  
  // Soumettre la demande
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner les dates')),
      );
      return;
    }
    if (_selectedLeaveTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner un type de congé')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final leaveRequest = LeaveRequest(
      requesterId: widget.userId,
      leaveTypeId: _selectedLeaveTypeId!,
      startDate: _startDate!,
      endDate: _endDate!,
      reason: _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim(),
    );
    
    try {
      final result = await LeaveRequestService.createLeaveRequest(leaveRequest);
      
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Retour à la page précédente
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  // Calculer et afficher les jours ouvrés
  Widget _buildWorkingDaysDisplay() {
    if (_startDate == null || _endDate == null) return Container();
    
    final workingDays = LeaveRequestService.calculateWorkingDays(_startDate!, _endDate!);
    
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.orange),
          SizedBox(width: 8),
          Text(
            '$workingDays jours ouvrés',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[800],
            ),
          ),
          SizedBox(width: 8),
          Text('Calcul automatique'),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Nouvelle demande'),
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type de demande
                    Text('TYPE DE DEMANDE', style: TextStyle(color: Colors.grey[400])),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _requestType = 'Congé'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _requestType == 'Congé' ? Colors.orange : Colors.grey[700],
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(8)),
                              ),
                              child: Center(
                                child: Text('Congé', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _requestType = 'Autorisation d\'absence'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _requestType == 'Autorisation d\'absence' ? Colors.orange : Colors.grey[700],
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
                              ),
                              child: Center(
                                child: Text('Autorisation d\'absence', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // Nature du congé (Type de congé)
                    Text('NATURE DU CONGÉ', style: TextStyle(color: Colors.grey[400])),
                    SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: _selectedLeaveTypeId,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[700],
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      dropdownColor: Colors.grey[700],
                      style: TextStyle(color: Colors.white),
                      items: _leaveTypes.map((type) => DropdownMenuItem(
                        value: type.id,
                        child: Text(type.name),
                      )).toList(),
                      onChanged: (value) {
                        setState(() => _selectedLeaveTypeId = value);
                      },
                    ),
                    SizedBox(height: 24),
                    
                    // Dates
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('DÉBUT', style: TextStyle(color: Colors.grey[400])),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, true),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _startDate?.toString().split(' ')[0] ?? '26/09/2026',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(Icons.calendar_today, color: Colors.white),
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
                              Text('FIN', style: TextStyle(color: Colors.grey[400])),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectDate(context, false),
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[700],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _endDate?.toString().split(' ')[0] ?? '30/09/2026',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Icon(Icons.calendar_today, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    // Affichage jours ouvrés
                    _buildWorkingDaysDisplay(),
                    
                    // Validation délai
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Délai de préavis respecté (minimum 72h)',
                            style: TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Commentaire
                    Text('COMMENTAIRE', style: TextStyle(color: Colors.grey[400])),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Précision (optionnel)',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[700],
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 24),
                    
                    // Pièces jointes
                    Text('PIÈCES JOINTES', style: TextStyle(color: Colors.grey[400])),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.attach_file, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Ajouter une pièce jointe', style: TextStyle(color: Colors.orange)),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    
                    // Bouton soumettre
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Créer ma demande',
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// 🎯 UTILISATION DANS VOTRE APP
/*
// Dans votre navigation ou bouton "Nouvelle demande":
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CreateLeaveRequestPage(
      userId: currentUser.id, // ID de l'utilisateur connecté
    ),
  ),
);
*/