-- Migration: Add missing RLS INSERT policy for recipe_snapshots
-- Problem: Recipes were being created in 'recipes' table but snapshots failed silently
-- Solution: Allow users to insert snapshots for their own recipes

-- Add INSERT policy for recipe_snapshots
create policy "Users can create snapshots for own recipes." 
  on public.recipe_snapshots 
  for insert 
  with check (
    exists (
      select 1 
      from public.recipes 
      where id = recipe_snapshots.recipe_id 
      and author_id = auth.uid()
    )
  );
