-- Migration: Add Cover Photo Support (Simplified)
-- Date: 2026-01-14

-- 1. Add cover_photo_url column to recipes table
-- This is critical to fix the 'Could not find column' crash.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'recipes' AND column_name = 'cover_photo_url') THEN
        ALTER TABLE recipes ADD COLUMN cover_photo_url text;
    END IF;
END $$;

-- 2. Create Storage Bucket 'recipe_images'
-- This attempts to create the bucket. If it fails due to permissions, create it in the Supabase Dashboard.
INSERT INTO storage.buckets (id, name, public) 
VALUES ('recipe_images', 'recipe_images', true)
ON CONFLICT (id) DO NOTHING;

-- NOTE: Storage Policies (RLS)
-- Creating policies on 'storage.objects' often fails in the SQL Editor due to permission restrictions.
-- Please go to the Supabase Dashboard -> Storage -> Policies
-- 1. Select 'recipe_images' bucket.
-- 2. Add Policy for SELECT (Read): Enable for "All Users" (Public).
-- 3. Add Policy for INSERT (Upload): Enable for "Authenticated Users".
