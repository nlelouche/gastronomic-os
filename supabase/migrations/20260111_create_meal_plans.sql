create table if not exists public.meal_plans (
  id uuid not null default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  recipe_id uuid not null references public.recipes(id) on delete cascade,
  scheduled_date date not null,
  meal_type text check (meal_type in ('Breakfast', 'Lunch', 'Dinner', 'Snack', 'Other')),
  created_at timestamptz not null default now(),
  constraint meal_plans_pkey primary key (id)
);

alter table public.meal_plans enable row level security;

create policy "Users can view their own meal plans" on public.meal_plans
  for select using (auth.uid() = user_id);

create policy "Users can insert their own meal plans" on public.meal_plans
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own meal plans" on public.meal_plans
  for update using (auth.uid() = user_id);

create policy "Users can delete their own meal plans" on public.meal_plans
  for delete using (auth.uid() = user_id);

-- Index for querying plans by date range
create index if not exists idx_meal_plans_date 
  on public.meal_plans(user_id, scheduled_date);
