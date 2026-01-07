# Лабораторная работа №2: ClickHouse для e-commerce данных

## Описание
Аналитическая система для анализа каталога товаров и пользовательских событий интернет-магазина на основе ClickHouse.

Билд
```
cd infrastructure/clickhouse
docker compose build
docker compose up -d
```

создание таблиц:
```
docker exec -i clickhouse-dev clickhouse-client --database ozon_analytics < 02_create_ecom_offers.sql
docker exec -i clickhouse-dev clickhouse-client --database ozon_analytics < 03_create_raw_events.sql
```

Далее необходимо загрузить данные в бд. Я загружал таким образом:
```
curl -H "X-ClickHouse-User: default" \   
     --data-binary "@10ozon.csv" \
     "http://5.188.44.142:8124/?query=INSERT+INTO+ozon_analytics.ecom_offers+(offer_id,price,seller_id,category_id,vendor)+FORMAT+CSVWithNames"
```

```
curl -sS 'http://5.188.44.142:8124/?query=INSERT+INTO+ozon_analytics.raw_events+FORMAT+Parquet' \
     -H 'Content-Type: application/octet-stream' \
     --data-binary @data.parquet
```

Материализованные представление данных:
```
docker exec -i clickhouse-dev clickhouse-client -n < clickhouse/init-scripts/02-materialized_views.sql
```

Дозаливка данных если они были загруженны до инициализации материализованного представления (Например, у меня так и произошло)
```
docker exec -i clickhouse-dev clickhouse-client --query "INSERT INTO ozon_analytics.catalog_by_category_mv SELECT category_id, count(), sum(price) FROM ozon_analytics.ecom_offers GROUP BY category_id"

docker exec -i clickhouse-dev clickhouse-client --query "INSERT INTO ozon_analytics.catalog_by_brand_mv SELECT vendor, countState(), minState(price), maxState(price) FROM ozon_analytics.ecom_offers GROUP BY vendor"

docker exec -i clickhouse-dev clickhouse-client --query "INSERT INTO ozon_analytics.product_activity_mv SELECT ContentUnitID, count() FROM ozon_analytics.raw_events GROUP BY ContentUnitID"
```

## Результаты
### Вызов SQL запросов
<img width="1280" height="438" alt="image" src="https://github.com/user-attachments/assets/30d4df40-a1dc-4c77-a478-2a46825d09fc" />

<img width="1280" height="578" alt="image" src="https://github.com/user-attachments/assets/46ecd6ca-e11f-4443-981d-e414102b906c" />

<img width="1280" height="237" alt="image" src="https://github.com/user-attachments/assets/bec0383f-fc52-420f-ad1f-bd2ce7534f6d" />

<img width="1280" height="84" alt="image" src="https://github.com/user-attachments/assets/b6c9570b-f7da-4fe1-8559-f76d3201e887" />

### Нагрузачное тестирование

<img width="351" height="237" alt="image" src="https://github.com/user-attachments/assets/60097ee4-5198-4a70-b0e5-a24ad422bde7" />

### Дашборды

http://5.188.44.142:3001/dashboards


