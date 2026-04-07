-- Очистка
TRUNCATE TABLE dim_client CASCADE;
TRUNCATE TABLE dim_dish CASCADE;
TRUNCATE TABLE dim_employee CASCADE;
TRUNCATE TABLE dim_hall CASCADE;
TRUNCATE TABLE dim_table CASCADE;
TRUNCATE TABLE dim_status CASCADE;
TRUNCATE TABLE dim_category CASCADE;
TRUNCATE TABLE dim_menu CASCADE;
TRUNCATE TABLE fact_order_items;

-- Загрузка Dimension-таблиц

-- dim_client
INSERT INTO dim_client
SELECT 
    p.id_person AS client_key,
    p.surname,
    p.first_name,
    p.patonymic,
    rc.discount_size,
    rc.card_number
FROM person p
JOIN regular_client rc ON rc.id_person = p.id_person;

-- dim_dish
INSERT INTO dim_dish
SELECT 
    d.id_dishes AS dish_key,
    d.dish_title,
    d.dish_cost,
    c.category_title
FROM dishes d
JOIN categories c ON c.id_categories = d.id_categories;

-- dim_employee
INSERT INTO dim_employee
SELECT 
    p.id_person AS employee_key,
    p.surname,
    p.first_name,
    p.patonymic,
    j.job_title,
    j.salary,
    jw.date_of_entry,
    COALESCE(jw.date_of_completion, CURRENT_DATE) AS date_of_completion,
    CASE WHEN jw.date_of_completion IS NULL THEN true ELSE false END AS is_current
FROM person p
JOIN workers w ON w.id_person = p.id_person
JOIN jobs_workers jw ON jw.id_person = p.id_person
JOIN jobs j ON j.id_job = jw.id_job;

-- dim_hall
INSERT INTO dim_hall
SELECT id_hall AS hall_key, halls_title AS hall_name FROM halls;

-- dim_table
INSERT INTO dim_table
SELECT 
    ht.id_hall_tables AS table_key,
    h.halls_title AS hall_name,
    ht.table_number,
    h.id_hall AS hall_key
FROM hall_tables ht
JOIN halls h ON h.id_hall = ht.id_hall;

-- dim_status
INSERT INTO dim_status
SELECT id_statuses AS status_key, status_title FROM statuses;

-- dim_category
INSERT INTO dim_category
SELECT 
    id_categories AS category_key,
    category_title,
    id_parent_category,
    (SELECT category_title FROM categories WHERE id_categories = c.id_parent_category) AS parent_category_title
FROM categories c;

-- dim_menu
INSERT INTO dim_menu
SELECT id_menu AS menu_key, create_date, menu_title FROM menu;



-- Загрузка Fact-таблицы
INSERT INTO fact_order_items
SELECT 
    o.id_order,
    o.date_order AS date_key,
    o.fk_id_person AS client_key,
    od.id_dishes AS dish_key,
    sh.id_person AS waiter_key,
    o.fk_id_statuses AS status_key,
    ht.id_hall_tables AS table_key,
    ht.id_hall AS hall_key,
    
    od.dish_count,
    d.dish_cost AS dish_cost,
    (od.dish_count * d.dish_cost) AS item_original_cost,
    ROUND(od.dish_count * d.dish_cost * 
          (1 - COALESCE(rc.discount_size, 0)::numeric/100), 2) AS item_final_cost,
    o.commentary,
    o.order_cost AS full_order_cost
FROM orders o
JOIN order_dishes od ON od.id_order = o.id_order
JOIN dishes d ON d.id_dishes = od.id_dishes
LEFT JOIN regular_client rc ON rc.id_person = o.fk_id_person
LEFT JOIN hall_tables ht ON ht.id_hall_tables IN (
    SELECT ss.id_hall_tables 
    FROM shift_summary ss 
    WHERE ss.id_shifts IN (SELECT id_shifts FROM shifts WHERE shifts_date = o.date_order)
)
LEFT JOIN shift_summary sh ON sh.id_hall_tables = ht.id_hall_tables 
                          AND sh.id_shifts IN (SELECT id_shifts FROM shifts WHERE shifts_date = o.date_order);