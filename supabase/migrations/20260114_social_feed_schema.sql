-- 1. Enhance Family Members (The Chefs)
ALTER TABLE public.family_members
ADD COLUMN IF NOT EXISTS avatar_path TEXT;

-- 2. Enhance Recipes (Linking to Chef)
ALTER TABLE public.recipes
ADD COLUMN IF NOT EXISTS created_by_member_id UUID REFERENCES public.family_members(id) ON DELETE SET NULL;

-- 3. Likes System
CREATE TABLE IF NOT EXISTS public.likes (
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (user_id, recipe_id)
);

-- RLS for Likes
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can like public recipes" 
ON public.likes FOR INSERT 
WITH CHECK (
    auth.uid() = user_id AND 
    EXISTS (SELECT 1 FROM public.recipes WHERE id = recipe_id AND is_public = true)
);

CREATE POLICY "Users can unlike their likes" 
ON public.likes FOR DELETE 
USING (auth.uid() = user_id);

CREATE POLICY "Everyone can view likes" 
ON public.likes FOR SELECT 
USING (true);

-- 4. Feed View (The "Magical" Join)
-- This view aggregates everything needed for a Feed Card in one efficient query
CREATE OR REPLACE VIEW public.recipe_feed_view AS
SELECT 
    r.id AS recipe_id,
    r.title,
    r.cover_photo_url,
    r.created_at,
    r.is_public,
    r.id AS origin_id, -- For forking
    
    -- Chef Info (Family Member)
    fm.name AS chef_name,
    fm.avatar_path AS chef_avatar,
    
    -- Social Proof
    (SELECT count(*) FROM public.likes l WHERE l.recipe_id = r.id) AS likes_count,
    
    -- Context
    r.author_id AS owner_user_id
FROM 
    public.recipes r
LEFT JOIN 
    public.family_members fm ON r.created_by_member_id = fm.id
WHERE 
    r.is_public = true;
