
CREATE TABLE IF NOT EXISTS ozon_analytics.raw_events
(
    Hour             UInt8,
    DeviceTypeName   String,
    ApplicationName  String,
    OSName           String,
    ProvinceName     String,
    ContentUnitID    UInt64
)
ENGINE = MergeTree
ORDER BY (ContentUnitID, Hour);
