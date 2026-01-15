-- 1. Recipe Reviews Table
CREATE TABLE IF NOT EXISTS public.recipe_reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, recipe_id)
);

-- RLS for Reviews
ALTER TABLE public.recipe_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can review public recipes" 
ON public.recipe_reviews FOR INSERT 
WITH CHECK (
    auth.uid() = user_id AND 
    EXISTS (SELECT 1 FROM public.recipes WHERE id = recipe_id AND is_public = true)
);

CREATE POLICY "Users can edit their own reviews" 
ON public.recipe_reviews FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews" 
ON public.recipe_reviews FOR DELETE 
USING (auth.uid() = user_id);

CREATE POLICY "Everyone can read reviews" 
ON public.recipe_reviews FOR SELECT 
USING (true);


-- 2. Cook Proofs Table (Photos)
CREATE TABLE IF NOT EXISTS public.cook_proofs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    caption TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS for Cook Proofs
ALTER TABLE public.cook_proofs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can upload proofs for public recipes" 
ON public.cook_proofs FOR INSERT 
WITH CHECK (
    auth.uid() = user_id AND 
    EXISTS (SELECT 1 FROM public.recipes WHERE id = recipe_id AND is_public = true)
);

CREATE POLICY "Users can delete their own proofs" 
ON public.cook_proofs FOR DELETE 
USING (auth.uid() = user_id);

CREATE POLICY "Everyone can see proofs" 
ON public.cook_proofs FOR SELECT 
USING (true);


-- 3. Family Members Enhancements
ALTER TABLE public.family_members
ADD COLUMN IF NOT EXISTS is_verified_chef BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS is_primary_cook BOOLEAN DEFAULT FALSE;


-- 4. RPC to Set Primary Cook
CREATE OR REPLACE FUNCTION public.set_primary_cook(target_member_id UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    owner_uid UUID;
BEGIN
    owner_uid := auth.uid();
    
    -- Verify the member belongs to the user
    IF NOT EXISTS (SELECT 1 FROM public.family_members WHERE id = target_member_id AND user_id = owner_uid) THEN
        RAISE EXCEPTION 'Member not found or permission denied';
    END IF;

    -- Reset all members for this user to false
    UPDATE public.family_members
    SET is_primary_cook = false
    WHERE user_id = owner_uid;

    -- Set target to true
    UPDATE public.family_members
    SET is_primary_cook = true
    WHERE id = target_member_id;
END;
$$;


-- 5. Update Feed View to include social stats
-- We drop it first to avoid dependency issues if it exists
DROP VIEW IF EXISTS public.recipe_feed_view;

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
    fm.is_verified_chef,
    
    -- Social Proof
    (SELECT count(*) FROM public.likes l WHERE l.recipe_id = r.id) AS likes_count,
    (SELECT count(*) FROM public.recipe_reviews rr WHERE rr.recipe_id = r.id) AS review_count,
    (SELECT COALESCE(AVG(rating), 0) FROM public.recipe_reviews rr WHERE rr.recipe_id = r.id) AS avg_rating,
    
    -- Context
    r.author_id AS owner_user_id
FROM 
    public.recipes r
LEFT JOIN 
    public.family_members fm ON r.created_by_member_id = fm.id
WHERE 
    r.is_public = true;
