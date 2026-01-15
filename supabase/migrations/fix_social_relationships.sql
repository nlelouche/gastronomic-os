-- Fix relationships for PostgREST joins
-- We need explicit FKs to profiles for the join to work as expected in the Dart query:
-- .select('*, profiles(name, avatar_path)')

-- 1. Add Foreign Key to recipe_reviews
ALTER TABLE public.recipe_reviews 
ADD CONSTRAINT fk_reviews_profile 
FOREIGN KEY (user_id) REFERENCES public.profiles(id);

-- 2. Add Foreign Key to cook_proofs
ALTER TABLE public.cook_proofs 
ADD CONSTRAINT fk_proofs_profile 
FOREIGN KEY (user_id) REFERENCES public.profiles(id);

-- 3. Just in case, grant permissions again (idempotent)
GRANT ALL ON TABLE public.recipe_reviews TO authenticated;
GRANT ALL ON TABLE public.cook_proofs TO authenticated;
GRANT ALL ON TABLE public.profiles TO authenticated;
