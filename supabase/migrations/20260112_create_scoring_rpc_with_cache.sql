-- Migration: Scoring Engine & Caching (The Chef's Brain)
-- Date: 2026-01-12
-- Description: Implements `user_dashboard_cache` and updates `get_dashboard_suggestions` to use it.

-- 1. Create Cache Table
CREATE TABLE IF NOT EXISTS public.user_dashboard_cache (
    user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    suggestions_json jsonb NOT NULL,
    updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.user_dashboard_cache ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own cache" ON public.user_dashboard_cache
    FOR SELECT USING (auth.uid() = user_id);

-- 2. Scoring Helper (Same as before)
CREATE OR REPLACE FUNCTION public.calculate_recipe_score(
    recipe_ingredients text[],
    user_inventory_names text[],
    user_inventory_expiries date[]
)
RETURNS float
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
    score float := 0;
    matched_count int := 0;
    total_ingredients int;
    i int;
    j int;
    ing_lower text;
    inv_lower text;
    days_until_expiry int;
BEGIN
    total_ingredients := array_length(recipe_ingredients, 1);
    IF total_ingredients IS NULL OR total_ingredients = 0 THEN
        RETURN 0;
    END IF;

    FOR i IN 1..total_ingredients LOOP
        ing_lower := lower(recipe_ingredients[i]);
        FOR j IN 1..array_length(user_inventory_names, 1) LOOP
            inv_lower := lower(user_inventory_names[j]);
            IF position(inv_lower in ing_lower) > 0 THEN
                matched_count := matched_count + 1;
                score := score + 10;
                IF user_inventory_expiries[j] IS NOT NULL THEN
                    days_until_expiry := user_inventory_expiries[j] - CURRENT_DATE;
                    IF days_until_expiry <= 2 THEN
                        score := score + 50; 
                    ELSIF days_until_expiry <= 5 THEN
                        score := score + 20; 
                    END IF;
                END IF;
                EXIT; 
            END IF;
        END LOOP;
    END LOOP;

    IF matched_count > 0 THEN
        score := score * (0.5 + ((matched_count::float / total_ingredients::float) * 0.5));
    END IF;

    RETURN score;
END;
$$;

-- 3. Cached RPC Function
CREATE OR REPLACE FUNCTION public.get_dashboard_suggestions(
    limit_count int DEFAULT 20
)
RETURNS SETOF public.recipes
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    current_user_id uuid := auth.uid();
    cached_record public.user_dashboard_cache%ROWTYPE;
    inv_names text[];
    inv_expiries date[];
    new_suggestions jsonb;
BEGIN
    -- 1. Check Cache (Valid for 12 hours? Or just daily?)
    -- Let's say valid for today (date check).
    SELECT * INTO cached_record 
    FROM public.user_dashboard_cache 
    WHERE user_id = current_user_id 
      AND updated_at > (now() - interval '4 hours'); -- Refresh every 4 hours for freshness? Or '1 day' for daily.

    IF FOUND THEN
        -- Return cached recipes (Need to cast jsonb back to row)
        RETURN QUERY 
        SELECT (jsonb_populate_record(null::public.recipes, value)).*
        FROM jsonb_array_elements(cached_record.suggestions_json) as value;
        RETURN;
    END IF;

    -- 2. Compute Fresh Suggestions
    SELECT array_agg(name), array_agg(expiration_date)
    INTO inv_names, inv_expiries
    FROM public.inventory_items
    WHERE user_id = current_user_id AND quantity > 0;

    -- If no inventory, fallback to recent
    IF inv_names IS NULL THEN
        RETURN QUERY SELECT * FROM public.recipes ORDER BY created_at DESC LIMIT limit_count;
        RETURN;
    END IF;

    -- Compute and Store in variable first
    -- We need to materialize the result to save it to JSONB
    WITH ranked_recipes AS (
        SELECT *
        FROM public.recipes
        ORDER BY public.calculate_recipe_score(ingredients, inv_names, inv_expiries) DESC
        LIMIT limit_count
    )
    SELECT jsonb_agg(to_jsonb(ranked_recipes.*)) INTO new_suggestions FROM ranked_recipes;

    if new_suggestions IS NULL THEN
         new_suggestions := '[]'::jsonb;
    END IF;

    -- 3. Update Cache
    INSERT INTO public.user_dashboard_cache (user_id, suggestions_json, updated_at)
    VALUES (current_user_id, new_suggestions, now())
    ON CONFLICT (user_id) DO UPDATE 
    SET suggestions_json = EXCLUDED.suggestions_json,
        updated_at = EXCLUDED.updated_at;

    -- 4. Return computed result by querying the table (or the CTE)
    RETURN QUERY
    SELECT (jsonb_populate_record(null::public.recipes, value)).*
    FROM jsonb_array_elements(new_suggestions) as value;

END;
$$;
