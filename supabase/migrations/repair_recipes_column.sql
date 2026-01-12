-- Ensure ingredients column exists and is of correct type
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'recipes' AND column_name = 'ingredients') THEN
        ALTER TABLE public.recipes ADD COLUMN ingredients text[] DEFAULT '{}';
    END IF;
END $$;

-- Check and Fix column type if needed (e.g., if it was created as something else)
-- This is harder to do safely in a generic script without dropping, so we assume valid state or user intervention.

-- Verify the column exists now
select column_name, data_type 
from information_schema.columns 
where table_name = 'recipes' and column_name = 'ingredients';
