-- 1. Агрегаты по категориям (кол-во товаров и средняя цена)
CREATE MATERIALIZED VIEW IF NOT EXISTS ozon_analytics.catalog_by_category_mv
ENGINE = SummingMergeTree
ORDER BY category_id AS
SELECT 
    category_id,
    count() as total_offers,
    sum(price) as sum_price -- Суммируем для последующего расчета среднего
FROM ozon_analytics.ecom_offers
GROUP BY category_id;

-- 2. Агрегаты по брендам (кол-во товаров и границы цен)
CREATE MATERIALIZED VIEW IF NOT EXISTS ozon_analytics.catalog_by_brand_mv
ENGINE = AggregatingMergeTree
ORDER BY vendor AS
SELECT 
    vendor,
    countState() as total_offers,
    minState(price) as min_price,
    maxState(price) as max_price
FROM ozon_analytics.ecom_offers
GROUP BY vendor;

-- 3. Анализ покрытия (сколько событий на каждый товар)
CREATE MATERIALIZED VIEW IF NOT EXISTS ozon_analytics.product_activity_mv
ENGINE = SummingMergeTree
ORDER BY ContentUnitID AS
SELECT 
    ContentUnitID,
    count() as event_count
FROM ozon_analytics.raw_events
GROUP BY ContentUnitID;
