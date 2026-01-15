-- 1. Create Storage Bucket (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types) 
VALUES ('recipe_images', 'recipe_images', true, 5242880, ARRAY['image/jpg', 'image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO UPDATE SET public = true;

-- 2. Storage Policies (Robust)
-- Allow Public Read
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'recipe_images');

-- Allow Authenticated Upload
CREATE POLICY "Authenticated Upload" ON storage.objects FOR INSERT WITH CHECK (
  bucket_id = 'recipe_images' AND 
  auth.role() = 'authenticated'
);

-- Allow Owners to Delete
CREATE POLICY "Owner Delete" ON storage.objects FOR DELETE USING (
  bucket_id = 'recipe_images' AND 
  auth.uid() = owner
);

-- 3. Fix Recipe Reviews Reference
-- If 'profiles' join is failing (causing 'Failed to load reviews'), ensure foreign key or relationship exists.
-- But standard PostgREST should infer it if FK exists.
-- Let's check if the 'recipe_reviews' table is actually referencing profiles or if we need to be explicit.
-- The previous migration referenced auth.users. 
-- If the query in Dart joins 'profiles', there MUST be a FK from recipe_reviews.user_id to profiles.id OR profiles.id is same as auth.users.id.

-- Explicitly add FK to profiles if it helps PostgREST auto-detection (optional but good practice)
-- ALTER TABLE public.recipe_reviews ADD CONSTRAINT fk_reviews_profile FOREIGN KEY (user_id) REFERENCES public.profiles(id);

-- 4. Grant Permissions (just in case)
GRANT ALL ON TABLE public.recipe_reviews TO authenticated;
GRANT ALL ON TABLE public.cook_proofs TO authenticated;
GRANT ALL ON TABLE public.recipe_reviews TO service_role;
GRANT ALL ON TABLE public.cook_proofs TO service_role;
