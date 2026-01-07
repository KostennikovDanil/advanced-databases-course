-- Запрос: Анализ товаров, по которым не было ни одного события
-- Использует JOIN ecom_offers и MV product_activity_mv
SELECT count() as items_without_events
FROM ozon_analytics.ecom_offers AS offers
LEFT JOIN ozon_analytics.product_activity_mv AS activity 
    ON offers.offer_id = activity.ContentUnitID
WHERE activity.event_count = 0 OR activity.ContentUnitID = 0;
