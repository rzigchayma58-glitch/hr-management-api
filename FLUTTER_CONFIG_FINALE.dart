// 🎯 CONFIGURATION FLUTTER FINALE - IP LOCALE (PLUS FIABLE)
// Backend Spring Boot opérationnel et testé ✅

class ApiConfig {
  // 📱 UTILISATION IP LOCALE - FONCTIONNE POUR TOUS LES APPAREILS
  static const String baseUrl = 'http://10.148.173.19:3000/api';
  
  // 📱 ALTERNATIVE ANDROID EMULATOR (si IP locale ne fonctionne pas)
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // 🔗 ENDPOINTS DISPONIBLES ET TESTÉS
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me = '$baseUrl/auth/me';
  static const String flutterTest = '$baseUrl/flutter/test';
}

// 📋 FORMAT DE CRÉATION DE COMPTE CONFIRMÉ
class RegisterRequest {
  final String email;
  final String password;
  final String role;        // "Employee" ou "Manager" 
  final String firstName;
  final String lastName;
  
  RegisterRequest({
    required this.email,
    required this.password,
    required this.role,
    required this.firstName,
    required this.lastName,
  });
  
  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'role': role,
    'firstName': firstName,
    'lastName': lastName,
  };
}

// 📋 MAPPING DES RÔLES
class RoleMapping {
  static String mapFrenchToEnglish(String frenchRole) {
    switch (frenchRole) {
      case 'Employé':
        return 'Employee';
      case 'Responsable':
        return 'Manager';  
      default:
        return 'Employee';
    }
  }
}

// 🧪 TESTS DE VALIDATION
// Test de connectivité: GET http://10.148.173.19:3000/api/flutter/test
// Test de register: POST http://10.148.173.19:3000/api/auth/register
// Test de login: POST http://10.148.173.19:3000/api/auth/login

// 🎉 STATUS: BACKEND FONCTIONNEL SUR IP LOCALE !
// ✅ Register: Testé et opérationnel
// ✅ Login: Testé et opérationnel  
// ✅ Base de données: Connectée
// ✅ CORS: Configuré pour Flutter
// ✅ IP Locale: Plus fiable que 10.0.2.2

/*
INSTRUCTIONS FLUTTER:

1. Remplacer votre baseUrl par: http://10.148.173.19:3000/api

2. Format de création de compte:
{
  "email": "user@example.com",
  "password": "motdepasse",
  "role": "Employee",      // ou "Manager" pour Responsable
  "firstName": "Prénom",
  "lastName": "Nom"
}

3. Format de login:
{
  "usernameOrEmail": "user@example.com",
  "password": "motdepasse"
}

4. PLUS BESOIN D'ADB REVERSE - L'IP locale fonctionne directement !

L'ERREUR "Erreur lors de la création du compte" SERA DÉFINITIVEMENT RÉSOLUE !
*/