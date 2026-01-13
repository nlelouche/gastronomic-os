-- Add 'low_carb' to the diet_lifestyle enum
ALTER TYPE public.diet_lifestyle ADD VALUE IF NOT EXISTS 'low_carb';
