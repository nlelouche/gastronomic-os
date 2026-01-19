-- Add bio column to family_members if it doesn't exist
ALTER TABLE public.family_members
ADD COLUMN IF NOT EXISTS bio TEXT;

-- Update RLS to ensure users can update their own members (already covered by generic policy, but good to double check)
-- Existing policy: "Users can update their own family members" ON public.family_members FOR UPDATE USING (auth.uid() = user_id);
