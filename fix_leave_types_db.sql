-- 🔧 SCRIPT DE CORRECTION - SYNCHRONISATION DES TYPES DE CONGÉ
-- Résout le problème d'incohérence entre conge_types et leave_types

USE rh_xtensus;

-- 1️⃣ VÉRIFIER LES TABLES EXISTANTES
SHOW TABLES LIKE '%type%';

-- 2️⃣ VÉRIFIER LE CONTENU DE CHAQUE TABLE
SELECT 'CONGE_TYPES' as table_name;
SELECT * FROM conge_types LIMIT 10;

SELECT 'LEAVE_TYPES' as table_name;  
SELECT * FROM leave_types LIMIT 10;

-- 3️⃣ SYNCHRONISER LES DONNÉES
-- Si leave_types est vide, copier depuis conge_types
INSERT IGNORE INTO leave_types (id, name, description, max_days, is_active, created_at, updated_at)
SELECT 
    conge_type_id as id,
    conge_type_nom as name,
    conge_type_description as description,
    COALESCE(conge_type_duree_max, 30) as max_days,
    COALESCE(conge_type_actif, true) as is_active,
    COALESCE(date_creation, NOW()) as created_at,
    COALESCE(date_modification, NOW()) as updated_at
FROM conge_types
WHERE conge_types.conge_type_id IS NOT NULL;

-- 4️⃣ CRÉER DES TYPES DE CONGÉ STANDARDS SI AUCUNE TABLE N'EXISTE
INSERT IGNORE INTO leave_types (id, name, description, max_days, is_active, created_at, updated_at) VALUES
(1, 'Congé annuel', 'Congé payé annuel standard', 30, true, NOW(), NOW()),
(2, 'Congé maladie', 'Congé pour raisons de santé', 90, true, NOW(), NOW()),
(3, 'Congé maternité', 'Congé maternité/paternité', 120, true, NOW(), NOW()),
(4, 'Congé sans solde', 'Congé exceptionnel sans rémunération', 365, true, NOW(), NOW()),
(5, 'Formation', 'Congé de formation professionnelle', 60, true, NOW(), NOW());

-- 5️⃣ ÉGALEMENT SYNCHRONISER conge_types SI NÉCESSAIRE
INSERT IGNORE INTO conge_types (conge_type_id, conge_type_nom, conge_type_description, conge_type_duree_max, conge_type_actif, date_creation, date_modification) VALUES
(1, 'Congé annuel', 'Congé payé annuel standard', 30, true, NOW(), NOW()),
(2, 'Congé maladie', 'Congé pour raisons de santé', 90, true, NOW(), NOW()),
(3, 'Congé maternité', 'Congé maternité/paternité', 120, true, NOW(), NOW()),
(4, 'Congé sans solde', 'Congé exceptionnel sans rémunération', 365, true, NOW(), NOW()),
(5, 'Formation', 'Congé de formation professionnelle', 60, true, NOW(), NOW());

-- 6️⃣ VÉRIFIER LES RÉSULTATS
SELECT 'FINAL_LEAVE_TYPES' as table_name;
SELECT id, name, description, max_days, is_active FROM leave_types ORDER BY id;

SELECT 'FINAL_CONGE_TYPES' as table_name;
SELECT conge_type_id, conge_type_nom, conge_type_description, conge_type_duree_max FROM conge_types ORDER BY conge_type_id;

-- 7️⃣ DIAGNOSTIC COMPLET DES TABLES LIÉES AUX CONGÉS
SELECT 
    TABLE_NAME,
    TABLE_COMMENT
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'rh_xtensus' 
AND (TABLE_NAME LIKE '%conge%' OR TABLE_NAME LIKE '%leave%')
ORDER BY TABLE_NAME;

-- Message de confirmation
SELECT '✅ CORRECTION TERMINÉE - Les types de congé sont maintenant synchronisés !' as message;