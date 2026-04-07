-- 1 +
/*Выбрать все данные о сотрудниках.*/
SELECT P.Surname, P.First_name, P.Patonymic, P.phone_number, W.sex, W.address
FROM Workers W JOIN Person P
	ON P.ID_Person = W.ID_Person;

-- 2 +
/*Вывести фамилию и инициалы, телефон сотрудников. Ре
зультат отсортировать по фамилии в порядке обратном лексико
графическому.  */
SELECT CONCAT(P.Surname, ' ', LEFT(P.First_name, 1), ' ', LEFT(P.Patonymic, 1)) AS FIO, P.phone_number
FROM Workers W JOIN Person P
	ON P.ID_Person = W.ID_Person
ORDER BY P.surname DESC;

-- 3 +
/*Выбрать категории блюд, которые не входят в другие ка
тегории. Результат отсортировать по названию категории в лекси
кографическом порядке.  */
SELECT Category_title
FROM Categories
WHERE ID_parent_category IS NULL
ORDER BY Category_title;

-- 4 +
/*Выбрать все данные о клиентах с четными номерами карт. 
Результат отсортировать по длине фамилии, имени, отчества кли
ента и по номеру карты. */
SELECT P.surname, P.first_name, P.patonymic, P.phone_number, R.discount_size, R.card_number
FROM Regular_client R JOIN Person P
	ON R.ID_Person = P.ID_Person
WHERE RIGHT(Card_number, 1) IN ('0', '2', '4', '6', '8')
ORDER BY LENGTH(P.Surname), LENGTH(P.First_name), LENGTH(P.Patonymic), LENGTH(R.card_number);

-- 5 + 
/*Выбрать фамилии, имена, отчества клиентов, в фамилии 
которых есть «-ов» и/или «ли» (независимо от регистра). */
SELECT P.surname, P.first_name, P.patonymic
FROM Regular_client R JOIN Person P
	ON R.ID_Person = P.ID_Person
WHERE LOWER(P.surname) LIKE '%ов%' OR LOWER(P.surname) LIKE '%ли%';

-- 6 +
/*Выбрать названия блюд, относящиеся к категориям с id 
равным 1, 3, 4, 5, 9. */
SELECT D.Dish_title
FROM Dishes AS D
WHERE D.ID_categories IN (1, 3, 4, 5, 9);

-- 7 + 
/*Выбрать id_заказов, в комментариях к которым 
есть два знака «%»*/
SELECT O.ID_Order
FROM Orders O
WHERE O.commentary IS NOT NULL AND (O.commentary LIKE '%@%%@%%' ESCAPE '@');

-- 8 +
/*Выбрать id и названия должностей, оклад которых от 
30 000 до 60 000. */
SELECT job_title
FROM Jobs
WHERE salary BETWEEN 30000 AND 60000;

-- 9 +
/*Выбрать все данные о заказах вчерашнего дня со скидкой.*/
SELECT O.ID_Order, O.FK_ID_Person, O.FK_ID_Statuses, O.Commentary, O.Date_order
FROM Orders O LEFT JOIN Regular_Client R
	ON O.FK_ID_Person = R.ID_Person
WHERE CURRENT_DATE - O.Date_order = 1 AND R.Discount_Size > 0;

-- 10 +
/*Выбрать все данные о заказах, совершенных в прошлом месяце. */
SELECT *
FROM Orders
WHERE DATE_TRUNC('month', Date_order) + INTERVAL '1 month' = DATE_TRUNC('month', CURRENT_DATE);

-- 11 +
/*Вывести среднюю цену блюд в ресторане.*/
SELECT AVG(Dish_cost)
FROM Dishes;

-- 12 +
/*Выбрать максимальную и минимальную суммы заказов. */
SELECT MAX(O.Order_cost), MIN(O.Order_cost)
FROM Orders O

-- 13 +
/*Выбрать общее количество заказов за прошлый месяц. */
SELECT COUNT(ID_order)
FROM Orders
WHERE DATE_TRUNC('month', Date_order) + INTERVAL '1 month' = DATE_TRUNC('month', CURRENT_DATE);

-- 14 +
/*Вывести стоимость самого дорогого заказа, совершенного вчера.*/
SELECT MAX(O.Order_cost)
FROM Orders O
WHERE CURRENT_DATE - O.Date_order = 1;

-- 15 +
/*Выбрать фамилию, имя, отчество сотрудника и 
номера столиков, им обслуживаемых. */
SELECT P.Surname, P.First_name, P.Patonymic, SS.ID_Hall_Tables
FROM Waiters W
	JOIN Person P ON W.ID_Person = P.ID_Person
	JOIN Shift_Summary SS ON SS.ID_Person = W.ID_Person;

	