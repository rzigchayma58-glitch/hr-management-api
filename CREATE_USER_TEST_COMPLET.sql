-- 🔧 CRÉATION UTILISATEUR DE TEST POUR XCONGES
-- Permet de tester immédiatement l'authentification et les demandes

USE rh_xtensus;

-- 1️⃣ CRÉER UN UTILISATEUR ADMIN DE TEST (si n'existe pas déjà)
INSERT IGNORE INTO users (
    id, email, password, firstName, lastName, role, 
    isActive, createdAt, updatedAt
) VALUES (
    999, 
    'admin@test.com', 
    '$2a$10$rZ8R8qBRWh.1ChP7HmV8Su7k7K9rK8pV8wM8cT9Z3jT2Xc3Vv2xMS', -- password123
    'Admin', 
    'Test', 
    'ADMIN', 
    true, 
    NOW(), 
    NOW()
);

-- 2️⃣ CRÉER UN EMPLOYÉ DE TEST
INSERT IGNORE INTO users (
    id, email, password, firstName, lastName, role, 
    isActive, createdAt, updatedAt
) VALUES (
    998, 
    'employe@test.com', 
    '$2a$10$rZ8R8qBRWh.1ChP7HmV8Su7k7K9rK8pV8wM8cT9Z3jT2Xc3Vv2xMS', -- password123
    'Jean', 
    'Dupont', 
    'EMPLOYEE', 
    true, 
    NOW(), 
    NOW()
);

-- 3️⃣ CRÉER UN MANAGER DE TEST
INSERT IGNORE INTO users (
    id, email, password, firstName, lastName, role, 
    isActive, createdAt, updatedAt
) VALUES (
    997, 
    'manager@test.com', 
    '$2a$10$rZ8R8qBRWh.1ChP7HmV8Su7k7K9rK8pV8wM8cT9Z3jT2Xc3Vv2xMS', -- password123
    'Marie', 
    'Manager', 
    'MANAGER', 
    true, 
    NOW(), 
    NOW()
);

-- 4️⃣ VÉRIFIER LES UTILISATEURS CRÉÉS
SELECT 'UTILISATEURS DE TEST CRÉÉS:' as verification;
SELECT id, email, firstName, lastName, role, isActive 
FROM users 
WHERE email IN ('admin@test.com', 'employe@test.com', 'manager@test.com')
ORDER BY id;

-- 5️⃣ MESSAGE DE CONFIRMATION
SELECT 
    '✅ UTILISATEURS PRÊTS POUR LES TESTS !' as message,
    'Utilisez admin@test.com / password123 pour tester' as login_info;

-- 6️⃣ INFORMATION IMPORTANTE SUR LES MOTS DE PASSE
SELECT 
    'MOTS DE PASSE:' as info,
    'Tous les comptes utilisent: password123' as password,
    'Hash BCrypt déjà encodé dans la base' as encryption;