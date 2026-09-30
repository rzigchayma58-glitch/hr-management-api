-- 🔍 TROUVER LA DEMANDE CRÉÉE DEPUIS FLUTTER
-- Exécutez ces requêtes une par une dans phpMyAdmin

USE rh_xtensus;

-- =====================================
-- 1. VÉRIFIER TOUTES LES TABLES DE DEMANDES
-- =====================================
SELECT 'TABLES CONTENANT DES DEMANDES:' as info;
SHOW TABLES LIKE '%demande%';
SHOW TABLES LIKE '%request%';
SHOW TABLES LIKE '%conge%';
SHOW TABLES LIKE '%leave%';

-- =====================================
-- 2. DERNIÈRES ENTRÉES DANS CHAQUE TABLE
-- =====================================

-- Table principale existante
SELECT 'DERNIÈRES DEMANDES - TABLE conge_demandes:' as info;
SELECT * FROM conge_demandes 
WHERE DATE(submitted_at) >= CURDATE() - INTERVAL 1 DAY
ORDER BY submitted_at DESC;

-- Si vous avez cette table
SELECT 'DERNIÈRES DEMANDES - TABLE leave_requests:' as info;
SELECT * FROM leave_requests 
WHERE DATE(submittedAt) >= CURDATE() - INTERVAL 1 DAY
ORDER BY submittedAt DESC;

-- Table Flutter (si créée)
SELECT 'DERNIÈRES DEMANDES - TABLE flutter_leave_requests:' as info;
SELECT * FROM flutter_leave_requests 
WHERE DATE(submittedAt) >= CURDATE() - INTERVAL 1 DAY
ORDER BY submittedAt DESC;

-- =====================================
-- 3. RECHERCHER PAR UTILISATEUR
-- =====================================

-- Vos utilisateurs de test
SELECT 'DEMANDES DE aa.bb@xtensus.com (ID=15):' as info;
SELECT cd.*, u.email 
FROM conge_demandes cd
JOIN users u ON cd.requester_id = u.id 
WHERE u.email = 'aa.bb@xtensus.com'
ORDER BY cd.submitted_at DESC;

SELECT 'DEMANDES DE chaimaa.rz@xtensus.com:' as info;
SELECT cd.*, u.email 
FROM conge_demandes cd
JOIN users u ON cd.requester_id = u.id 
WHERE u.email = 'chaimaa.rz@xtensus.com'
ORDER BY cd.submitted_at DESC;

-- =====================================
-- 4. TOUTES LES DEMANDES RÉCENTES (DERNIÈRE HEURE)
-- =====================================
SELECT 'TOUTES LES DEMANDES CRÉÉES DANS LA DERNIÈRE HEURE:' as info;
SELECT 
    cd.id,
    cd.requester_id,
    u.username,
    u.email,
    cd.start_date,
    cd.end_date,
    cd.status,
    cd.submitted_at
FROM conge_demandes cd
LEFT JOIN users u ON cd.requester_id = u.id
WHERE cd.submitted_at >= NOW() - INTERVAL 1 HOUR
ORDER BY cd.submitted_at DESC;

-- =====================================
-- 5. VÉRIFIER LES ERREURS POSSIBLES
-- =====================================

-- Demandes sans utilisateur (erreur de foreign key)
SELECT 'DEMANDES AVEC REQUESTER_ID INVALIDE:' as info;
SELECT cd.* 
FROM conge_demandes cd
LEFT JOIN users u ON cd.requester_id = u.id
WHERE u.id IS NULL;

-- Utilisateurs disponibles
SELECT 'UTILISATEURS DISPONIBLES:' as info;
SELECT id, username, email, enabled 
FROM users 
WHERE enabled = 1 OR enabled IS NULL
ORDER BY id DESC;

-- =====================================
-- 6. COMPTER TOUTES LES DEMANDES
-- =====================================
SELECT 'STATISTIQUES TABLES:' as info;

SELECT 
    'conge_demandes' as table_name,
    COUNT(*) as total_rows,
    MAX(submitted_at) as derniere_demande
FROM conge_demandes

UNION ALL

SELECT 
    'leave_requests' as table_name,
    COUNT(*) as total_rows,
    MAX(submittedAt) as derniere_demande
FROM leave_requests

UNION ALL

SELECT 
    'flutter_leave_requests' as table_name,
    COUNT(*) as total_rows,
    MAX(submittedAt) as derniere_demande
FROM flutter_leave_requests;

SELECT '🔍 SI VOUS NE TROUVEZ TOUJOURS PAS VOTRE DEMANDE, VÉRIFIEZ LES LOGS DU BACKEND !' as message;