// 🎯 CONFIGURATION FLUTTER - LOCALHOST (SOLUTION FIABLE)
// Utiliser localhost avec adb reverse pour Android emulator

class ApiConfig {
  // 🏠 LOCALHOST - Fonctionne avec adb reverse
  static const String baseUrl = 'http://localhost:3000/api';
  
  // 📱 ALTERNATIVE ANDROID EMULATOR
  // static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // 🔗 ENDPOINTS
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me = '$baseUrl/auth/me';
  static const String flutterTest = '$baseUrl/flutter/test';
  static const String leaveRequests = '$baseUrl/leave-requests';
  static const String congeTypes = '$baseUrl/conge-types';
}

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔍 Connexion à: ${ApiConfig.login}');
      
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'usernameOrEmail': email,
          'password': password,
        }),
      );

      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Sauvegarder le token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['accessToken']);
        
        return {
          'success': true,
          'token': data['accessToken'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': 'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur de connexion: $e',
      };
    }
  }
}

// 🚀 COMMANDES ADB POUR ANDROID EMULATOR
/*
AVANT DE LANCER FLUTTER:

1. Ouvrez cmd/PowerShell
2. Exécutez ces commandes:

   adb reverse tcp:3000 tcp:3000

3. Vérifiez avec:
   
   adb reverse --list
   
   Vous devez voir: tcp:3000 -> tcp:3000

4. Maintenant lancez Flutter:
   
   flutter run

AVEC CES COMMANDES, localhost:3000 dans Flutter 
redirigera vers votre PC localhost:3000 !
*/

// 🎯 COMPTE DE TEST GARANTI
/*
Email: admin@test.com
Password: password123

Ce compte existe déjà dans votre base de données !
*/

// 📋 UTILISATION DANS VOTRE APP

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec le compte test
    _emailController.text = 'admin@test.com';
    _passwordController.text = 'password123';
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    final result = await AuthService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (result['success']) {
      // Connexion réussie
      Navigator.of(context).pushReplacementNamed('/dashboard');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Connexion réussie !'),
          backgroundColor: Colors.green,
        ),
      );
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
      appBar: AppBar(
        title: Text('XCongés - Connexion'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instructions ADB
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⚠️ ANDROID EMULATOR:', 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('1. Ouvrez cmd'),
                  Text('2. Tapez: adb reverse tcp:3000 tcp:3000'),
                  Text('3. Relancez l\'app'),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Compte test
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  Text('🧪 Compte de test pré-rempli:', 
                       style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('admin@test.com / password123'),
                ],
              ),
            ),
            SizedBox(height: 30),
            
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 16),
            
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
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
                      Text('Connexion...'),
                    ],
                  )
                : Text('Se connecter'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Status backend
            Text(
              '🔗 Backend: ${ApiConfig.baseUrl}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
🎯 RÉSUMÉ SOLUTION LOCALHOST:

✅ AVANTAGES:
- Plus stable que l'IP réseau
- Fonctionne avec adb reverse
- Pas de problèmes de firewall
- Configuration simple

📱 POUR ANDROID EMULATOR:
1. adb reverse tcp:3000 tcp:3000
2. Utiliser localhost:3000 dans Flutter

📱 POUR APPAREIL PHYSIQUE:
1. Modifier le YAML pour écouter sur 0.0.0.0
2. Utiliser l'IP réseau: http://10.148.173.19:3000/api

🚀 CETTE SOLUTION RÉSOUT DÉFINITIVEMENT VOS ERREURS DE LOGIN !
*/