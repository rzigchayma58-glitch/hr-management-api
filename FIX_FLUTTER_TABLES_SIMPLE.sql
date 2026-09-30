-- 🎯 CRÉATION TABLES FLUTTER - VERSION CORRIGÉE
-- Fonctionne avec votre structure de base existante

USE rh_xtensus;

-- Vérifier d'abord la structure de la table users
DESCRIBE users;

-- =====================================
-- 1. TABLE FLUTTER_LEAVE_TYPES (SIMPLE)
-- =====================================
CREATE TABLE IF NOT EXISTS flutter_leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    max_days INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insérer les types pour Flutter
INSERT IGNORE INTO flutter_leave_types (id, name, description, max_days) VALUES 
(1, 'Congé annuel', 'Congé payé annuel', 30),
(2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90),
(3, 'Congé exceptionnel', 'Congé pour événement familial', 5),
(4, 'Autorisation d\'absence', 'Absence de courte durée', 1);

-- =====================================
-- 2. TABLE FLUTTER_LEAVE_REQUESTS (SIMPLE)
-- =====================================
CREATE TABLE IF NOT EXISTS flutter_leave_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    requesterId BIGINT NOT NULL,
    leaveTypeId BIGINT NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    startTime TIME NULL,
    endTime TIME NULL,
    requestedDays DECIMAL(5,2) DEFAULT 1.0,
    reason TEXT,
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') DEFAULT 'PENDING',
    submittedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_from VARCHAR(50) DEFAULT 'FLUTTER_APP'
);

-- =====================================
-- 3. VUE SIMPLIFIÉE (SANS COLONNES PROBLÉMATIQUES)
-- =====================================
CREATE OR REPLACE VIEW flutter_leave_requests_simple_view AS
SELECT 
    flr.id,
    flr.requesterId,
    u.username as requesterName,
    u.email as requesterEmail,
    flr.leaveTypeId,
    flt.name as leaveTypeName,
    flr.startDate,
    flr.endDate,
    flr.startTime,
    flr.endTime,
    flr.requestedDays,
    flr.reason,
    flr.status,
    flr.submittedAt,
    flr.created_from
FROM flutter_leave_requests flr
JOIN users u ON flr.requesterId = u.id
JOIN flutter_leave_types flt ON flr.leaveTypeId = flt.id
ORDER BY flr.submittedAt DESC;

-- =====================================
-- 4. DEMANDES DE TEST AVEC UTILISATEURS EXISTANTS
-- =====================================
-- Créer une demande test avec l'utilisateur admin (ID=8)
INSERT IGNORE INTO flutter_leave_requests (
    leaveTypeId, requesterId, startDate, endDate, requestedDays, reason, status, created_from
) VALUES 
(1, 8, DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), 3.0, 'Demande test Flutter', 'PENDING', 'TEST_SETUP'),
(2, 8, DATE_ADD(CURDATE(), INTERVAL 14 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 1.0, 'Congé maladie test', 'APPROVED', 'TEST_SETUP');

-- =====================================
-- 5. VÉRIFICATIONS
-- =====================================
SELECT 'STRUCTURE TABLE USERS:' as info;
SHOW COLUMNS FROM users;

SELECT '---' as separator;

SELECT 'TABLES FLUTTER CRÉÉES:' as info;
SELECT COUNT(*) as types_count FROM flutter_leave_types;
SELECT COUNT(*) as requests_count FROM flutter_leave_requests;

SELECT '---' as separator;

SELECT 'TYPES DE CONGÉ DISPONIBLES:' as info;
SELECT * FROM flutter_leave_types;

SELECT '---' as separator;

SELECT 'DEMANDES TEST CRÉÉES:' as info;
SELECT * FROM flutter_leave_requests_simple_view;

SELECT '🎉 TABLES CRÉÉES AVEC SUCCÈS ! Flutter peut maintenant se connecter !' as final_message;