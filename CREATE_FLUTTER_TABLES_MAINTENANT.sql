-- 🎯 TABLES FLUTTER SPÉCIALISÉES - EXÉCUTER MAINTENANT
-- Base de données: leaveapp (ou rh_xtensus selon votre configuration)

USE rh_xtensus;

-- =====================================
-- 1. TABLE FLUTTER_LEAVE_TYPES (NOUVELLE)
-- =====================================
CREATE TABLE IF NOT EXISTS flutter_leave_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    max_days INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insérer les types pour Flutter
INSERT IGNORE INTO flutter_leave_types (id, name, description, max_days) VALUES 
(1, 'Congé annuel', 'Congé payé annuel', 30),
(2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90),
(3, 'Congé exceptionnel', 'Congé pour événement familial', 5),
(4, 'Autorisation d\'absence', 'Absence de courte durée', 1);

-- =====================================
-- 2. TABLE FLUTTER_LEAVE_REQUESTS (NOUVELLE)
-- =====================================
CREATE TABLE IF NOT EXISTS flutter_leave_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    -- Relations utilisateur
    requesterId BIGINT NOT NULL,
    approverId BIGINT NULL,
    -- Type de congé
    leaveTypeId BIGINT NOT NULL,
    -- Dates et durée
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    startTime TIME NULL,
    endTime TIME NULL,
    requestedDays DECIMAL(5,2) DEFAULT 1.0,
    -- Détails
    reason TEXT,
    -- Status et suivi
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') DEFAULT 'PENDING',
    submittedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    decisionAt TIMESTAMP NULL,
    decisionComment TEXT,
    -- Métadonnées Flutter
    created_from VARCHAR(50) DEFAULT 'FLUTTER_APP',
    device_info TEXT,
    app_version VARCHAR(20) DEFAULT '1.0.0',
    -- Index
    INDEX idx_requester (requesterId),
    INDEX idx_approver (approverId),
    INDEX idx_leave_type (leaveTypeId),
    INDEX idx_status (status),
    INDEX idx_submitted (submittedAt),
    -- Foreign keys vers tables existantes
    FOREIGN KEY (requesterId) REFERENCES users(id),
    FOREIGN KEY (approverId) REFERENCES users(id),
    FOREIGN KEY (leaveTypeId) REFERENCES flutter_leave_types(id)
);

-- =====================================
-- 3. VUE POUR FLUTTER (REQUÊTES SIMPLIFIÉES)
-- =====================================
CREATE OR REPLACE VIEW flutter_leave_requests_view AS
SELECT 
    flr.id,
    flr.requesterId,
    CONCAT(req.firstName, ' ', req.lastName) as requesterName,
    req.email as requesterEmail,
    flr.approverId,
    CONCAT(app.firstName, ' ', app.lastName) as approverName,
    app.email as approverEmail,
    flr.leaveTypeId,
    flt.name as leaveTypeName,
    flt.description as leaveTypeDescription,
    flr.startDate,
    flr.endDate,
    flr.startTime,
    flr.endTime,
    flr.requestedDays,
    flr.reason,
    flr.status,
    flr.submittedAt,
    flr.decisionAt,
    flr.decisionComment,
    flr.created_from,
    flr.app_version
FROM flutter_leave_requests flr
JOIN users req ON flr.requesterId = req.id
LEFT JOIN users app ON flr.approverId = app.id  
JOIN flutter_leave_types flt ON flr.leaveTypeId = flt.id
ORDER BY flr.submittedAt DESC;

-- =====================================
-- 4. DEMANDES DE TEST AVEC VOS UTILISATEURS
-- =====================================
-- Créer quelques demandes de test pour que "Mes demandes" affiche du contenu
INSERT IGNORE INTO flutter_leave_requests (
    leaveTypeId, requesterId, startDate, endDate, requestedDays, reason, status, created_from
)
SELECT 
    1 as leaveTypeId, -- Congé annuel
    u.id as requesterId,
    DATE_ADD(CURDATE(), INTERVAL 7 DAY) as startDate,
    DATE_ADD(CURDATE(), INTERVAL 9 DAY) as endDate,
    3.0 as requestedDays,
    CONCAT('Demande test pour ', u.firstName) as reason,
    'PENDING' as status,
    'MYSQL_SETUP' as created_from
FROM users u 
WHERE u.email IN ('aa.bb@xtensus.com', 'admin@test.com', 'chaimaa.rz@xtensus.com')
LIMIT 3;

-- =====================================
-- 5. VÉRIFICATIONS
-- =====================================
SELECT 'TABLES FLUTTER CRÉÉES' as status;
SELECT COUNT(*) as types_count FROM flutter_leave_types;
SELECT COUNT(*) as requests_count FROM flutter_leave_requests;

-- Afficher les types de congé
SELECT * FROM flutter_leave_types;

-- Afficher les demandes créées
SELECT * FROM flutter_leave_requests_view LIMIT 5;

SELECT '🎉 FLUTTER TABLES PRÊTES ! Maintenant connectons votre app !' as final_message;