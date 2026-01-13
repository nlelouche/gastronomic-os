-- Add translation columns for English (fallback is existing Spanish)
ALTER TABLE recipes
ADD COLUMN title_en TEXT,
ADD COLUMN description_en TEXT,
ADD COLUMN ingredients_en JSONB,
ADD COLUMN steps_en JSONB;

-- Comment
COMMENT ON COLUMN recipes.title_en IS 'English translation of the title. If null, use title (Spanish).';
