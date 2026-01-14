-- Migration: Add missing RLS DELETE policies
-- Date: 2026-01-14
-- Description: Allow users to delete their own recipes, commits, and snapshots.

-- 1. Recipes Policy
-- Users can delete their own recipes
CREATE POLICY "Users can delete own recipes" 
ON public.recipes 
FOR DELETE 
USING (auth.uid() = author_id);

-- 2. Commits Policy
-- Users can delete their own commits (author_id check is fastest)
CREATE POLICY "Users can delete own commits" 
ON public.commits 
FOR DELETE 
USING (auth.uid() = author_id);

-- 3. Snapshots Policy
-- Users can delete snapshots belonging to their recipes
-- Snapshots don't have author_id directly, so check via recipe_id
CREATE POLICY "Users can delete snapshots for own recipes" 
ON public.recipe_snapshots 
FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM public.recipes
    WHERE id = recipe_snapshots.recipe_id
    AND author_id = auth.uid()
  )
);
