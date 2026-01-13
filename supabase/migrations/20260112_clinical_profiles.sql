-- 1. Create ENUM for "Lifestyle" (Primary Diet)
-- Defines the base macronutrient distribution and ethical choices.
CREATE TYPE public.diet_lifestyle AS ENUM (
    'omnivore',
    'vegetarian',
    'vegan',
    'pescatarian',
    'keto',
    'paleo',
    'whole30',
    'mediterranean',
    'high_performance',
    'low_carb'
);

-- 2. Create ENUM for "Medical Conditions" (Clinical Overlays)
-- These are "Zero Tolerance" safety filters.
CREATE TYPE public.medical_condition AS ENUM (
    'aplv',             -- Cow's Milk Protein Allergy
    'egg_allergy',
    'soy_allergy',
    'nut_allergy',
    'shellfish_allergy',
    'celiac',           -- Gluten
    'low_fodmap',       -- IBS
    'histamine',        -- Histamine Intolerance (SIGHI)
    'diabetes',         -- Glycemic Control
    'renal'             -- Kidney Disease (Potassium/Phosphorus)
);

-- 3. Create or Update family_members table
CREATE TABLE IF NOT EXISTS public.family_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'Member', -- Dad, Mom, etc.
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add new columns safely
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'family_members' AND column_name = 'primary_diet') THEN
        ALTER TABLE public.family_members ADD COLUMN primary_diet public.diet_lifestyle NOT NULL DEFAULT 'omnivore';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'family_members' AND column_name = 'medical_conditions') THEN
        ALTER TABLE public.family_members ADD COLUMN medical_conditions public.medical_condition[] DEFAULT '{}';
    END IF;
END $$;

-- 4. Comment on columns for documentation
COMMENT ON COLUMN public.family_members.primary_diet IS 'Base lifestyle choice (e.g. Keto, Vegan). Defines preferences.';
COMMENT ON COLUMN public.family_members.medical_conditions IS 'Strict medical exclusions. These override any lifestyle choice.';
