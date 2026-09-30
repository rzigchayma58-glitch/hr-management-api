# 🔍 DEBUG FLUTTER CONNECTION - SOLUTION DÉFINITIVE

## ÉTAPE 1: VÉRIFIER LE BACKEND (OBLIGATOIRE)

### Test Backend Actuel:
```bash
# Dans votre navigateur ou Postman, tester cette URL:
http://localhost:3000/api/flutter/test

# Résultat attendu: {"message":"Flutter connection OK !","port":"8081","timestamp":"..."}
```

### Si ça ne marche pas:
```bash
# Vérifier si le backend tourne:
curl http://localhost:3000/api/flutter/test
# OU dans votre navigateur: http://localhost:3000/api/flutter/test
```

## ÉTAPE 2: TESTER L'ENDPOINT REGISTER DIRECTEMENT

### Test avec Postman ou curl:
```bash
POST http://localhost:3000/api/auth/register
Content-Type: application/json

{
  "email": "debug@test.com",
  "password": "123456",
  "role": "Employee",
  "firstName": "Debug",
  "lastName": "User"
}

# Si ça marche ici, le problème vient de Flutter
# Si ça ne marche pas, le problème vient du backend
```

## ÉTAPE 3: FORCER LA CONFIGURATION FLUTTER

### Dans votre app Flutter, remplacez TEMPORAIREMENT votre URL par:

```dart
// CONFIGURATION TEMPORAIRE DE DEBUG
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000/api';  // Android Emulator
  // static const String baseUrl = 'http://192.168.1.X:3000/api';  // Votre IP locale
}
```

### Alternative - IP locale (plus fiable):
1. Trouvez votre IP locale: `ipconfig` dans cmd
2. Remplacez dans Flutter: `http://[VOTRE_IP]:3000/api`
3. Exemple: `http://192.168.1.100:3000/api`

## ÉTAPE 4: NETTOYER LE CACHE FLUTTER

```bash
flutter clean
flutter pub get
flutter run --no-cache
```

## ÉTAPE 5: LOGS DE DEBUG

### Ajouter des logs dans votre service Flutter:
```dart
Future<void> register(Map<String, dynamic> data) async {
  print('🔍 DEBUG - URL utilisée: $baseUrl/auth/register');
  print('🔍 DEBUG - Données envoyées: $data');
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    print('🔍 DEBUG - Status Code: ${response.statusCode}');
    print('🔍 DEBUG - Response Body: ${response.body}');
    
    // Reste de votre code...
  } catch (e) {
    print('🔍 DEBUG - Erreur réseau: $e');
  }
}
```

## SOLUTION RAPIDE - TEST DIRECT

### Testez avec votre IP locale au lieu de 10.0.2.2:

1. **Trouvez votre IP:**
   ```cmd
   ipconfig
   ```

2. **Dans Flutter, utilisez:**
   ```dart
   static const String baseUrl = 'http://[VOTRE_IP]:3000/api';
   ```

3. **Exemple concret:**
   ```dart
   static const String baseUrl = 'http://192.168.1.100:3000/api';
   ```

Cette méthode évite complètement les problèmes d'émulateur !

## 🎯 PROCHAINES ÉTAPES

1. **Tester le backend** dans le navigateur: `http://localhost:3000/api/flutter/test`
2. **Si ça marche**: Utiliser votre IP locale dans Flutter
3. **Si ça ne marche pas**: Redémarrer le backend
4. **Ajouter les logs** pour voir exactement quelle URL Flutter utilise

**Dites-moi le résultat du test dans le navigateur, et on résoudra ça définitivement !**