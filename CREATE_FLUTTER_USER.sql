-- Créer utilisateur pour Flutter app (azerty.aa@xtensus.com)
USE rh_xtensus;

-- Supprimer si existe
DELETE FROM users WHERE email = 'azerty.aa@xtensus.com';

-- Créer l'utilisateur avec le bon email
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
    'azerty.aa',
    'azerty.aa@xtensus.com',
    '$2a$10$VqAjQqj.qcZyQZjXUjr8T.LJAYftSzpQ4fmqJZlH3W1QUeFT6fdQS', -- password: 123456
    'Azerty',
    'AA',
    'EMPLOYEE',
    'ACTIVE',
    true,
    NOW(),
    NOW()
);

-- Vérifier que l'utilisateur a été créé
SELECT id, username, email, first_name, last_name, role, status, enabled 
FROM users 
WHERE email = 'azerty.aa@xtensus.com';