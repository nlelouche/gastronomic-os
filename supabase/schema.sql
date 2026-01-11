-- Enable necessary extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pg_jsonschema"; -- Required for JSONB validation if available on instance

-- 1. PROFILES & AUTH TRIGGER
-- Linked to auth.users to store public profile info and family usage stats
create table public.profiles (
  id uuid references auth.users not null primary key,
  display_name text,
  family_config jsonb default '{}'::jsonb, -- Stores dietary restrictions (e.g., { "father": "keto", "mother": "vegan" })
  freshness_score integer default 100, -- Gamification score
  xp_points integer default 0,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- RLS: Profiles
alter table public.profiles enable row level security;
create policy "Public profiles are viewable by everyone." on public.profiles for select using (true);
create policy "Users can insert their own profile." on public.profiles for insert with check (auth.uid() = id);
create policy "Users can update own profile." on public.profiles for update using (auth.uid() = id);

-- Trigger to create profile on signup
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, new.raw_user_meta_data->>'full_name');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 2. INVENTORY SYSTEM
create table public.inventory_items (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  name text not null,
  quantity numeric default 1.0,
  unit text default 'unit',
  expiration_date date,
  category text, -- 'meat', 'dairy', 'produce', etc.
  meta jsonb default '{}'::jsonb, -- Brand info, barcode, nutrition override
  created_at timestamp with time zone default now()
);

-- RLS: Inventory (Private to user)
alter table public.inventory_items enable row level security;
create policy "Users can view own inventory." on public.inventory_items for select using (auth.uid() = user_id);
create policy "Users can insert own inventory." on public.inventory_items for insert with check (auth.uid() = user_id);
create policy "Users can update own inventory." on public.inventory_items for update using (auth.uid() = user_id);
create policy "Users can delete own inventory." on public.inventory_items for delete using (auth.uid() = user_id);

-- 3. GIT-FOR-FOOD: RECIPE VERSIONING

-- A. Recipes (The Repositories)
create table public.recipes (
  id uuid default uuid_generate_v4() primary key,
  author_id uuid references public.profiles(id) not null,
  origin_id uuid references public.recipes(id), -- If this is a fork, points to the master
  is_fork boolean default false,
  title text not null,
  description text,
  tags text[] default '{}', -- Array of diet/restriction tags
  is_public boolean default true,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- RLS: Recipes
alter table public.recipes enable row level security;
create policy "Public recipes are viewable by everyone." on public.recipes for select using (is_public = true);
create policy "Users can view own private recipes." on public.recipes for select using (auth.uid() = author_id);
create policy "Users can create recipes." on public.recipes for insert with check (auth.uid() = author_id);
create policy "Users can update own recipes." on public.recipes for update using (auth.uid() = author_id);

-- B. Commits (The History)
create table public.commits (
  id uuid default uuid_generate_v4() primary key,
  recipe_id uuid references public.recipes(id) not null,
  parent_commit_id uuid references public.commits(id), -- Tree structure
  author_id uuid references public.profiles(id) not null,
  message text not null, -- Commit message (e.g., "Reduced salt")
  diff jsonb not null, -- The semantic delta: { "add": [...], "remove": [...], "modify": [...] }
  created_at timestamp with time zone default now()
);

-- RLS: Commits
alter table public.commits enable row level security;
create policy "Commits viewable if recipe is viewable." on public.commits for select 
  using (exists (select 1 from public.recipes where id = commits.recipe_id and (is_public = true or author_id = auth.uid())));
create policy "Users can commit to own recipes." on public.commits for insert 
  with check (exists (select 1 from public.recipes where id = recipe_id and author_id = auth.uid()));

-- C. Recipe Snapshots (The Head/Tree)
-- Optimization: Stores the fully resolved JSON of a recipe at a specific commit
-- This avoids re-calculating the diff chain on every read.
create table public.recipe_snapshots (
  commit_id uuid references public.commits(id) primary key,
  recipe_id uuid references public.recipes(id) not null,
  full_structure jsonb not null, -- { "ingredients": [...], "steps": [...] }
  created_at timestamp with time zone default now()
);

-- RLS: Snapshots
alter table public.recipe_snapshots enable row level security;
create policy "Snapshots viewable if recipe is viewable." on public.recipe_snapshots for select
  using (exists (select 1 from public.recipes where id = recipe_snapshots.recipe_id and (is_public = true or author_id = auth.uid())));
create policy "Users can create snapshots for own recipes." on public.recipe_snapshots for insert
  with check (exists (select 1 from public.recipes where id = recipe_snapshots.recipe_id and author_id = auth.uid()));


-- INDEXES for Performance (JSONB)
create index idx_inventory_meta on public.inventory_items using gin (meta);
create index idx_profiles_family_config on public.profiles using gin (family_config);
create index idx_commits_diff on public.commits using gin (diff);
create index idx_snapshots_structure on public.recipe_snapshots using gin (full_structure);
