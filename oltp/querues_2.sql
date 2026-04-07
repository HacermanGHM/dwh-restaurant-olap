-- 16 +
/* Выбрать название блюд, количество, комментарии, сум
му без скидки клиента Иванова Иван Ивановича, сделавшего заказ 
вчера. Результат отсортировать по возрастанию стоимости блюд и 
названию блюд в порядке обратном лексикографическому.*/

SELECT D.Dish_title, OD.dish_count, O.Commentary, D.dish_cost
FROM Regular_client R
	JOIN Person P ON R.ID_Person = P.ID_Person
	JOIN Orders O ON O.FK_ID_Person = R.ID_Person
	JOIN Order_Dishes OD ON O.ID_order = OD.ID_order
	JOIN Dishes D ON OD.ID_dishes = D.ID_dishes
WHERE P.Surname = 'Иванов' AND O.Date_order = CURRENT_DATE - interval '1 day'
ORDER BY D.dish_cost, D.Dish_title DESC;

-- 17 +
/*Выбрать фамилию, имя, отчество клиента, который все
гда заказывает разные блюда и ни разу не повторил свой заказ */

SELECT P.Surname, P.First_Name, P.Patonymic
FROM Person P
	JOIN Orders O ON O.FK_ID_Person = P.ID_Person
	JOIN Order_Dishes OD ON O.ID_order = OD.ID_order
GROUP BY P.ID_Person
HAVING COUNT(OD.ID_dishes) = COUNT(DISTINCT OD.ID_dishes);

-- 18 +
/*Выбрать фамилию, имя, отчество сотрудника и 
количество столиков, им обслуживаемых. */

SELECT P.Surname, P.First_name, P.Patonymic, COUNT(DISTINCT SS.ID_Hall_Tables)
FROM Waiters W
	JOIN Person P ON W.ID_Person = P.ID_Person
	JOIN Shift_Summary SS ON SS.ID_Person = W.ID_Person
GROUP BY P.ID_Person, P.Surname, P.First_name, P.Patonymic;

-- 19 +
/*Для каждого месяца вывести количество клиентов, сде
лавших заказ какого-то определенного блюда (какого, укажите 
сами)*/

SELECT TO_CHAR(O.Date_order, 'YYYY-MM'), COUNT(DISTINCT O.FK_ID_Person)
FROM Orders O
	JOIN Order_Dishes OD ON O.ID_order = OD.ID_order
	JOIN Dishes D ON OD.ID_dishes = D.ID_dishes
WHERE D.Dish_title = 'Компот'
GROUP BY TO_CHAR(O.Date_order, 'YYYY-MM')
ORDER BY TO_CHAR(O.Date_order, 'YYYY-MM');

-- 20 +
/*Выбрать клиентов, которые посещали ресторан более 2 
раз в месяц. */
SELECT P.Surname, P.First_name, P.Patonymic, TO_CHAR(O.Date_order, 'YYYY-MM'), COUNT(*)
FROM Orders O
	JOIN Person P ON O.FK_ID_Person = P.ID_Person
	JOIN Regular_Client RC ON P.ID_Person = RC.ID_Person
GROUP BY P.ID_Person, P.Surname, P.First_name, P.Patonymic, TO_CHAR(O.Date_order, 'YYYY-MM')
HAVING COUNT(*) > 2;

-- 21 + 
/* Выбрать названия блюд, которые заказывали в текущем 
месяце не более двух клиентов. */

SELECT D.Dish_title, COUNT(DISTINCT O.FK_ID_Person)
FROM Dishes D
	JOIN Order_Dishes OD ON D.ID_dishes = OD.ID_dishes
	JOIN Orders O ON OD.ID_order = O.ID_order
WHERE DATE_TRUNC('month', O.date_order) = DATE_TRUNC('month', CURRENT_DATE)
GROUP BY D.Dish_title
HAVING COUNT(DISTINCT O.FK_ID_Person) <= 2;

-- 22. !  - group person
/* Выбрать id зала, в котором более 10 столиков, и все они 
обслуживаются одним сотрудником. */

/*SELECT H.ID_hall, H.Halls_title, P.Surname, P.First_name, COUNT(HT.ID_hall_tables)
FROM Halls H
	JOIN Hall_Tables HT ON H.ID_hall = HT.ID_hall
	JOIN Shift_summary SS ON SS.ID_hall_tables = HT.ID_hall_tables
	JOIN Waiters W ON SS.ID_Person = W.ID_Person
	JOIN Person P ON W.ID_Person = P.ID_Person
GROUP BY H.ID_hall, H.Halls_title, P.ID_Person, P.Surname, P.First_name
HAVING COUNT(HT.ID_hall_tables) > 10 AND COUNT(DISTINCT P.ID_Person) = 1;*/


SELECT H.ID_hall, H.Halls_title
FROM Halls H
WHERE EXISTS (
    SELECT 1
    FROM Hall_Tables HT
    WHERE HT.ID_hall = H.ID_hall
    GROUP BY HT.ID_hall
    HAVING COUNT(*) > 10
)
AND NOT EXISTS (
    SELECT 1
    FROM Hall_Tables HT
    JOIN Shift_Summary SS ON HT.ID_hall_tables = SS.ID_hall_tables
    WHERE HT.ID_hall = H.ID_hall
    GROUP BY HT.ID_hall
    HAVING COUNT(DISTINCT SS.ID_Person) > 1
);

-- 23. +
/*Вывести в первом столбце фамилии, имена, отчества 
клиентов, посетивших ресторан сегодня, а во втором столбце, если 
скидка превышает 10 %, то слова «золотая карта», если скидка от 
5 до 10 %, то «серебряная карта», если скидка менее 5 %, то размер 
скидки, если дисконтная карта отсутствует, то вывести «-». */

SELECT CONCAT(P.Surname, ' ', P.First_name, ' ', P.Patonymic) AS FIO, 
	CASE 
		WHEN R.Discount_size >= 10 THEN 'Золотая карта'
		WHEN R.Discount_size BETWEEN 5 AND 10 THEN 'Серебрянная карта'
		WHEN R.Discount_size BETWEEN 1 AND 5 THEN R.Discount_size::TEXT
		ELSE '-'
	END AS Card
FROM Regular_client R
	JOIN Person P ON R.ID_Person = P.ID_Person
	JOIN Orders O ON O.FK_ID_Person = P.ID_Person
WHERE O.Date_order = '2025-10-29';

-- 24. !  - join а не select
/*По каждому году поквартально вывести количество 
официантов, принятых на работу. Результирующая таблица должна
содержать в первом столбце год, во втором – количество официантов,
принятых в I квартале, в третьем – количество официантов,
принятых во II квартале? и т. д.*/
SELECT 
    EXTRACT(YEAR FROM JW.Date_of_entry),
    COUNT(CASE WHEN EXTRACT(QUARTER FROM JW.Date_of_entry) = 1 THEN 1 END),
    COUNT(CASE WHEN EXTRACT(QUARTER FROM JW.Date_of_entry) = 2 THEN 1 END),
    COUNT(CASE WHEN EXTRACT(QUARTER FROM JW.Date_of_entry) = 3 THEN 1 END),
    COUNT(CASE WHEN EXTRACT(QUARTER FROM JW.Date_of_entry) = 4 THEN 1 END),
    COUNT(*)
FROM Jobs_Workers JW
	JOIN Waiters W ON JW.ID_Person = W.ID_Person
	JOIN Jobs J ON J.ID_job = JW.ID_job
WHERE Job_title = 'Официант'
GROUP BY EXTRACT(YEAR FROM JW.Date_of_entry);

-- 25. +
/*Выбрать данные обо всех сотрудниках и, если сотрудник 
обслуживает столик, то зал и номер столика.*/
SELECT DISTINCT P.Surname, P.First_name, P.Patonymic, P.Phone_number, Wo.Sex, Wo.Address, SS.ID_Hall_tables, H.Halls_title
FROM Workers Wo
	JOIN Person P ON Wo.ID_Person = P.ID_Person
	LEFT JOIN Waiters Wa ON Wa.ID_Person = Wo.ID_Person
	LEFT JOIN Shift_summary SS ON SS.ID_Person = Wa.ID_Person
	LEFT JOIN Hall_tables HT ON HT.ID_Hall_tables = SS.ID_Hall_tables
	LEFT JOIN Halls H ON HT.ID_Hall = H.ID_Hall
ORDER BY P.Surname;

-- 26. +
/*Для каждой должности выбрать количество человек, 
побывавших в этой должности. Если есть должности, которые 
никогда не были заняты, то их тоже необходимо вывести. */
SELECT J.job_title, COUNT(DISTINCT JW.ID_Person)
FROM Jobs J
LEFT JOIN Jobs_Workers JW ON J.ID_Job = JW.ID_Job
GROUP BY J.ID_Job, J.job_title;

-- 27. !  not exist
/*Выбрать название и оклад для вакантных должностей. */
SELECT Job_title, Salary
FROM Jobs J
WHERE NOT EXISTS (
    SELECT ID_Job 
    FROM Jobs_Workers JW
    WHERE JW.ID_Job = J.ID_Job AND Date_of_completion IS NULL
);

-- 28. +
/*Выбрать название должности с максимальной зарплатой. */
SELECT Job_title
FROM Jobs
WHERE Salary = (
	SELECT MAX(Salary)
	FROM Jobs
);

-- 29.
/*Выбрать таких клиентов, чьи фамилии, имена, отчества 
совпадают с фамилиями, именами, отчествами сотрудников.*/
SELECT P.Surname, P.first_name, P.patonymic
FROM Workers W
JOIN Person P
	ON W.ID_person = P.ID_person
INTERSECT
SELECT P.Surname, P.first_name, P.patonymic
FROM Regular_client R
JOIN Person P
	ON R.ID_person = P.ID_person;	

-- 30.
/*Выбрать категории, названия которых совпадают с названиями блюд. */
SELECT C.Category_title
FROM Categories C
JOIN Dishes D
	ON C.Category_title = D.dish_title;


