-- Script pour créer un utilisateur de test rapidement
-- Exécuter dans MySQL Workbench ou ligne de commande

USE rh_xtensus;

-- Supprimer l'utilisateur test s'il existe
DELETE FROM users WHERE email IN ('admin@test.com', 'test@example.com');

-- Créer utilisateur admin de test  
-- Mot de passe: "password123" (hashé avec BCrypt)
INSERT INTO users (
    username, 
    email, 
    password_hash, 
    first_name, 
    last_name, 
    role, 
    status, 
    enabled,
    created_at,
    updated_at
) VALUES (
    'admin',
    'admin@test.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'Admin',
    'Test',
    'ADMIN',
    'ACTIVE',
    true,
    NOW(),
    NOW()
);

-- Créer un employé de test
INSERT INTO users (
    username, 
    email, 
    password_hash, 
    first_name, 
    last_name, 
    role, 
    status, 
    enabled,
    created_at,
    updated_at
) VALUES (
    'employee',
    'test@example.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    'John',
    'Doe',
    'EMPLOYEE',
    'ACTIVE',
    true,
    NOW(),
    NOW()
);

-- Vérifier que les utilisateurs ont été créés
SELECT id, username, email, first_name, last_name, role, status, enabled 
FROM users 
WHERE email IN ('admin@test.com', 'test@example.com');