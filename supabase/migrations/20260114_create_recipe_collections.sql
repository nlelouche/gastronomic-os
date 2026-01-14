-- Migration: 20260114_create_recipe_collections.sql

-- 1. Create recipe_collections table
CREATE TABLE IF NOT EXISTS public.recipe_collections (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    owner_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT recipe_collections_pkey PRIMARY KEY (id)
);

-- 2. Create collection_items table (Junction table)
CREATE TABLE IF NOT EXISTS public.collection_items (
    collection_id uuid NOT NULL REFERENCES public.recipe_collections(id) ON DELETE CASCADE,
    recipe_id text NOT NULL, -- Assuming recipe ids are strings (text) based on previous files, referencing recipes.id ideally if UUID
    added_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT collection_items_pkey PRIMARY KEY (collection_id, recipe_id)
);

-- 3. RLS - Recipe Collections
ALTER TABLE public.recipe_collections ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own collections" ON public.recipe_collections;
CREATE POLICY "Users can view their own collections"
    ON public.recipe_collections FOR SELECT
    USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Users can insert their own collections" ON public.recipe_collections;
CREATE POLICY "Users can insert their own collections"
    ON public.recipe_collections FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Users can update their own collections" ON public.recipe_collections;
CREATE POLICY "Users can update their own collections"
    ON public.recipe_collections FOR UPDATE
    USING (auth.uid() = owner_id);

DROP POLICY IF EXISTS "Users can delete their own collections" ON public.recipe_collections;
CREATE POLICY "Users can delete their own collections"
    ON public.recipe_collections FOR DELETE
    USING (auth.uid() = owner_id);

-- 4. RLS - Collection Items
ALTER TABLE public.collection_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view items in their collections" ON public.collection_items;
CREATE POLICY "Users can view items in their collections"
    ON public.collection_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.recipe_collections rc
            WHERE rc.id = collection_items.collection_id
            AND rc.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can add items to their collections" ON public.collection_items;
CREATE POLICY "Users can add items to their collections"
    ON public.collection_items FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.recipe_collections rc
            WHERE rc.id = collection_id -- Fixed Reference
            AND rc.owner_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Users can remove items from their collections" ON public.collection_items;
CREATE POLICY "Users can remove items from their collections"
    ON public.collection_items FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.recipe_collections rc
            WHERE rc.id = collection_items.collection_id
            AND rc.owner_id = auth.uid()
        )
    );
