-- 🚨 CORRECTION URGENTE - TYPES DE CONGÉ MANQUANTS
-- Exécutez ceci dans votre base MySQL leaveapp/rh_xtensus

-- 1. Vérifier quelle base vous utilisez
USE rh_xtensus;  -- ou USE leaveapp; selon votre configuration

-- 2. Vérifier la table conge_types existante
SELECT * FROM conge_types;

-- 3. Insérer les IDs manquants si nécessaire
INSERT IGNORE INTO conge_types (id, nom, description, duree_maximale, actif) VALUES 
(1, 'Congé annuel', 'Congé payé annuel', 30, 1),
(2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90, 1),
(3, 'Congé exceptionnel', 'Congé pour événement familial', 5, 1),
(4, 'Autorisation d\'absence', 'Absence de courte durée', 1, 1);

-- 4. Vérifier que les IDs 1,2,3,4 existent maintenant
SELECT id, nom, actif FROM conge_types WHERE id IN (1, 2, 3, 4);

-- 5. Si la table s'appelle leave_types (pas conge_types), utilisez ceci :
-- INSERT IGNORE INTO leave_types (id, name, description, max_days, is_active) VALUES 
-- (1, 'Congé annuel', 'Congé payé annuel', 30, 1),
-- (2, 'Congé maladie', 'Congé pour maladie avec certificat médical', 90, 1),
-- (3, 'Congé exceptionnel', 'Congé pour événement familial', 5, 1),
-- (4, 'Autorisation d\'absence', 'Absence de courte durée', 1, 1);

-- 6. Test final
SELECT 'Types de congé prêts !' as message, COUNT(*) as nombre_types FROM conge_types WHERE actif = 1;