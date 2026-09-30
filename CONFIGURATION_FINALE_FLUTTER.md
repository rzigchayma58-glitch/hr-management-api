# 🎯 Configuration Finale Flutter XCongés

## ✅ **BACKEND CONFIGURÉ ET OPÉRATIONNEL**

### **Port Configuration**
- **Fichier .env mis à jour** : `SERVER_PORT=8082`
- **Backend accessible** : http://localhost:8082
- **Health Check** : http://localhost:8082/actuator/health ✅

### **URLs pour Flutter**

| Environnement | URL Backend |
|---------------|-------------|
| **PC Local** | `http://localhost:8082/api` |
| **Android Emulator** | `http://10.0.2.2:8082/api` |
| **iOS Simulator** | `http://127.0.0.1:8082/api` |

---

## 📱 **Configuration Flutter Required**

### **1. ApiConfig.dart**
```dart
// lib/config/api_config.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kDebugMode;

class ApiConfig {
  // URLs par environnement - PORT 8082 !!
  static const String devUrlAndroid = 'http://10.0.2.2:8082/api';
  static const String devUrlIOS = 'http://127.0.0.1:8082/api';
  static const String devUrlPC = 'http://localhost:8082/api';
  static const String prodUrl = 'https://api.xconges.com/api';
  
  static String get baseUrl {
    if (kDebugMode) {
      // Pour test sur PC Windows
      if (Platform.isWindows) return devUrlPC;
      // Pour émulateur mobile
      return Platform.isAndroid ? devUrlAndroid : devUrlIOS;
    }
    return prodUrl;
  }
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
```

### **2. Dépendances pubspec.yaml**
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
  provider: ^6.1.2
```

### **3. Test de Connexion Simple**
```dart
// Copiez ce code dans un widget de test
import 'package:http/http.dart' as http;

Future<void> testBackendConnection() async {
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8082/api/flutter/test'),
      headers: {'Content-Type': 'application/json'},
    );
    
    if (response.statusCode == 200) {
      print('✅ Backend connecté : ${response.body}');
    } else {
      print('❌ Erreur ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Erreur réseau: $e');
  }
}
```

---

## 🔐 **Authentification - Prêt à Utiliser**

### **Utilisateur de Test Créé**
- **Email** : `admin@test.com`
- **Password** : `password123`
- **Role** : `ADMIN`

### **Test Login Direct**
```bash
# Test avec curl (PowerShell)
$loginData = '{"usernameOrEmail": "admin@test.com", "password": "password123"}'
curl -X POST http://localhost:8082/api/auth/login -H "Content-Type: application/json" -d $loginData
```

**Réponse Attendue :**
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "tokenType": "Bearer",
  "expiresIn": 3600000,
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@test.com",
    "firstName": "Admin",
    "lastName": "Test",
    "role": "ADMIN"
  }
}
```

---

## 🧪 **Collection Postman Mise à Jour**

### **Importer la Collection**
1. Fichier : `XConges_API_Tests.postman_collection.json`
2. URL de base automatique : `http://localhost:8082/api`
3. Tests automatiques inclus

### **Scénario de Test Complet**
1. **Login** → Récupère le token automatiquement
2. **Get User Profile** → Valide l'authentification  
3. **Create Leave Request** → Test création congé
4. **Get User Requests** → Liste des demandes
5. **Upload Medical Document** → Test upload fichier

---

## 🗄️ **Base de Données - Script Utilisateur**

### **Exécuter dans MySQL**
```sql
-- Script déjà créé : CREATE_TEST_USER.sql
USE rh_xtensus;

INSERT INTO users (username, email, password_hash, first_name, last_name, role, status, enabled, created_at) 
VALUES ('admin', 'admin@test.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Admin', 'Test', 'ADMIN', 'ACTIVE', true, NOW());
```

---

## 🚀 **Endpoints Principaux Testés**

| Endpoint | Méthode | URL | Status |
|----------|---------|-----|---------|
| Health Check | GET | `/actuator/health` | ✅ |
| Flutter Test | GET | `/api/flutter/test` | ✅ |
| Login | POST | `/api/auth/login` | ✅ |
| User Profile | GET | `/api/auth/me` | ✅ |
| Leave Requests | GET | `/api/leave-requests/requester/{id}` | ✅ |
| Create Request | POST | `/api/leave-requests` | ✅ |
| Upload File | POST | `/api/medical-documents/upload/{id}` | ✅ |

---

## ⚡ **Démarrage Rapide Flutter**

### **Étapes Finales (2 minutes)**

1. **Modifier ApiConfig.dart** avec port 8082
2. **Ajouter les dépendances** http et shared_preferences  
3. **Tester avec le code de connexion** fourni
4. **Login avec admin@test.com / password123**

### **Vérification Succès**
```dart
// Si cette requête fonctionne, vous êtes prêt !
final response = await http.get(
  Uri.parse('http://localhost:8082/actuator/health')
);
print(response.statusCode); // Doit afficher: 200
```

---

## 🎉 **RÉSULTAT FINAL**

✅ **Backend Spring Boot** opérationnel sur port 8082  
✅ **Base de données MySQL** connectée  
✅ **Utilisateur test** créé et validé  
✅ **JWT authentification** fonctionnelle  
✅ **CORS** configuré pour Flutter  
✅ **Collection Postman** prête  
✅ **Configuration .env** optimisée  

### **🚀 VOTRE FLUTTER APP PEUT MAINTENANT SE CONNECTER !**

**Prochain test** : Lancez votre app Flutter avec la nouvelle configuration et testez le login avec admin@test.com !