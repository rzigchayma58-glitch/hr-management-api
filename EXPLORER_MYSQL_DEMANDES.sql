-- 🔍 EXPLORER LES DEMANDES DE CONGÉ DANS MYSQL
-- Exécutez ces requêtes dans phpMyAdmin pour voir vos données

USE rh_xtensus;

-- =====================================
-- 1. VOIR LA STRUCTURE DES TABLES
-- =====================================
SHOW TABLES LIKE '%conge%';
SHOW TABLES LIKE '%leave%';
SHOW TABLES LIKE '%demande%';

-- =====================================
-- 2. STRUCTURE DE LA TABLE PRINCIPALE
-- =====================================
DESCRIBE conge_demandes;
-- Ou si c'est l'autre nom :
-- DESCRIBE leave_requests;

-- =====================================
-- 3. TOUTES LES DEMANDES EXISTANTES
-- =====================================
SELECT 'TOUTES LES DEMANDES DE CONGÉ:' as info;
SELECT * FROM conge_demandes ORDER BY id DESC LIMIT 10;

-- =====================================
-- 4. DEMANDES AVEC INFORMATIONS UTILISATEUR
-- =====================================
SELECT 'DEMANDES AVEC UTILISATEURS:' as info;
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
ORDER BY cd.id DESC
LIMIT 10;

-- =====================================
-- 5. STATISTIQUES DES DEMANDES
-- =====================================
SELECT 'STATISTIQUES:' as info;

-- Nombre total de demandes
SELECT COUNT(*) as total_demandes FROM conge_demandes;

-- Demandes par statut
SELECT status, COUNT(*) as nombre 
FROM conge_demandes 
GROUP BY status;

-- Demandes par utilisateur
SELECT 
    u.username,
    u.email,
    COUNT(cd.id) as nb_demandes
FROM users u
LEFT JOIN conge_demandes cd ON u.id = cd.requester_id
GROUP BY u.id, u.username, u.email
HAVING nb_demandes > 0
ORDER BY nb_demandes DESC;

-- =====================================
-- 6. DERNIÈRES DEMANDES (PLUS RÉCENTES)
-- =====================================
SELECT 'DERNIÈRES DEMANDES:' as info;
SELECT 
    cd.id,
    u.username as utilisateur,
    cd.start_date as debut,
    cd.end_date as fin,
    cd.status,
    cd.submitted_at as cree_le
FROM conge_demandes cd
LEFT JOIN users u ON cd.requester_id = u.id
ORDER BY cd.submitted_at DESC
LIMIT 5;

-- =====================================
-- 7. DEMANDES D'UN UTILISATEUR SPÉCIFIQUE
-- =====================================
SELECT 'DEMANDES DE L\'UTILISATEUR ID=15 (aa.bb@xtensus.com):' as info;
SELECT 
    cd.*,
    u.username,
    u.email
FROM conge_demandes cd
LEFT JOIN users u ON cd.requester_id = u.id
WHERE cd.requester_id = 15
ORDER BY cd.submitted_at DESC;

-- =====================================
-- 8. VÉRIFIER LES TYPES DE CONGÉ
-- =====================================
SELECT 'TYPES DE CONGÉ DISPONIBLES:' as info;
SELECT * FROM conge_types;
-- Ou :
-- SELECT * FROM leave_types;

-- =====================================
-- 9. DEMANDES AVEC TYPES DE CONGÉ
-- =====================================
SELECT 'DEMANDES AVEC TYPES:' as info;
SELECT 
    cd.id,
    u.username as utilisateur,
    ct.nom as type_conge,
    cd.start_date,
    cd.end_date,
    cd.status
FROM conge_demandes cd
LEFT JOIN users u ON cd.requester_id = u.id
LEFT JOIN conge_types ct ON cd.leave_type_id = ct.id
ORDER BY cd.submitted_at DESC
LIMIT 10;

-- =====================================
-- 10. RECHERCHER UNE DEMANDE SPÉCIFIQUE
-- =====================================
-- Remplacez '2026-10-01' par la date qui vous intéresse
SELECT 'DEMANDES POUR UNE DATE SPÉCIFIQUE:' as info;
SELECT 
    cd.*,
    u.username,
    u.email
FROM conge_demandes cd
LEFT JOIN users u ON cd.requester_id = u.id
WHERE cd.start_date >= '2026-09-20'
ORDER BY cd.start_date;

SELECT '🎉 EXPLORATION TERMINÉE !' as final_message;