-- Запрос: Топ-30 брендов по количеству товаров
-- Использует MV: catalog_by_brand_mv (AggregatingMergeTree)
SELECT 
    vendor, 
    countMerge(total_offers) as items_count 
FROM ozon_analytics.catalog_by_brand_mv 
GROUP BY vendor 
ORDER BY items_count DESC 
LIMIT 30;
