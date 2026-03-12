-- Affiche les contraintes FK des tables cine_pass (pour vérifier les noms en base)
SELECT
  c.conrelid::regclass AS table_name,
  c.conname AS constraint_name
FROM pg_constraint c
JOIN pg_class t ON t.oid = c.conrelid
WHERE c.contype = 'f'
  AND t.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
  AND t.relname LIKE 'cine_pass%'
ORDER BY t.relname, c.conname;
