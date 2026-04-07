-- 31. 
/*Выбрать категории, названия которых совпадают 
с названием одного из блюд, входящим в категорию.*/
SELECT C.Category_title
FROM Categories C
JOIN Dishes D
	ON D.ID_categories = C.ID_categories
WHERE D.Dish_title = C.Category_title;

-- 32.
/* Найти общее количество однофамильцев по всей базе. */
-- как именно считаются однофамильцы?
SELECT COUNT(*)
FROM Person P
WHERE EXISTS (
    SELECT P.ID_Person 
    FROM Person P2 
    WHERE P2.Surname = P.Surname 
    AND P2.ID_Person != P.ID_Person
);

SELECT SUM(Sur_cnt.cnt)
FROM (
	SELECT COUNT(*) AS cnt
	FROM Person P
	GROUP BY P.Surname
	HAVING COUNT(*) > 1
) Sur_cnt;

-- 33.
/*Выбрать названия блюд с одинаковым набором ингредиентов.*/

SELECT D1.Dish_title, D2.Dish_title
FROM Dishes D1
JOIN Dishes D2
	ON D1.ID_dishes < D2.ID_dishes
WHERE EXISTS (
    SELECT 1 FROM Ingredients_Dishes WHERE ID_Dishes = D1.ID_dishes
) 
AND EXISTS (
    SELECT 1 FROM Ingredients_Dishes WHERE ID_Dishes = D2.ID_dishes  
)
AND NOT EXISTS (
    SELECT ID_Ingredients
    FROM Ingredients_Dishes ID1
    WHERE ID1.ID_Dishes = D1.ID_dishes
    EXCEPT
    SELECT ID_Ingredients  
    FROM Ingredients_Dishes ID2
    WHERE ID2.ID_Dishes = D2.ID_dishes
)
AND NOT EXISTS (
    SELECT ID_Ingredients
    FROM Ingredients_Dishes ID2
    WHERE ID2.ID_Dishes = D2.ID_dishes
    EXCEPT
    SELECT ID_Ingredients
    FROM Ingredients_Dishes ID1
    WHERE ID1.ID_Dishes = D1.ID_dishes
);

-- 34. 
/*Выбрать тройку самых популярных блюд. */
SELECT 
    D.Dish_title,
    COUNT(OD.ID_order)
FROM Dishes D
JOIN Order_Dishes OD ON D.ID_dishes = OD.ID_dishes
GROUP BY D.ID_dishes, D.Dish_title
ORDER BY COUNT(OD.ID_order) DESC
LIMIT 3;

-- 35.
/*Выбрать фамилию, имя, отчество заказчика, 
совершившего заказ с максимальной суммой. */
SELECT P.Surname, P.First_name, P.Patonymic, O.Order_cost
FROM Orders O
JOIN Regular_Client R
	ON O.FK_ID_Person = R.ID_Person
JOIN Person P 
	ON R.ID_Person = P.ID_Person
WHERE O.Order_cost = (
    SELECT MAX(Order_cost) 
    FROM Orders
    WHERE FK_ID_Statuses != (
		SELECT ID_Statuses 
		FROM Statuses 
		WHERE Status_title = 'Отменён'
	)
);

-- 36.
/*Выбрать актуальную должность для каждого сотрудника 
на определенную дату в прошлом. */
SELECT 
    P.Surname, P.First_name, P.Patonymic, J.Job_title
FROM Workers W 
JOIN Person P ON P.ID_Person = W.ID_Person
JOIN Jobs_Workers JW ON P.ID_Person = JW.ID_Person
JOIN Jobs J ON JW.ID_Job = J.ID_Job
WHERE JW.Date_of_entry <= '2025-02-01'
  AND (JW.Date_of_completion IS NULL OR JW.Date_of_completion >= '2025-02-01')
ORDER BY J.ID_job, P.Surname;

-- 37.
/*Выбрать фамилии, имена, отчества сотрудников, 
которые не закреплены за столиками.*/
SELECT 
    P.Surname,
    P.First_name,
    P.Patonymic
FROM Person P
JOIN Waiters W ON W.ID_Person = P.ID_Person
WHERE NOT EXISTS (
    SELECT W.ID_Person
    FROM Shift_Summary SS
    WHERE SS.ID_Person = W.ID_Person
);












