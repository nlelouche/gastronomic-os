-- Fix Social Feed: Populate created_by_member_id for existing recipes
-- This migration assigns recipes to their author's family members

-- 1. For recipes without created_by_member_id, assign to first family member of the author
UPDATE public.recipes r
SET created_by_member_id = (
    SELECT fm.id 
    FROM public.family_members fm 
    WHERE fm.user_id = r.author_id 
    ORDER BY fm.created_at ASC 
    LIMIT 1
)
WHERE r.created_by_member_id IS NULL
AND EXISTS (
    SELECT 1 FROM public.family_members fm WHERE fm.user_id = r.author_id
);
