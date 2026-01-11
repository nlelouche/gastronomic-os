-- Cleanup Script: Remove recipes that were created without snapshots
-- This removes the "hollow" recipes that have headers but no ingredients/steps
-- Run this BEFORE re-seeding with the fixed RLS policy

-- Step 1: Delete commits for recipes created by 'system' author
DELETE FROM public.commits
WHERE EXISTS (
  SELECT 1 FROM public.recipes
  WHERE recipes.id = commits.recipe_id
  AND EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = recipes.author_id
    AND profiles.display_name = 'system'
  )
);

-- Step 2: Delete the hollow recipes created by 'system'
DELETE FROM public.recipes
WHERE EXISTS (
  SELECT 1 FROM public.profiles
  WHERE profiles.id = recipes.author_id
  AND profiles.display_name = 'system'
);

-- Alternatively, if you want to clean ALL recipes (including user-created):
-- WARNING: This will delete EVERYTHING in the recipe system
-- DELETE FROM public.recipe_snapshots;
-- DELETE FROM public.commits;
-- DELETE FROM public.recipes;

-- Verify cleanup
SELECT COUNT(*) as remaining_recipes FROM public.recipes;
SELECT COUNT(*) as remaining_commits FROM public.commits;
SELECT COUNT(*) as remaining_snapshots FROM public.recipe_snapshots;
