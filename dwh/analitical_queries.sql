-- 1. Выручка по месяцам (сравнение с предыдущим годом)
SELECT 
    dd.year,
    dd.month_name,
    SUM(f.item_final_cost) AS total_revenue,
    SUM(f.item_final_cost) - LAG(SUM(f.item_final_cost)) OVER (ORDER BY dd.year, dd.month) AS mom_growth
FROM fact_order_items f
JOIN dim_date dd ON dd.date_key = f.date_key
GROUP BY dd.year, dd.month_name, dd.month
ORDER BY dd.year DESC, dd.month DESC;

-- 2. ТОП-10 самых прибыльных блюд за всё время
SELECT 
    dd.dish_title,
    COUNT(*) AS times_ordered,
    SUM(f.item_final_cost) AS total_revenue,
    ROUND(AVG(f.item_final_cost), 2) AS avg_item_price
FROM fact_order_items f
JOIN dim_dish dd ON dd.dish_key = f.dish_key
GROUP BY dd.dish_title
ORDER BY total_revenue DESC
LIMIT 10;

-- 3. Эффективность официантов (выручка + количество заказов)
SELECT 
    de.surname || ' ' || de.first_name AS waiter_name,
    COUNT(DISTINCT f.id_order) AS orders_served,
    SUM(f.item_final_cost) AS total_revenue,
    ROUND(SUM(f.item_final_cost) / COUNT(DISTINCT f.id_order), 2) AS avg_order_value
FROM fact_order_items f
JOIN dim_employee de ON de.employee_key = f.waiter_key
WHERE de.is_current = true
GROUP BY de.surname, de.first_name
ORDER BY total_revenue DESC;

-- 4. Анализ скидок — сколько теряем на скидках
SELECT 
    dd.year,
    SUM(f.item_original_cost) AS revenue_without_discount,
    SUM(f.item_final_cost) AS revenue_final,
    ROUND(SUM(f.item_original_cost - f.item_final_cost), 2) AS total_discount_amount,
    ROUND(100.0 * SUM(f.item_original_cost - f.item_final_cost) / SUM(f.item_original_cost), 2) AS discount_percent
FROM fact_order_items f
JOIN dim_date dd ON dd.date_key = f.date_key
GROUP BY dd.year
ORDER BY dd.year DESC;

-- 5. Любимые блюда клиентов
SELECT 
    dc.surname || ' ' || dc.first_name AS client_name,
    dd.dish_title AS favorite_dish,
    COUNT(*) AS times_ordered
FROM fact_order_items f
JOIN dim_client dc ON dc.client_key = f.client_key
JOIN dim_dish dd ON dd.dish_key = f.dish_key
WHERE f.client_key IN (
    SELECT client_key 
    FROM fact_order_items 
    GROUP BY client_key 
    HAVING COUNT(DISTINCT dish_key) > 5  -- клиенты, которые пробовали много блюд
)
GROUP BY dc.surname, dc.first_name, dd.dish_title
HAVING COUNT(*) >= 2
ORDER BY client_name, times_ordered DESC;

-- 6. Загрузка залов по дням недели
SELECT 
    dd.weekday,
    dh.hall_name,
    COUNT(DISTINCT f.id_order) AS total_orders,
    SUM(f.item_final_cost) AS revenue
FROM fact_order_items f
JOIN dim_date dd ON dd.date_key = f.date_key
JOIN dim_hall dh ON dh.hall_key = f.hall_key
GROUP BY dd.weekday, dh.hall_name
ORDER BY revenue DESC;

-- 7. Динамика отменённых заказов
SELECT 
    dd.year,
    dd.month_name,
    COUNT(CASE WHEN ds.status_title = 'Отменён' THEN 1 END) AS cancelled_orders,
    COUNT(*) AS total_orders,
    ROUND(100.0 * COUNT(CASE WHEN ds.status_title = 'Отменён' THEN 1 END) / COUNT(*), 2) AS cancel_rate_percent
FROM fact_order_items f
JOIN dim_date dd ON dd.date_key = f.date_key
JOIN dim_status ds ON ds.status_key = f.status_key
GROUP BY dd.year, dd.month_name, dd.month
ORDER BY dd.year DESC, dd.month DESC;