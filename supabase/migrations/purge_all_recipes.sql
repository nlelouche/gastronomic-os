-- COMPLETE DATABASE PURGE
-- WARNING: This will delete ALL recipe data for ALL users

-- 1. Delete all snapshots first (foreign key dependency on commits)
DELETE FROM recipe_snapshots;

-- 2. Delete all commits (foreign key dependency on recipes)
DELETE FROM commits;

-- 3. Delete all recipes
DELETE FROM recipes;

-- 4. Verify cleanup
SELECT 
  (SELECT COUNT(*) FROM recipes) as recipes_count,
  (SELECT COUNT(*) FROM commits) as commits_count,
  (SELECT COUNT(*) FROM recipe_snapshots) as snapshots_count;

-- Expected result: All counts should be 0
