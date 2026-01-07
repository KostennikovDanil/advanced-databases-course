-- Запрос: Среднее количество товаров по брендам внутри категорий
SELECT 
    category_id, 
    round(avg(items_per_brand), 2) as avg_items_in_brand
FROM (
    SELECT category_id, vendor, count() as items_per_brand 
    FROM ozon_analytics.ecom_offers 
    GROUP BY category_id, vendor
) 
GROUP BY category_id
ORDER BY avg_items_in_brand DESC
LIMIT 10;
