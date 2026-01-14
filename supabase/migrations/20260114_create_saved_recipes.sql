-- Migration: Create Saved Recipes (Bookmarks)
-- Date: 2026-01-14
-- Description: Allows users to save/bookmark recipes.

create table if not exists public.saved_recipes (
  id uuid not null default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  recipe_id uuid not null references public.recipes(id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint saved_recipes_pkey primary key (id),
  constraint unique_user_recipe unique (user_id, recipe_id)
);

-- Enable RLS
alter table public.saved_recipes enable row level security;

-- Policies
create policy "Users can view their own saved recipes" 
on public.saved_recipes for select 
using (auth.uid() = user_id);

create policy "Users can save recipes (insert)" 
on public.saved_recipes for insert 
with check (auth.uid() = user_id);

create policy "Users can unsave recipes (delete)" 
on public.saved_recipes for delete 
using (auth.uid() = user_id);
