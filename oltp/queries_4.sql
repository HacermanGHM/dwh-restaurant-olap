-- 38. +
/*Для каждого клиента выбрать его любимое блюдо, т. е. 
то, которое он заказывает чаще других.*/

WITH dish_stats AS (
    SELECT
        O.FK_ID_Person, D.ID_dishes, D.Dish_title, SUM(OD.Dish_count) AS total_count
    FROM Orders O
    JOIN Order_Dishes OD ON OD.ID_order = O.ID_order
    JOIN Dishes D ON D.ID_dishes = OD.ID_dishes
    GROUP BY O.FK_ID_Person, D.ID_dishes, D.Dish_title
)
SELECT P.Surname, DS.Dish_title, DS.total_count
FROM dish_stats DS
JOIN Person P ON P.ID_Person = DS.FK_ID_Person
WHERE DS.total_count = (
    SELECT MAX(DS2.total_count)
    FROM dish_stats DS2
    WHERE DS2.FK_ID_Person = DS.FK_ID_Person
)
ORDER BY P.Surname;

-- 39. +
/*Выбрать блюдо, которое включено в каждый заказ.*/

SELECT D.Dish_title
FROM Dishes D
JOIN Order_Dishes OD ON OD.ID_dishes = D.ID_dishes
GROUP BY D.ID_dishes, D.Dish_title
HAVING COUNT(OD.ID_order) = (SELECT COUNT(*) FROM Orders);
-- ну или так
-- нет таких заказов, где нет такого блюда
SELECT D.Dish_title
FROM Dishes D
WHERE NOT EXISTS(
	SELECT 1
	FROM Orders O
	WHERE NOT EXISTS(
		SELECT 1
		FROM Order_dishes OD
		WHERE OD.id_dishes = D.id_dishes AND OD.id_order = O.id_order
	)
);

-- 40. +
/*Выбрать клиентов, которые в каждый заказ включают 
одно и то же блюдо. В результирующей таблице должно быть два 
столбца: фамилия, имя, отчество клиента и название блюда. */

SELECT CONCAT(P.Surname, ' ', P.First_name, ' ', P.Patonymic), D.Dish_title
FROM Order_Dishes OD
JOIN Orders O ON O.id_order = OD.id_order
JOIN Person P ON P.id_person = O.fk_id_person
JOIN Dishes D ON D.ID_dishes = OD.ID_dishes
GROUP BY P.id_person, P.Surname, P.First_name, P.Patonymic, D.ID_dishes, D.Dish_title
HAVING COUNT(DISTINCT O.ID_order) = (
    SELECT COUNT(*)
    FROM Orders Ord
    WHERE Ord.FK_ID_Person = P.ID_Person
);

-- 41. +
/*Выбрать блюда, которые никто не заказывал последние 
полгода или вообще никто никогда не заказывал. */

SELECT *
FROM Dishes D
WHERE NOT EXISTS (
	SELECT 1
	FROM Order_dishes OD
	JOIN Orders O ON O.id_order = OD.id_order
	WHERE O.date_order + INTERVAL '6 month' >= CURRENT_DATE 
		AND D.ID_dishes = OD.ID_dishes
);

-- 42. +
/*Вывести фамилии, имена, отчества сотрудников, 
которые работали в одной и той же должности в разные периоды времени.*/

SELECT P.Surname, P.First_name, P.Patonymic
FROM Jobs_Workers JW
JOIN Person P ON P.ID_Person = JW.ID_Person
GROUP BY P.ID_Person, P.Surname, P.First_name, P.Patonymic, JW.ID_Job
HAVING COUNT(JW.Date_of_entry) > 1;

-- 43. +
/*Вывести все иерархии категорий блюд.*/

WITH RECURSIVE CatTree AS (
    -- 1. Корневые категории (без родителя)
    SELECT 
        ID_categories,
        ID_Parent_Category,
        Category_title,
        1 AS levels
    FROM Categories
    WHERE ID_Parent_Category IS NULL

    UNION ALL

    -- 2. Дочерние категории
    SELECT 
        C.ID_categories,
        C.ID_Parent_Category,
        C.Category_title,
        CT.levels + 1
    FROM Categories C
    JOIN CatTree CT 
        ON C.ID_Parent_Category = CT.ID_categories
)
SELECT *
FROM CatTree
ORDER BY levels, ID_categories;

-- 44. +
/*Для каждой категории вывести количество блюд, 
непосредственно в нее входящих. */

SELECT C.category_title, COUNT(D.id_dishes)
FROM Categories C
LEFT JOIN Dishes D
	ON D.ID_categories = C.ID_Categories
GROUP BY C.id_categories
ORDER BY C.id_categories;

-- 45. +
/*Для каждой категории блюд вывести количество различных блюд,
входящих в нее и в подкатегории. */

-- все пары вида "для кого считаем - кого учесть"
WITH RECURSIVE CatTree AS (
    SELECT 
        ID_categories AS parent,
        ID_categories AS child
    FROM Categories

    UNION ALL

    SELECT
        CT.parent,
        C.ID_categories
    FROM Categories C
    JOIN CatTree CT 
        ON C.ID_Parent_Category = CT.child
)
SELECT C.Category_title, COUNT(D.ID_dishes) 
FROM Categories C
LEFT JOIN CatTree CT 
       ON CT.parent = C.ID_categories
LEFT JOIN Dishes D 
       ON D.ID_Categories = CT.child
GROUP BY C.ID_categories, C.Category_title
ORDER BY C.ID_Categories;

-- 46. +
/*Выбрать все цепочки категорий. */

WITH RECURSIVE CatPath AS (
    SELECT 
        ID_categories,
        ID_Parent_Category,
        Category_title,
        Category_title::TEXT AS pathes
    FROM Categories
    WHERE ID_Parent_Category IS NULL

    UNION ALL

    SELECT
        C.ID_categories,
        C.ID_Parent_Category,
        C.Category_title,
        CP.pathes || ' - ' || C.Category_title
    FROM Categories C
    JOIN CatPath CP
        ON C.ID_Parent_Category = CP.ID_categories
)
SELECT pathes
FROM CatPath CP
WHERE NOT EXISTS (
    SELECT 1
    FROM Categories C2
    WHERE C2.ID_Parent_Category = CP.ID_categories
)
ORDER BY pathes;

-- 47. +
/*Выбрать самую длинную цепочку категорий.*/
WITH RECURSIVE CatPath AS (
    SELECT 
        ID_categories,
        ID_Parent_Category,
        Category_title,
		1 AS levels,
        Category_title::TEXT AS pathes
    FROM Categories
    WHERE ID_Parent_Category IS NULL

    UNION ALL

    SELECT
        C.ID_categories,
        C.ID_Parent_Category,
        C.Category_title,
		CP.levels + 1,
        CP.pathes || ' - ' || C.Category_title
    FROM Categories C
    JOIN CatPath CP
        ON C.ID_Parent_Category = CP.ID_categories
)
SELECT levels, pathes
FROM CatPath CP
WHERE NOT EXISTS (
    SELECT 1
    FROM Categories C2
    WHERE C2.ID_Parent_Category = CP.ID_categories
)
AND CP.levels = (SELECT MAX(levels) FROM CatPath)
ORDER BY levels, pathes;

-- 48. +
/*Найти категорию, от которой идет самая длинная цепочка категорий. */
WITH RECURSIVE CatPath AS (
    SELECT 
		ID_categories AS root,
        ID_categories,
        ID_Parent_Category,
        Category_title,
        1 AS levels
    FROM Categories
    WHERE ID_Parent_Category IS NULL

    UNION ALL

    SELECT
		CP.root,
        C.ID_categories,
        C.ID_Parent_Category,
        C.Category_title,
        CP.levels + 1
    FROM Categories C
    JOIN CatPath CP
        ON C.ID_Parent_Category = CP.ID_categories
)
SELECT C.category_title
FROM CatPath CP
JOIN Categories C ON C.ID_categories = CP.root
WHERE NOT EXISTS (
    SELECT 1
    FROM Categories C2
    WHERE C2.ID_Parent_Category = CP.ID_categories
) AND CP.levels = (SELECT MAX(levels) FROM CatPath);

-- 49. побаловаться (считать количество вхождений каждого блюда, оно должно быть одинаковым. 
-- или сравнить максимальное и минимальное количество, они должны быть равны
-- или через not exists, нет таких заказов, где чето-то нет. или через множества. )
/*Выбрать фамилии, имена, отчества клиентов, которые 
всегда делают заказы только определенного набора блюд.*/
SELECT P.Surname, P.First_name, P.Patonymic
FROM Person P
JOIN Orders O ON O.FK_ID_Person = P.ID_Person
JOIN Order_Dishes OD ON OD.ID_order = O.ID_order
GROUP BY P.ID_Person, P.Surname, P.First_name, P.Patonymic
HAVING COUNT(DISTINCT OD.ID_dishes) = ALL (
    SELECT COUNT(DISTINCT OD2.ID_dishes)
    FROM Orders O2
    JOIN Order_Dishes OD2 ON OD2.ID_order = O2.ID_order
    WHERE O2.FK_ID_Person = P.ID_Person
    GROUP BY O2.ID_order
);

-------

-- 50. +
/*Вывести сообщения «Есть вакантные должности», если 
таковые действительно имеются. */
SELECT CASE 
	WHEN EXISTS (SELECT 1
			FROM Jobs J
			WHERE NOT EXISTS (
			    SELECT ID_Job 
			    FROM Jobs_Workers JW
			    WHERE JW.ID_Job = J.ID_Job AND Date_of_completion IS NULL
		))
		THEN 'Есть вакантные места'
		ELSE ' '
	END;

-- 51. +
/*Выбрать количество приготовленных заказов, количество
отмененных заказов, количество готовящихся заказов, 
процентное отношение отмененных заказов к количеству всех заказов.*/
SELECT
    (SELECT COUNT(*) FROM Orders O JOIN Statuses S 
        ON S.ID_Statuses = O.FK_ID_Statuses
        WHERE S.Status_title = 'Приготовлен') AS cooked_count,

    (SELECT COUNT(*) FROM Orders O JOIN Statuses S 
        ON S.ID_Statuses = O.FK_ID_Statuses
        WHERE S.Status_title = 'Отменён') AS cancelled_count,

    (SELECT COUNT(*) FROM Orders O JOIN Statuses S 
        ON S.ID_Statuses = O.FK_ID_Statuses
        WHERE S.Status_title = 'В процессе') AS cooking_count,

    ROUND(
        100.0 *
        (SELECT COUNT(*) FROM Orders O JOIN Statuses S 
            ON S.ID_Statuses = O.FK_ID_Statuses
            WHERE S.Status_title = 'Отменён')
        /
        (SELECT COUNT(*) FROM Orders),
        2
    ) AS cancelled_percent;

-------------------------------- даже не знаю, что хуже

SELECT
    SUM(CASE WHEN S.Status_title = 'Приготовлен' THEN 1 ELSE 0 END) AS prepared_count,
    SUM(CASE WHEN S.Status_title = 'Отменён' THEN 1 ELSE 0 END) AS cancelled_count,
    SUM(CASE WHEN S.Status_title = 'В процессе' THEN 1 ELSE 0 END) AS cooking_count,
    ROUND(
        100.0 * SUM(CASE WHEN S.Status_title = 'Отменён' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS cancelled_percent
FROM Orders O
JOIN Statuses S ON S.ID_Statuses = O.FK_ID_Statuses;




SELECT DISTINCT
    cooked_count,
    cancelled_count,
    cooking_count,
    cancelled_percent
FROM (
    SELECT
        SUM(CASE WHEN S.Status_title = 'Приготовлен' THEN 1 ELSE 0 END)
            OVER () AS cooked_count,

        SUM(CASE WHEN S.Status_title = 'Отменён' THEN 1 ELSE 0 END)
            OVER () AS cancelled_count,

        SUM(CASE WHEN S.Status_title = 'В процессе' THEN 1 ELSE 0 END)
            OVER () AS cooking_count,

        ROUND(
            100.0 * SUM(CASE WHEN S.Status_title = 'Отменён' THEN 1 ELSE 0 END)
                OVER ()
            / COUNT(*) OVER (),
            2
        ) AS cancelled_percent

    FROM Orders O
    JOIN Statuses S ON S.ID_Statuses = O.FK_ID_Statuses
) t;
