-- Migration: Optimize Recipes Schema (Smart Headers)
-- Date: 2026-01-12
-- Description: Adds denormalized columns for ingredients and diets to allow fast filtering.

-- 1. Add Columns
ALTER TABLE public.recipes 
ADD COLUMN IF NOT EXISTS ingredients text[] DEFAULT '{}';

ALTER TABLE public.recipes 
ADD COLUMN IF NOT EXISTS diet_tags text[] DEFAULT '{}';

-- 2. Create Sync Function
CREATE OR REPLACE FUNCTION public.sync_recipe_header_columns()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Only update if this is the "active" or latest snapshot. 
  -- Assuming the app inserts a new snapshot to update a recipe.
  -- We update the parent recipe with data from THIS snapshot.
  
  UPDATE public.recipes
  SET 
    ingredients = COALESCE(
      ARRAY(SELECT jsonb_array_elements_text(NEW.full_structure -> 'ingredients')),
      '{}'
    ),
    diet_tags = COALESCE(
      ARRAY(SELECT jsonb_array_elements_text(NEW.full_structure -> 'diets')),
      ARRAY(SELECT jsonb_array_elements_text(NEW.full_structure -> 'diet_tags')),
      '{}'
    )
  WHERE id = NEW.recipe_id;
  
  RETURN NEW;
END;
$$;

-- 3. Create Trigger
DROP TRIGGER IF EXISTS on_recipe_snapshot_created ON public.recipe_snapshots;

CREATE TRIGGER on_recipe_snapshot_created
AFTER INSERT OR UPDATE ON public.recipe_snapshots
FOR EACH ROW
EXECUTE FUNCTION public.sync_recipe_header_columns();

-- 4. Backfill Data (Execute once)
DO $$
DECLARE
  r RECORD;
BEGIN
  -- Iterate all recipes that have snapshots
  -- We take the most recent snapshot for each recipe
  FOR r IN 
    SELECT DISTINCT ON (recipe_id) *
    FROM public.recipe_snapshots
    ORDER BY recipe_id, created_at DESC
  LOOP
    UPDATE public.recipes
    SET 
        ingredients = COALESCE(ARRAY(SELECT jsonb_array_elements_text(r.full_structure -> 'ingredients')), '{}'),
        diet_tags = COALESCE(
            ARRAY(SELECT jsonb_array_elements_text(r.full_structure -> 'diets')), 
            ARRAY(SELECT jsonb_array_elements_text(r.full_structure -> 'diet_tags')), 
            '{}'
        )
    WHERE id = r.recipe_id;
  END LOOP;
END $$;
