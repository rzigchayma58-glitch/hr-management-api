# 🎯 GUIDE ULTRA-SIMPLE - 3 ÉTAPES SEULEMENT !

## ✅ SITUATION ACTUELLE
- **Backend Spring Boot** : ✅ FONCTIONNE sur localhost:3000
- **Endpoints** : ✅ Login, Types de congé, Demandes OPÉRATIONNELS
- **Interface Flutter** : ✅ Prête mais pas connectée

## 🚀 3 ÉTAPES POUR CONNECTER VOTRE APP

### ÉTAPE 1: EXÉCUTER LE SCRIPT SQL (2 minutes)
1. Ouvrez **phpMyAdmin** dans votre navigateur
2. Sélectionnez la base **`rh_xtensus`**
3. Cliquez sur **"SQL"**
4. Copiez-collez ce code :

```sql
USE rh_xtensus;

-- Table types de congé Flutter
CREATE TABLE IF NOT EXISTS flutter_leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT IGNORE INTO flutter_leave_types (id, name, description) VALUES 
(1, 'Congé annuel', 'Congé payé annuel'),
(2, 'Autorisation d\'absence', 'Absence ponctuelle');

-- Table demandes Flutter
CREATE TABLE IF NOT EXISTS flutter_leave_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    requesterId BIGINT NOT NULL,
    leaveTypeId BIGINT NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    reason TEXT,
    status ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
    submittedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Demande test
INSERT IGNORE INTO flutter_leave_requests (requesterId, leaveTypeId, startDate, endDate, reason) 
VALUES (15, 1, '2026-10-01', '2026-10-03', 'Test Flutter');

SELECT 'TABLES CRÉÉES AVEC SUCCÈS !' as message;
```

5. Cliquez **"Exécuter"**

### ÉTAPE 2: CONFIGURER FLUTTER (1 minute)
Dans votre projet Flutter, remplacez votre configuration API par :

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000/api';
}

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usernameOrEmail': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {'success': true, 'token': data['accessToken']};
    } else {
      return {'success': false, 'error': 'Login échoué'};
    }
  }
}
```

### ÉTAPE 3: ANDROID EMULATOR (30 secondes)
Si vous utilisez Android Emulator, ouvrez **cmd** et tapez :
```bash
adb reverse tcp:3000 tcp:3000
```

## 🎉 RÉSULTAT FINAL
Après ces 3 étapes :
- ✅ Votre login marchera : `aa.bb@xtensus.com` / `123456`
- ✅ Les types de congé se chargeront depuis MySQL
- ✅ Vos demandes s'enregistreront en base
- ✅ "Mes demandes" affichera les vraies données

## 🧪 COMPTES DE TEST PRÊTS
| Email | Mot de passe | Status |
|-------|--------------|---------|
| `aa.bb@xtensus.com` | `123456` | ✅ Testé |
| `admin@test.com` | `password123` | ✅ Testé |

## 🆘 SI PROBLÈME
1. **Backend ne répond pas** → Lancez `mvn spring-boot:run`
2. **Script SQL erreur** → Vérifiez que la base `rh_xtensus` existe
3. **Flutter ne se connecte pas** → Vérifiez l'URL : `localhost:3000/api`

## ✅ VÉRIFICATION RAPIDE
Testez dans votre navigateur : http://localhost:3000/api/flutter/test
**Résultat attendu** : `"message": "Flutter connection OK !"`

---

## 🎯 MAINTENANT VOUS SAVEZ QUOI FAIRE !
1. **Script SQL** → phpMyAdmin
2. **Configuration Flutter** → Remplacer l'URL API  
3. **adb reverse** → Si Android Emulator
4. **Tester** → Login puis créer une demande !

**VOTRE APP SERA 100% CONNECTÉE ! 🚀**