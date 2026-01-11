-- Migration: Add tags column to recipes table
-- Problem: Tags were being parsed from JSON but not stored in database
-- Solution: Add tags column as JSONB array

ALTER TABLE public.recipes
ADD COLUMN tags text[] DEFAULT '{}';

-- Optional: Create GIN index for fast tag lookups
CREATE INDEX idx_recipes_tags ON public.recipes USING GIN (tags);

-- Verify
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'recipes' AND column_name = 'tags';
