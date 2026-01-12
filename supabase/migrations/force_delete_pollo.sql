-- 1. Identificar ID de la receta original
-- (Aunque lo hacemos con subqueries para hacerlo en un solo bloque)

-- 2. Limpiar SNAPSHOTS de los FORKS (hijos)
DELETE FROM recipe_snapshots 
WHERE recipe_id IN (
    SELECT id FROM recipes 
    WHERE origin_id IN (SELECT id FROM recipes WHERE title = 'Pollo al Limón con Arroz y Vegetales')
);

-- 3. Limpiar COMMITS de los FORKS (hijos)
DELETE FROM commits 
WHERE recipe_id IN (
    SELECT id FROM recipes 
    WHERE origin_id IN (SELECT id FROM recipes WHERE title = 'Pollo al Limón con Arroz y Vegetales')
);

-- 4. Eliminar los FORKS (recetas hijas que apuntan a la original)
DELETE FROM recipes 
WHERE origin_id IN (SELECT id FROM recipes WHERE title = 'Pollo al Limón con Arroz y Vegetales');

-- 5. Limpiar SNAPSHOTS de la receta Original
DELETE FROM recipe_snapshots 
WHERE recipe_id IN (SELECT id FROM recipes WHERE title = 'Pollo al Limón con Arroz y Vegetales');

-- 6. Limpiar COMMITS de la receta Original
DELETE FROM commits 
WHERE recipe_id IN (SELECT id FROM recipes WHERE title = 'Pollo al Limón con Arroz y Vegetales');

-- 7. Eliminar la receta Original
DELETE FROM recipes 
WHERE title = 'Pollo al Limón con Arroz y Vegetales';
