-- 🔧 SCRIPT DE CORRECTION COMPLÈTE - BASE MYSQL POUR XCONGES
-- Résout DÉFINITIVEMENT les problèmes d'intégration Flutter + Backend

USE rh_xtensus;

-- 1️⃣ SUPPRESSION ET RECRÉATION DES TABLES PROBLÉMATIQUES
DROP TABLE IF EXISTS leave_balances;
DROP TABLE IF EXISTS conge_demandes;
DROP TABLE IF EXISTS leave_types;

-- 2️⃣ CRÉATION DE LA TABLE leave_types (STANDARD SPRING BOOT)
CREATE TABLE leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    max_days INT NOT NULL DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_leave_type_name (name)
);

-- 3️⃣ INSERTION DES TYPES DE CONGÉ STANDARDS
INSERT INTO leave_types (id, name, description, max_days, is_active) VALUES
(1, 'Congé annuel', 'Congé payé annuel standard', 30, true),
(2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90, true),
(3, 'Congé exceptionnel', 'Congé pour événement familial important', 5, true),
(4, 'Autorisation d\'absence', 'Absence de courte durée sans décompte', 1, true),
(5, 'Congé maternité', 'Congé maternité/paternité', 120, true);

-- 4️⃣ RECRÉATION DE LA TABLE conge_demandes (COMPATIBLE SPRING BOOT)
CREATE TABLE conge_demandes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    requesterId BIGINT NOT NULL,
    leaveTypeId BIGINT NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    workingDays INT NOT NULL,
    reason TEXT,
    status VARCHAR(20) DEFAULT 'PENDING',
    submittedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reviewedAt TIMESTAMP NULL,
    reviewedBy BIGINT NULL,
    reviewerComments TEXT NULL,
    medicalCertificateRequired BOOLEAN DEFAULT FALSE,
    medicalCertificatePath VARCHAR(500) NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Contraintes foreign key
    FOREIGN KEY (requesterId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (leaveTypeId) REFERENCES leave_types(id) ON DELETE RESTRICT,
    FOREIGN KEY (reviewedBy) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Index pour performance
    INDEX idx_requester (requesterId),
    INDEX idx_leave_type (leaveTypeId),
    INDEX idx_status (status),
    INDEX idx_dates (startDate, endDate)
);

-- 5️⃣ CRÉATION DE LA TABLE leave_balances POUR LES SOLDES
CREATE TABLE leave_balances (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    userId BIGINT NOT NULL,
    leaveTypeId BIGINT NOT NULL,
    totalDays DECIMAL(5,2) DEFAULT 0.00,
    usedDays DECIMAL(5,2) DEFAULT 0.00,
    remainingDays DECIMAL(5,2) GENERATED ALWAYS AS (totalDays - usedDays) STORED,
    year INT NOT NULL,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Contraintes
    FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (leaveTypeId) REFERENCES leave_types(id) ON DELETE CASCADE,
    
    -- Unique par utilisateur/type/année
    UNIQUE KEY uk_user_leave_year (userId, leaveTypeId, year),
    
    -- Index
    INDEX idx_user_year (userId, year)
);

-- 6️⃣ CRÉATION DES SOLDES POUR TOUS LES UTILISATEURS EXISTANTS
INSERT INTO leave_balances (userId, leaveTypeId, totalDays, usedDays, year)
SELECT 
    u.id as userId,
    lt.id as leaveTypeId,
    CASE 
        WHEN lt.id = 1 THEN 30.00  -- Congé annuel: 30 jours
        WHEN lt.id = 2 THEN 90.00  -- Congé maladie: 90 jours
        WHEN lt.id = 3 THEN 5.00   -- Congé exceptionnel: 5 jours
        WHEN lt.id = 4 THEN 12.00  -- Autorisations: 12 jours/an
        WHEN lt.id = 5 THEN 120.00 -- Congé maternité: 120 jours
        ELSE 0.00
    END as totalDays,
    0.00 as usedDays,
    YEAR(CURDATE()) as year
FROM users u
CROSS JOIN leave_types lt
WHERE u.id IS NOT NULL AND lt.is_active = TRUE;

-- 7️⃣ MISE À JOUR DE LA TABLE conge_types SI ELLE EXISTE (POUR COMPATIBILITÉ)
UPDATE conge_types SET 
    conge_type_nom = 'Congé annuel',
    conge_type_description = 'Congé payé annuel standard',
    conge_type_duree_max = 30
WHERE conge_type_id = 1;

UPDATE conge_types SET 
    conge_type_nom = 'Congé maladie',
    conge_type_description = 'Congé pour maladie avec certificat médical',
    conge_type_duree_max = 90
WHERE conge_type_id = 2;

-- 8️⃣ VÉRIFICATIONS FINALES
SELECT '✅ TYPES DE CONGÉ CRÉÉS:' as verification;
SELECT id, name, description, max_days, is_active FROM leave_types ORDER BY id;

SELECT '✅ STRUCTURE conge_demandes:' as verification;
DESCRIBE conge_demandes;

SELECT '✅ SOLDES CRÉÉS:' as verification;
SELECT 
    u.firstName, 
    u.lastName, 
    lt.name as type_conge,
    lb.totalDays,
    lb.usedDays,
    lb.remainingDays
FROM leave_balances lb
JOIN users u ON lb.userId = u.id 
JOIN leave_types lt ON lb.leaveTypeId = lt.id
ORDER BY u.firstName, lt.id
LIMIT 10;

SELECT '🎉 CORRECTION TERMINÉE - VOTRE BASE EST PRÊTE POUR FLUTTER !' as message;

-- 9️⃣ DIAGNOSTIC COMPLET
SELECT 
    'TABLES_CONGE' as diagnostic,
    TABLE_NAME,
    TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'rh_xtensus' 
AND (TABLE_NAME LIKE '%conge%' OR TABLE_NAME LIKE '%leave%')
ORDER BY TABLE_NAME;