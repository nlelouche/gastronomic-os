-- CLEANUP SCRIPT V2: Remove ALL recipes (safer approach)
-- This script removes all recipes regardless of author
-- Run this BEFORE re-seeding

-- Step 1: Delete all snapshots first (to avoid FK constraint errors)
DELETE FROM public.recipe_snapshots;

-- Step 2: Delete all commits
DELETE FROM public.commits;

-- Step 3: Delete all recipes
DELETE FROM public.recipes;

-- Verify cleanup
SELECT 
    (SELECT COUNT(*) FROM public.recipes) as remaining_recipes,
    (SELECT COUNT(*) FROM public.commits) as remaining_commits,
    (SELECT COUNT(*) FROM public.recipe_snapshots) as remaining_snapshots;

-- Expected output: All should be 0
