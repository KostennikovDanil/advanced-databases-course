
CREATE TABLE IF NOT EXISTS ozon_analytics.ecom_offers
(
    offer_id    UInt64,
    price       Float64,
    seller_id   UInt64,
    category_id UInt32,
    vendor      String,
    updated_at  DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(updated_at)
PARTITION BY toYYYYMM(updated_at)
ORDER BY (category_id, vendor, offer_id);
