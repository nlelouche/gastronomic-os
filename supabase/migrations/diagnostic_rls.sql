-- DIAGNOSTIC SCRIPT: Verify RLS Policies and Data State
-- Run this in Supabase SQL Editor to diagnose the issue

-- 1. Verify the INSERT policy exists for recipe_snapshots
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'recipe_snapshots';

-- Expected output: Should show TWO policies:
-- - "Snapshots viewable if recipe is viewable." (SELECT)
-- - "Users can create snapshots for own recipes." (INSERT)

-- 2. Check current authentication state
SELECT 
    auth.uid() as current_user_id,
    auth.email() as current_user_email;

-- Expected: Should return your user ID, NOT null

-- 3. Count existing recipes and snapshots
SELECT 
    (SELECT COUNT(*) FROM public.recipes) as total_recipes,
    (SELECT COUNT(*) FROM public.commits) as total_commits,
    (SELECT COUNT(*) FROM public.recipe_snapshots) as total_snapshots;

-- 4. Find recipes WITHOUT snapshots (the "hollow" ones)
SELECT 
    r.id,
    r.title,
    r.author_id,
    r.created_at,
    CASE 
        WHEN EXISTS (SELECT 1 FROM recipe_snapshots WHERE recipe_id = r.id) 
        THEN 'HAS SNAPSHOT' 
        ELSE 'MISSING SNAPSHOT' 
    END as status
FROM public.recipes r
ORDER BY r.created_at DESC
LIMIT 20;

-- 5. Check if profiles exist for recipe authors
SELECT 
    r.title,
    r.author_id,
    p.display_name
FROM public.recipes r
LEFT JOIN public.profiles p ON p.id = r.author_id
LIMIT 10;
