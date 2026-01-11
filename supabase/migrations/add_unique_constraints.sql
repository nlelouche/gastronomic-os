-- Add unique constraint to prevent duplicate recipes
-- This ensures one user cannot create multiple recipes with the same title

ALTER TABLE recipes
ADD CONSTRAINT unique_recipe_per_user 
UNIQUE (author_id, title);

-- Add performance indexes for common queries

-- Index for fetching user's recipes ordered by creation date
CREATE INDEX IF NOT EXISTS idx_recipes_author_created 
ON recipes(author_id, created_at DESC);

-- Index for fetching latest snapshot for a recipe
CREATE INDEX IF NOT EXISTS idx_snapshots_recipe_created 
ON recipe_snapshots(recipe_id, created_at DESC);

-- Index for commit lookups
CREATE INDEX IF NOT EXISTS idx_commits_recipe 
ON commits(recipe_id);

-- Verify constraints
SELECT 
  conname as constraint_name,
  contype as constraint_type
FROM pg_constraint
WHERE conrelid = 'recipes'::regclass;
