# 🚀 Solution Rapide - Login XCongés Backend

## ✅ Problème Résolu

**Erreur 503 - Tunnel Unavailable** → **Backend local sur port 8080**

---

## 🔧 **Étape 1: Créer un Utilisateur de Test**

### **Script SQL Rapide**
```sql
-- Connexion à MySQL
USE rh_xtensus;

-- Supprimer utilisateur test s'il existe
DELETE FROM users WHERE email = 'admin@test.com';

-- Créer utilisateur admin de test
INSERT INTO users (
    username, 
    email, 
    password_hash, 
    first_name, 
    last_name, 
    role, 
    status, 
    enabled,
    created_at
) VALUES (
    'admin',
    'admin@test.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password123
    'Admin',
    'Test',
    'ADMIN',
    'ACTIVE',
    true,
    NOW()
);

-- Créer un type de congé
INSERT INTO leave_types (name, max_days, is_paid, requires_approval, created_at) 
VALUES ('Congé Annuel', 25, true, true, NOW());

-- Créer solde pour l'admin
INSERT INTO leave_balances (user_id, leave_type_id, year, total_days, used_days, remaining_days, created_at)
SELECT u.id, lt.id, YEAR(NOW()), 25, 0, 25, NOW()
FROM users u, leave_types lt 
WHERE u.email = 'admin@test.com' AND lt.name = 'Congé Annuel';
```

### **Exécuter le Script**
1. Ouvrir MySQL Workbench ou ligne de commande
2. Coller le script ci-dessus
3. Exécuter

---

## 🚀 **Étape 2: Démarrer le Backend**

```bash
cd c:\Users\msi\backend_leaveapp\hr-management-api
.\mvnw.cmd spring-boot:run
```

**Le backend démarrera sur:** http://localhost:8080

---

## 🧪 **Étape 3: Tester avec Postman**

### **Test Login**
```http
POST http://localhost:8080/api/auth/login
Content-Type: application/json

{
    "usernameOrEmail": "admin@test.com",
    "password": "password123"
}
```

**Réponse Attendue:**
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

## 📱 **Étape 4: Configuration Flutter**

### **Modifier ApiConfig.dart**
```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8080/api';  // PC local
  // static const String baseUrl = 'http://10.0.2.2:8080/api';  // Android emulator
  
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

### **Test de Connexion Flutter**
```dart
// Dans votre app Flutter, testez avec:
final response = await http.get(Uri.parse('http://localhost:8080/api/flutter/test'));
print(response.statusCode); // Devrait être 200
```

---

## 🔑 **Comptes de Test Créés**

| Email | Mot de Passe | Rôle | Usage |
|-------|--------------|------|-------|
| `admin@test.com` | `password123` | ADMIN | Tests complets |

---

## ⚡ **URLs de Test Direct**

### **Backend Health Check**
- http://localhost:8080/actuator/health
- http://localhost:8080/api/flutter/test

### **Endpoints Principaux**
- **Login:** POST http://localhost:8080/api/auth/login
- **Profile:** GET http://localhost:8080/api/auth/me
- **Congés:** GET http://localhost:8080/api/leave-requests

---

## 🐛 **Dépannage Rapide**

### **Port déjà utilisé?**
```bash
netstat -ano | findstr :8080
taskkill /PID [PID_NUMBER] /F
```

### **Base de données inaccessible?**
Vérifiez MySQL dans services Windows ou démarrez:
```bash
net start mysql
```

### **CORS bloqué?**
Le backend est configuré pour accepter:
- http://localhost:4200
- http://127.0.0.1:*
- http://10.0.2.2:8080

---

## 🎯 **Résultat Attendu**

✅ **Backend démarré** sur http://localhost:8080  
✅ **Login fonctionnel** avec admin@test.com  
✅ **Postman validé** avec token JWT  
✅ **Flutter connecté** aux vrais endpoints  

**Temps estimé:** 5 minutes max !