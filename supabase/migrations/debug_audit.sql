-- Inspection Script
-- 1. Check Tags for 'Steak & Eggs'
SELECT id, title, tags FROM recipes WHERE title LIKE '%Steak%';

-- 2. Check Snapshot content for 'Tofu' (Recipe ID from screenshot: c088a212...)
-- We'll search by title to be sure
SELECT r.title, s.full_structure 
FROM recipes r
JOIN recipe_snapshots s ON r.id = s.recipe_id
WHERE r.title LIKE '%Tofu%';
