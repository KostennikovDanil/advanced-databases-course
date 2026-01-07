CREATE DATABASE IF NOT EXISTS ecom;

CREATE TABLE IF NOT EXISTS ecom.ecom_offers
(
    offer_id UInt64,
    price Float64,
    seller_id UInt64,
    category_id UInt64,
    vendor String,
    version DateTime DEFAULT now()
)
ENGINE = ReplacingMergeTree(version)
PARTITION BY toYYYYMM(version)
ORDER BY (category_id, vendor, offer_id);

CREATE TABLE IF NOT EXISTS  ecom.raw_events
(
    Hour DateTime,
    DeviceTypeName String,
    ApplicationName String,
    OSName String,
    ProvinceName String,
    ContentUnitID UInt64
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(Hour)
ORDER BY (Hour, ContentUnitID);
