-- Debug: Check if current user has family members
-- Run this in Supabase SQL Editor to see if the user has family configured

-- 1. Check current user ID
SELECT auth.uid() as current_user_id;

-- 2. Check family members for current user
SELECT id, name, user_id, created_at 
FROM public.family_members 
WHERE user_id = auth.uid()
ORDER BY created_at ASC;

-- 3. Check recent recipes and their chef assignment
SELECT 
    r.id,
    r.title,
    r.author_id,
    r.created_by_member_id,
    fm.name as chef_name,
    r.created_at
FROM public.recipes r
LEFT JOIN public.family_members fm ON r.created_by_member_id = fm.id
WHERE r.author_id = auth.uid()
ORDER BY r.created_at DESC
LIMIT 10;
