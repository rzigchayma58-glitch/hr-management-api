# HR Management API - Documentation d'Intégration Frontend

## Vue d'ensemble

API REST Spring Boot pour la gestion des ressources humaines avec authentification JWT et gestion des congés.

**URL de base**: `http://localhost:8080`  
**Version**: 0.0.1-SNAPSHOT  
**Authentification**: JWT Bearer Token  
**Framework**: Spring Boot 3.4.1 avec Java 17  

## Configuration CORS

L'API accepte les requêtes depuis :
- `http://localhost:4200`
- `http://127.0.0.1:4200`

## Authentification

### 1. Connexion
```http
POST /api/auth/login
Content-Type: application/json

{
  "usernameOrEmail": "string",
  "password": "string"
}
```

**Réponse (200)**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIs...",
  "tokenType": "Bearer",
  "expiresIn": 3600000,
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "role": "EMPLOYEE",
    "status": "ACTIVE",
    "enabled": true,
    "department": {
      "id": 1,
      "name": "IT"
    },
    "position": {
      "id": 1,
      "name": "Developer"
    },
    "manager": {
      "id": 2,
      "firstName": "Jane",
      "lastName": "Manager"
    }
  }
}
```

### 2. Informations utilisateur connecté
```http
GET /api/auth/me
Authorization: Bearer {token}
```

**En-têtes requis pour toutes les requêtes authentifiées**:
```http
Authorization: Bearer {accessToken}
Content-Type: application/json
```

## Rôles et Permissions

### Types de rôles :
- `EMPLOYEE` : Employé standard
- `MANAGER` : Manager d'équipe  
- `HR` : Ressources humaines
- `ADMIN` : Administrateur système

### Permissions par rôle :

| Endpoint | EMPLOYEE | MANAGER | HR | ADMIN |
|----------|----------|---------|----|----- |
| Créer demande congé | ✅ | ✅ | ✅ | ✅ |
| Voir ses demandes | ✅ | ✅ | ✅ | ✅ |
| Approuver demandes | ❌ | ✅ | ✅ | ✅ |
| Gérer utilisateurs | ❌ | ❌ | ✅ | ✅ |
| Gérer départements | ❌ | ❌ | ✅ | ✅ |

## Endpoints Principaux

## 1. Gestion des Demandes de Congé

### Créer une demande
```http
POST /api/leave-requests
POST /api/conge-demandes
Authorization: Bearer {token}

{
  "leaveTypeId": 1,
  "startDate": "2024-12-01",
  "endDate": "2024-12-05",
  "reason": "Vacances familiales",
  "medicalCertificateRequired": false
}
```

### Lister toutes les demandes (HR/Admin)
```http
GET /api/leave-requests
Authorization: Bearer {token}
```

### Demandes d'un employé spécifique
```http
GET /api/leave-requests/requester/{userId}
Authorization: Bearer {token}
```

### Demandes à approuver (Manager/HR/Admin)
```http
GET /api/leave-requests/approver/{managerId}
Authorization: Bearer {token}
```

### Approuver une demande
```http
PATCH /api/leave-requests/{id}/approve
Authorization: Bearer {token}

{
  "comments": "Approuvé - bon voyage !"
}
```

### Rejeter une demande
```http
PATCH /api/leave-requests/{id}/reject
Authorization: Bearer {token}

{
  "comments": "Refusé - période trop chargée",
  "reason": "WORKLOAD_CONFLICT"
}
```

### Modifier une demande
```http
PUT /api/leave-requests/{id}
Authorization: Bearer {token}

{
  "startDate": "2024-12-02",
  "endDate": "2024-12-06",
  "reason": "Vacances familiales modifiées"
}
```

## 2. Gestion des Utilisateurs (HR/Admin)

### Créer un utilisateur
```http
POST /api/users
Authorization: Bearer {token}

{
  "username": "newuser",
  "email": "newuser@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+33123456789",
  "hireDate": "2024-01-15",
  "role": "EMPLOYEE",
  "managerId": 2,
  "departmentId": 1,
  "positionId": 1
}
```

### Lister tous les utilisateurs
```http
GET /api/users
Authorization: Bearer {token}
```

### Utilisateur par ID
```http
GET /api/users/{id}
Authorization: Bearer {token}
```

### Utilisateurs par rôle
```http
GET /api/users/role/{role}
Authorization: Bearer {token}
```

### Équipe d'un manager
```http
GET /api/users/{managerId}/team
Authorization: Bearer {token}
```

## 3. Gestion des Départements

### Créer un département
```http
POST /api/departments
POST /api/departements
Authorization: Bearer {token}

{
  "name": "Développement",
  "description": "Équipe de développement logiciel"
}
```

### Lister départements
```http
GET /api/departments
Authorization: Bearer {token}
```

## 4. Certificats Médicaux

### Upload d'un certificat
```http
POST /api/certificats-medicaux-v2/televerser/{congeDemandeId}
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [fichier PDF/image]
```

### Télécharger un certificat
```http
GET /api/certificats-medicaux-v2/telecharger/{id}
Authorization: Bearer {token}
```

## 5. Gestion des Soldes de Congé

### Solde d'un utilisateur
```http
GET /api/leave-balances/user/{userId}
Authorization: Bearer {token}
```

**Réponse**:
```json
{
  "id": 1,
  "userId": 1,
  "leaveTypeId": 1,
  "totalDays": 25,
  "usedDays": 5,
  "remainingDays": 20,
  "year": 2024
}
```

## Codes d'Erreur et Gestion des Exceptions

### Structure de réponse d'erreur
```json
{
  "timestamp": "2024-12-01T10:30:00",
  "status": 400,
  "error": "Bad Request",
  "message": "Validation failed",
  "path": "/api/leave-requests",
  "details": {
    "field": "startDate",
    "rejectedValue": "invalid-date",
    "message": "Date de début invalide"
  }
}
```

### Codes d'erreur principaux

| Code | Signification | Exemple |
|------|---------------|---------|
| 400 | Bad Request | Données invalides |
| 401 | Unauthorized | Token invalide/expiré |
| 403 | Forbidden | Permissions insuffisantes |
| 404 | Not Found | Ressource inexistante |
| 409 | Conflict | Doublon (email existant) |
| 500 | Internal Server Error | Erreur serveur |

### Erreurs spécifiques métier

- `InvalidCredentialsException` : Identifiants incorrects
- `AccountDisabledException` : Compte désactivé
- `InsufficientLeaveBalanceException` : Solde congé insuffisant
- `LeaveRequestNotFoundException` : Demande introuvable
- `UnauthorizedApproverException` : Pas d'autorisation d'approbation

## Types de Données Importants

### Énumérations

**RoleType**:
```typescript
type RoleType = 'EMPLOYEE' | 'MANAGER' | 'HR' | 'ADMIN';
```

**UserStatus**:
```typescript
type UserStatus = 'ACTIVE' | 'INACTIVE' | 'SUSPENDED';
```

**LeaveRequestStatus** (déduit du code):
```typescript
type LeaveRequestStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED';
```

### Format des dates
- Toutes les dates sont au format ISO 8601 : `YYYY-MM-DD`
- Les timestamps : `YYYY-MM-DDTHH:mm:ss`

### Pagination
Pour les endpoints retournant des listes, vérifiez si la pagination est implémentée (non visible dans le code actuel).

## Endpoints Alternatifs Français

L'API propose des endpoints en français pour certains modules :

| Anglais | Français |
|---------|----------|
| `/api/leave-requests` | `/api/conge-demandes` |
| `/api/departments` | `/api/departements` |
| `/api/medical-documents` | `/api/certificats-medicaux` |

**Note**: Les endpoints français peuvent avoir des différences dans les noms des propriétés JSON.

## Configuration Recommandée pour le Frontend

### Intercepteur HTTP (exemple Angular)
```typescript
// Ajout automatique du token
headers = headers.set('Authorization', `Bearer ${token}`);

// Gestion globale des erreurs
if (error.status === 401) {
  // Rediriger vers login
  this.router.navigate(['/login']);
}
```

### Variables d'environnement recommandées
```typescript
export const environment = {
  apiUrl: 'http://localhost:8080/api',
  tokenExpiration: 3600000, // 1 heure
  corsEnabled: true
};
```

## Contact et Support

Pour toute question sur l'intégration, contactez l'équipe backend ou consultez les logs d'erreur détaillés dans les réponses HTTP.

**Date de dernière mise à jour**: Décembre 2024