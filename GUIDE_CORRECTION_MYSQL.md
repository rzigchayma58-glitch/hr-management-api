# 🔧 GUIDE DE CORRECTION MYSQL POUR XCONGES

## 🎯 PROBLÈME IDENTIFIÉ

Votre backend Spring Boot cherche les types de congé dans la table `leave_types`, mais ils sont dans `conge_types`.

**Erreur:** `"Leave type not found with id: 1"`

## 🚀 SOLUTION COMPLÈTE

### 1. Exécuter le script SQL

Ouvrez votre client MySQL (phpMyAdmin, MySQL Workbench, ou ligne de commande) et exécutez :

```sql
-- Charger le fichier CORRIGER_BASE_MYSQL_COMPLETE.sql
SOURCE CORRIGER_BASE_MYSQL_COMPLETE.sql;
```

Ou copiez-collez le contenu du fichier `CORRIGER_BASE_MYSQL_COMPLETE.sql`

### 2. Vérifier que tout est correct

Après exécution, vous devriez voir :

```sql
-- Types de congé créés
SELECT * FROM leave_types;
-- Résultat attendu:
-- +----+-------------------------+------------------------------------------+-----------+
-- | id | name                    | description                              | max_days  |
-- +----+-------------------------+------------------------------------------+-----------+
-- |  1 | Congé annuel           | Congé payé annuel                        |        30 |
-- |  2 | Congé maladie          | Congé pour maladie avec certificat       |        90 |
-- |  3 | Congé exceptionnel     | Congé pour événement familial           |         5 |
-- |  4 | Autorisation d'absence | Absence de courte durée sans décompte   |         1 |
-- +----+-------------------------+------------------------------------------+-----------+

-- Structure corrigée de conge_demandes
DESCRIBE conge_demandes;

-- Soldes créés pour les utilisateurs
SELECT u.firstName, u.lastName, lt.name, lb.totalDays, lb.remainingDays 
FROM leave_balances lb
JOIN users u ON lb.userId = u.id 
JOIN leave_types lt ON lb.leaveTypeId = lt.id;
```

### 3. Relancer le test Flutter

```bash
dart test_create_leave_request.dart
```

**Résultat attendu :**
```
✅ Demande créée avec succès !
ID: 1
Status: PENDING
Dates: 2026-09-29 -> 2026-10-01
```

### 4. Vérifier dans MySQL

```sql
-- Voir les demandes créées
SELECT cd.*, lt.name as type_conge, u.firstName, u.lastName 
FROM conge_demandes cd 
JOIN leave_types lt ON cd.leaveTypeId = lt.id 
JOIN users u ON cd.requesterId = u.id 
ORDER BY cd.submittedAt DESC;
```

## ✅ APRÈS CORRECTION

### Votre base MySQL aura :

1. **Table `leave_types`** avec les types de congé standard
2. **Table `conge_demandes`** avec toutes les colonnes nécessaires
3. **Table `leave_balances`** pour gérer les soldes de congés
4. **Contraintes foreign key** pour la cohérence des données
5. **Données de test** pour vérifier le bon fonctionnement

### Votre app Flutter pourra :

- ✅ Récupérer les types de congé depuis la BD
- ✅ Créer des demandes qui se sauvent en MySQL
- ✅ Afficher l'historique des demandes
- ✅ Gérer les soldes de congés
- ✅ Permettre l'approbation par les managers

## 🎉 RÉSULTAT FINAL

Après cette correction, quand vous créerez une demande depuis votre app Flutter :

1. **Frontend Flutter** → Saisie du formulaire
2. **Backend Spring Boot** → Validation et traitement  
3. **Base MySQL** → Sauvegarde dans `conge_demandes`
4. **Retour à Flutter** → Confirmation et rafraîchissement

**Votre système sera complètement opérationnel ! 🚀**

## 🔧 DÉPANNAGE

### Si vous avez encore des erreurs :

1. **Vérifier que le backend est démarré :**
   ```bash
   curl http://localhost:3000/api/flutter/test
   ```

2. **Vérifier les logs Spring Boot :**
   Regarder la console pour voir les erreurs SQL

3. **Tester la connectivité base :**
   ```sql
   SHOW TABLES LIKE '%leave%';
   SHOW TABLES LIKE '%conge%';
   ```

4. **Relancer le backend après la correction :**
   Redémarrer Spring Boot pour qu'il reprenne les nouvelles tables

### Ports utilisés :
- **Backend Spring Boot :** Port 3000 (configuré dans application.yml)
- **Flutter (IP locale) :** http://10.148.173.19:3000/api
- **MySQL :** Port 3306 (localhost)

**Cette solution corrige définitivement tous les problèmes d'intégration ! 🎯**