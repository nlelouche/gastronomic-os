-- Migration: Scoring Engine (The Chef's Brain)
-- Date: 2026-01-12
-- Description: Implements a server-side scoring function to rank recipes based on inventory.

-- 1. Create Helper to parse ingredients (Simplified for prototype)
-- In production, we'd use a separate table `recipe_ingredients` for proper joining.
-- Here we rely on fuzzy text matching against the `ingredients` text array.

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

    -- Iterate Recipe Ingredients
    FOR i IN 1..total_ingredients LOOP
        ing_lower := lower(recipe_ingredients[i]);
        
        -- Check against Inventory
        FOR j IN 1..array_length(user_inventory_names, 1) LOOP
            inv_lower := lower(user_inventory_names[j]);
            
            -- Fuzzy Match: "2 onions" contains "onion"?
            -- Logic: If the recipe ingredient string contains the inventory item name.
            -- Example: Ing="chopped onions", Inv="onion" -> Match.
            IF position(inv_lower in ing_lower) > 0 THEN
                matched_count := matched_count + 1;
                score := score + 10; -- Base match points
                
                -- Freshness Bonus
                IF user_inventory_expiries[j] IS NOT NULL THEN
                    days_until_expiry := user_inventory_expiries[j] - CURRENT_DATE;
                    IF days_until_expiry <= 2 THEN
                        score := score + 50; -- Critical Rescue Bonus
                    ELSIF days_until_expiry <= 5 THEN
                        score := score + 20; -- Freshness Bonus
                    END IF;
                END IF;
                
                EXIT; -- Stop checking inventory for this ingredient once matched
            END IF;
        END LOOP;
    END LOOP;

    -- Coverage Multiplier
    -- score = score * (0.5 + (matched / total * 0.5))
    IF matched_count > 0 THEN
        score := score * (0.5 + ((matched_count::float / total_ingredients::float) * 0.5));
    END IF;

    RETURN score;
END;
$$;

-- 2. Create RPC Function for Dashboard
CREATE OR REPLACE FUNCTION public.get_dashboard_suggestions(
    limit_count int DEFAULT 20
)
RETURNS SETOF public.recipes
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    -- We fetch inventory into arrays for passing to the scoring function
    inv_names text[];
    inv_expiries date[];
    current_user_id uuid := auth.uid();
BEGIN
    -- Aggregating inventory for the current user
    SELECT 
        array_agg(name), 
        array_agg(expiration_date)
    INTO 
        inv_names, 
        inv_expiries
    FROM public.inventory_items
    WHERE user_id = current_user_id 
      AND quantity > 0;

    -- If no inventory, just return by created_at
    IF inv_names IS NULL THEN
        RETURN QUERY SELECT * FROM public.recipes ORDER BY created_at DESC LIMIT limit_count;
        RETURN;
    END IF;

    -- Return Scored Recipes
    RETURN QUERY
    SELECT *
    FROM public.recipes
    -- Pre-filter? Maybe only recipes with at least one match?
    -- For now, score everything. (Scalability warning: checking 20k rows is fine, but 1M is not)
    -- Optimization: We could add a 'WHERE ingredients && inv_names' clause if ingredients were individual text items in array
    -- But our ingredients are "2 onions", so '&&' operator won't work on strict equality.
    ORDER BY public.calculate_recipe_score(ingredients, inv_names, inv_expiries) DESC
    LIMIT limit_count;
END;
$$;
