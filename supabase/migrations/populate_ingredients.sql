-- Update Pollo al Limón
UPDATE public.recipes
SET ingredients = ARRAY['2 Chicken Breasts', '1 Cup Rice', '2 Lemons', '1 tsp Salt', '1 tbsp Olive Oil']
WHERE title ILIKE '%Pollo%';

-- Update Steak
UPDATE public.recipes
SET ingredients = ARRAY['1 Steak', '2 Eggs', '1 Avocado', 'Salt', 'Pepper']
WHERE title ILIKE '%Steak%';

-- Update Pasta
UPDATE public.recipes
SET ingredients = ARRAY['500g Pasta', '1 Jar Tomato Sauce', '1 Onion', 'Basil']
WHERE title ILIKE '%Pasta%';

-- Check results
SELECT title, ingredients FROM public.recipes;
