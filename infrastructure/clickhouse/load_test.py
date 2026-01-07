import time
import requests
import pandas as pd


CH_URL = 'http://localhost:8124'

SETTINGS = "?use_query_cache=0&max_threads=1"

def execute_query(query, name="Query"):
    start = time.time()
    try:

        response = requests.post(CH_URL + SETTINGS, data=query, timeout=30)
        response.raise_for_status()
        elapsed = time.time() - start
        return elapsed, response.text
    except Exception as e:
        print(f"Ошибка в {name}: {e}")
        return None, None

def main():
    results = []
    
    # 1. Сравнение по категориям (Raw vs MV)
    query_raw = """
    SELECT category_id, count(), avg(price) 
    FROM ozon_analytics.ecom_offers 
    GROUP BY category_id 
    ORDER BY count() DESC LIMIT 20
    """
    
    query_mv = """
    SELECT category_id, sum(total_offers), sum(sum_price) / sum(total_offers) 
    FROM ozon_analytics.catalog_by_category_mv 
    GROUP BY category_id 
    ORDER BY sum(total_offers) DESC LIMIT 20
    """

    # 2. Анализ покрытия (Raw vs MV)
    # Ищем сколько событий на каждый товар
    query_coverage_raw = """
    SELECT ContentUnitID, count() 
    FROM ozon_analytics.raw_events 
    GROUP BY ContentUnitID 
    ORDER BY count() DESC LIMIT 10
    """
    
    query_coverage_mv = """
    SELECT ContentUnitID, event_count 
    FROM ozon_analytics.product_activity_mv 
    ORDER BY event_count DESC LIMIT 10
    """
    
    print("=== Запуск финального нагрузочного тестирования ===")
    
    # Делаем 10 попыток для более точного среднего
    for i in range(10):
        t_raw, _ = execute_query(query_raw, "Raw Categories")
        t_mv, _ = execute_query(query_mv, "MV Categories")
        
        t_cov_raw, _ = execute_query(query_coverage_raw, "Raw Coverage")
        t_cov_mv, _ = execute_query(query_coverage_mv, "MV Coverage")
        
        if all([t_raw, t_mv, t_cov_raw, t_cov_mv]):
            results.append({
                'iteration': i + 1,
                'categories_raw': t_raw,
                'categories_mv': t_mv,
                'cat_speedup': t_raw / t_mv,
                'coverage_raw': t_cov_raw,
                'coverage_mv': t_cov_mv,
                'cov_speedup': t_cov_raw / t_cov_mv
            })
            print(f"Попытка {i+1}: OK (Ускорение кат: {t_raw/t_mv:.1f}x, Покр: {t_cov_raw/t_cov_mv:.1f}x)")

    # Анализ результатов
    if results:
        df = pd.DataFrame(results)
        print("\n" + "="*40)
        print("ИТОГОВЫЙ ОТЧЕТ ПО ПРОИЗВОДИТЕЛЬНОСТИ")
        print("="*40)
        
        print(f"\nАНАЛИЗ КАТЕГОРИЙ:")
        print(f"Среднее время (Raw): {df['categories_raw'].mean():.4f} сек")
        print(f"Среднее время (MV):  {df['categories_mv'].mean():.4f} сек")
        print(f"Макс. ускорение:    {df['cat_speedup'].max():.1f}x")
        
        print(f"\nАНАЛИЗ ПОКРЫТИЯ СОБЫТИЯМИ:")
        print(f"Среднее время (Raw): {df['coverage_raw'].mean():.4f} сек")
        print(f"Среднее время (MV):  {df['coverage_mv'].mean():.4f} сек")
        print(f"Среднее ускорение:   {df['cov_speedup'].mean():.1f}x")
        print(f"Максимальное ускорение: {df['cov_speedup'].max():.1f}x")

if __name__ == "__main__":
    main()
