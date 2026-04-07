-- 1. Dim Date
CREATE TABLE dim_date AS
SELECT 
    d::date AS date_key,
    EXTRACT(YEAR FROM d) AS year,
    EXTRACT(MONTH FROM d) AS month,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(QUARTER FROM d) AS quarter,
    EXTRACT(ISODOW FROM d) AS weekday,
    CASE WHEN EXTRACT(ISODOW FROM d) > 5 THEN true ELSE false END AS is_weekend
FROM generate_series('2023-01-01'::date, '2027-12-31'::date, '1 day') AS d;

-- 2. Dim Client
CREATE TABLE dim_client AS
SELECT 
    p.id_person AS client_key,
    p.surname,
    p.first_name,
    p.patonymic,
    rc.discount_size,
    rc.card_number
FROM person p
JOIN regular_client rc ON rc.id_person = p.id_person;

-- 3. Dim Dish
CREATE TABLE dim_dish AS
SELECT 
    d.id_dishes AS dish_key,
    d.dish_title,
    d.dish_cost,
    c.category_title
FROM dishes d
JOIN categories c ON c.id_categories = d.id_categories;

-- 4. dim_employee + история должностей
CREATE TABLE dim_employee AS
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

-- 5. dim_hall
CREATE TABLE dim_hall AS
SELECT 
    id_hall AS hall_key,
    halls_title AS hall_name
FROM halls;

-- 6. dim_table
CREATE TABLE dim_table AS
SELECT 
    ht.id_hall_tables AS table_key,
    h.halls_title AS hall_name,
    ht.table_number,
    h.id_hall AS hall_key
FROM hall_tables ht
JOIN halls h ON h.id_hall = ht.id_hall;

-- 7. dim_status
CREATE TABLE dim_status AS
SELECT 
    id_statuses AS status_key,
    status_title
FROM statuses;

-- 8. dim_category (с поддержкой иерархии)
CREATE TABLE dim_category AS
SELECT 
    id_categories AS category_key,
    category_title,
    id_parent_category,
    (SELECT category_title FROM categories WHERE id_categories = c.id_parent_category) AS parent_category_title
FROM categories c;

-- 9. dim_menu
CREATE TABLE dim_menu AS
SELECT 
    id_menu AS menu_key,
    create_date,
    menu_title
FROM menu;



CREATE TABLE fact_order_items AS
SELECT 
    o.id_order,
    o.date_order AS date_key,                    -- связь с dim_date
    o.fk_id_person AS client_key,                -- связь с dim_client
    od.id_dishes AS dish_key,                    -- связь с dim_dish
    sh.id_person AS waiter_key,                  -- связь с dim_employee
    o.fk_id_statuses AS status_key,              -- связь с dim_status
    ht.id_hall_tables AS table_key,              -- связь с dim_table
    ht.id_hall AS hall_key,                      -- связь с dim_hall
    
    od.dish_count,
    d.dish_cost,
    (od.dish_count * d.dish_cost) AS item_original_cost,
    ROUND(od.dish_count * d.dish_cost * 
          (1 - COALESCE(rc.discount_size, 0)::numeric/100), 2) AS item_final_cost,
    o.commentary,
    o.order_cost AS full_order_cost
FROM orders o
JOIN order_dishes od ON od.id_order = o.id_order
JOIN dishes d ON d.id_dishes = od.id_dishes
LEFT JOIN regular_client rc ON rc.id_person = o.fk_id_person
LEFT JOIN hall_tables ht ON ht.id_hall_tables = (
    SELECT id_hall_tables 
    FROM shift_summary ss 
    WHERE ss.id_person = (SELECT id_person FROM waiters WHERE id_person = o.fk_id_person LIMIT 1)
      AND ss.id_shifts IN (SELECT id_shifts FROM shifts WHERE shifts_date = o.date_order)
)
LEFT JOIN shift_summary sh ON sh.id_hall_tables = ht.id_hall_tables 
                          AND sh.id_shifts IN (SELECT id_shifts FROM shifts WHERE shifts_date = o.date_order);