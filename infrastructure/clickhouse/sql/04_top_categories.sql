-- Запрос: Топ-20 категорий по количеству товаров
-- Использует MV: catalog_by_category_mv
SELECT 
    category_id, 
    sum(total_offers) as items_count 
FROM ozon_analytics.catalog_by_category_mv 
GROUP BY category_id 
ORDER BY items_count DESC 
LIMIT 20;
