-- 🔍 VÉRIFICATION DES DEMANDES EN BASE
-- Exécutez ces requêtes dans phpMyAdmin

-- 1. Vérifier l'utilisateur aa.bb@xtensus.com
SELECT id, firstName, lastName, email, username 
FROM users 
WHERE email = 'aa.bb@xtensus.com' OR username LIKE '%aa.bb%';

-- 2. Vérifier toutes les demandes dans leave_requests
SELECT 
    id,
    requesterId,
    leaveTypeId, 
    reason,
    status,
    startDate,
    endDate,
    submittedAt
FROM leave_requests 
ORDER BY submittedAt DESC 
LIMIT 10;

-- 3. Vérifier les demandes pour l'utilisateur 15 (aa.bb)
SELECT 
    lr.id,
    lr.requesterId,
    u.email,
    lr.leaveTypeId,
    lr.reason,
    lr.status,
    lr.submittedAt
FROM leave_requests lr
JOIN users u ON lr.requesterId = u.id
WHERE lr.requesterId = 15
ORDER BY lr.submittedAt DESC;

-- 4. Vérifier la table conge_demandes (si elle existe)
SELECT * FROM conge_demandes ORDER BY conge_demande_date DESC LIMIT 5;

-- 5. Vérifier les types de congé
SELECT id, nom, description, actif FROM conge_types WHERE actif = 1;