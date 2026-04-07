ALTER TABLE Shift_Summary DROP ID_hall_tables;
ALTER TABLE Shift_Summary DROP ID_Person;
ALTER TABLE Shift_Summary DROP ID_Shifts;
ALTER TABLE Order_Dishes DROP ID_Order;
ALTER TABLE Order_Dishes DROP ID_Dishes;
ALTER TABLE Dishes_Menu DROP ID_Menu;
ALTER TABLE Dishes_Menu DROP ID_Dishes;
ALTER TABLE Ingredients_Dishes DROP ID_Ingredients;
ALTER TABLE Ingredients_Dishes DROP ID_Dishes;
ALTER TABLE Jobs_Workers DROP ID_job;
ALTER TABLE Jobs_Workers DROP ID_person;
ALTER TABLE Orders DROP FK_ID_Person;
ALTER TABLE Orders DROP FK_ID_Statuses;
ALTER TABLE Waiters DROP ID_Person;
ALTER TABLE Other DROP ID_Person;
ALTER TABLE Workers DROP ID_Person;
ALTER TABLE Regular_Client DROP ID_Person;
ALTER TABLE Hall_tables DROP ID_hall;

DROP TABLE IF EXISTS Jobs;
DROP TABLE IF EXISTS Jobs_Workers;
DROP TABLE IF EXISTS Person;
DROP TABLE IF EXISTS Workers;
DROP TABLE IF EXISTS Regular_Client;
DROP TABLE IF EXISTS Waiters;
DROP TABLE IF EXISTS Other;
DROP TABLE IF EXISTS Halls;
DROP TABLE IF EXISTS Hall_Tables;
DROP TABLE IF EXISTS Shifts;
DROP TABLE IF EXISTS Shift_Summary;
DROP TABLE IF EXISTS Statuses;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Order_Dishes;
DROP TABLE IF EXISTS Dishes;
DROP TABLE IF EXISTS Menu;
DROP TABLE IF EXISTS Dishes_menu;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Ingredients;
DROP TABLE IF EXISTS Ingredients_dishes;

/*Создание таблиц*/
CREATE TABLE Jobs
(ID_Job SERIAL PRIMARY KEY,
Job_title VARCHAR(50) NOT NULL,
Salary NUMERIC(10, 2) NOT NULL);
CREATE TABLE Jobs_Workers
(ID_Job INTEGER,
ID_Person INTEGER,
Date_of_entry DATE NOT NULL,
Date_of_completion DATE);
CREATE TABLE Person
(ID_Person Serial PRIMARY KEY,
Surname VARCHAR(150) NOT NULL,
First_name VARCHAR(70) NOT NULL,
Patonymic VARCHAR(100),
Phone_number CHAR(11) NOT NULL);
CREATE TABLE Workers
(ID_Person INTEGER,
Sex BOOLEAN NOT NULL,
Address VARCHAR(100) NOT NULL);
CREATE TABLE Regular_Client
(ID_Person INTEGER,
Discount_size SMALLINT NOT NULL,
Card_number CHAR(16) NOT NULL);
CREATE TABLE Waiters
(ID_Person INTEGER);
CREATE TABLE Other
(ID_Person INTEGER);
CREATE TABLE Halls
(ID_hall SERIAL PRIMARY KEY,
Halls_title VARCHAR(30) NOT NULL);
CREATE TABLE Hall_Tables
(ID_hall_tables SERIAL PRIMARY KEY,
ID_hall INTEGER,
Table_number SMALLINT NOT NULL);
CREATE TABLE Shifts
(ID_shifts SERIAL PRIMARY KEY,
Morning_Evening BOOLEAN NOT NULL,
Shifts_Date DATE NOT NULL);
CREATE TABLE Shift_Summary
(ID_hall_tables INTEGER,
ID_Person INTEGER,
ID_Shifts INTEGER,
Count_of_work_hours SMALLINT NOT NULL);
CREATE TABLE Statuses
(ID_Statuses SERIAL PRIMARY KEY,
Status_title VARCHAR(15) NOT NULL);
CREATE TABLE Orders
(ID_order SERIAL PRIMARY KEY,
FK_ID_Person INTEGER,
FK_ID_Statuses INTEGER,
Commentary TEXT,
Order_cost NUMERIC(10, 2),
Date_order DATE NOT NULL);
CREATE TABLE Order_Dishes
(ID_order INTEGER,
ID_dishes INTEGER,
Dish_count SMALLINT NOT NULL);
CREATE TABLE Dishes
(ID_dishes SERIAL PRIMARY KEY,
ID_Categories INTEGER,
Dish_title VARCHAR(40) NOT NULL,
Dish_cost NUMERIC(10, 2) NOT NULL,
Dish_mass NUMERIC(5, 2) NOT NULL);
CREATE TABLE Menu
(ID_menu SERIAL PRIMARY KEY,
Create_date DATE NOT NULL,
Menu_title VARCHAR(30) NOT NULL);
CREATE TABLE Dishes_menu
(ID_Dishes INTEGER,
ID_Menu INTEGER,
Description TEXT NOT NULL);
CREATE TABLE Categories
(ID_categories SERIAL PRIMARY KEY,
ID_Parent_Category INTEGER,
Category_title VARCHAR(20) NOT NULL);
CREATE TABLE Ingredients
(ID_ingredients SERIAL PRIMARY KEY,
Ingredients_title VARCHAR(30) NOT NULL);
CREATE TABLE Ingredients_dishes
(ID_Ingredients INTEGER,
ID_Dishes INTEGER,
Ingredients_count NUMERIC(10,2) NOT NULL);

/*Внешние ключи*/
ALTER TABLE Jobs_Workers
ADD CONSTRAINT FK_ID_Job FOREIGN KEY (ID_Job) REFERENCES Jobs(ID_Job);
ALTER TABLE Jobs_Workers
ADD CONSTRAINT FK_ID_Person FOREIGN KEY (ID_Person) REFERENCES Person(ID_Person);
ALTER TABLE Workers
ADD CONSTRAINT FK_ID_Person FOREIGN KEY (ID_Person) REFERENCES Person(ID_Person);
ALTER TABLE Workers 
ADD UNIQUE (ID_Person);
ALTER TABLE Regular_Client
ADD CONSTRAINT FK_ID_Person FOREIGN KEY (ID_Person) REFERENCES Person(ID_Person);
ALTER TABLE Regular_Client
ADD UNIQUE (ID_Person);
ALTER TABLE Waiters
ADD CONSTRAINT FK_ID_Person FOREIGN KEY (ID_Person) REFERENCES Workers(ID_Person);
ALTER TABLE Waiters 
ADD UNIQUE (ID_Person);
ALTER TABLE Other
ADD CONSTRAINT FK_ID_Person FOREIGN KEY (ID_Person) REFERENCES Workers(ID_Person);
ALTER TABLE Other
ADD UNIQUE (ID_Person);
ALTER TABLE Hall_Tables
ADD CONSTRAINT FK_ID_hall FOREIGN KEY (ID_Hall) REFERENCES Halls(ID_Hall);
ALTER TABLE Shift_Summary
ADD CONSTRAINT FK_ID_tables FOREIGN KEY (ID_hall_tables) REFERENCES Hall_tables(ID_hall_tables);
ALTER TABLE Shift_Summary
ADD CONSTRAINT FK_ID_Person FOREIGN KEY (ID_Person) REFERENCES Waiters(ID_Person);
ALTER TABLE Shift_Summary
ADD CONSTRAINT FK_ID_Shifts FOREIGN KEY (ID_Shifts) REFERENCES Shifts(ID_Shifts);
ALTER TABLE Orders
ADD CONSTRAINT FK_ID_Person FOREIGN KEY (FK_ID_Person) REFERENCES Regular_Client(ID_Person);
ALTER TABLE Orders
ADD CONSTRAINT FK_ID_Statuses FOREIGN KEY (FK_ID_Statuses) REFERENCES Statuses(ID_Statuses);
ALTER TABLE Order_Dishes
ADD CONSTRAINT ID_Dishes FOREIGN KEY (ID_Dishes) REFERENCES Dishes(ID_dishes);
ALTER TABLE Order_Dishes
ADD CONSTRAINT ID_Orders FOREIGN KEY (ID_Order) REFERENCES Orders(ID_order);
ALTER TABLE Dishes
ADD CONSTRAINT ID_Categories FOREIGN KEY(ID_Categories) REFERENCES Categories(ID_Categories);
ALTER TABLE Categories
ADD CONSTRAINT FK_Parent_Category FOREIGN KEY (ID_Parent_Category) REFERENCES Categories(ID_Categories);
ALTER TABLE Dishes_Menu
ADD CONSTRAINT FK_ID_Dish FOREIGN KEY (ID_Dishes) REFERENCES Dishes(ID_Dishes);
ALTER TABLE Dishes_Menu
ADD CONSTRAINT FK_ID_Menu FOREIGN KEY (ID_Menu) REFERENCES Menu(ID_Menu);
ALTER TABLE Ingredients_Dishes
ADD CONSTRAINT FK_ID_Ingredients FOREIGN KEY (ID_Ingredients) REFERENCES Ingredients(ID_Ingredients);
ALTER TABLE Ingredients_Dishes
ADD CONSTRAINT FK_ID_Dish FOREIGN KEY (ID_Dishes) REFERENCES Dishes(ID_Dishes);

/*Ограничения*/
ALTER TABLE Jobs
ADD UNIQUE (Job_title);
ALTER TABLE Jobs
ADD CONSTRAINT CH_Salary CHECK (Salary > 0);
ALTER TABLE Jobs_Workers
ADD CONSTRAINT CH_Date_of_completion CHECK (Date_of_completion > Date_of_entry);
ALTER TABLE Person
ADD UNIQUE (Phone_number);
ALTER TABLE Regular_Client
ADD UNIQUE (Card_Number);
ALTER TABLE Regular_Client
ADD CONSTRAINT CH_Discount_Size CHECK (Discount_Size BETWEEN 0 AND 99);
ALTER TABLE Halls
ADD UNIQUE (Halls_title);
ALTER TABLE Hall_Tables
ADD UNIQUE (ID_Hall, Table_Number);
ALTER TABLE Hall_Tables
ADD CONSTRAINT CH_Table_Number CHECK (Table_Number > 0);
ALTER TABLE Shifts
ADD UNIQUE (Shifts_Date, Morning_Evening);
ALTER TABLE Shift_Summary
ADD CONSTRAINT CH_Count_of_work_hours CHECK (Count_of_work_hours > 0);
ALTER TABLE Statuses
ADD UNIQUE (Status_title);
ALTER TABLE Order_Dishes
ADD CONSTRAINT CH_Dish_count CHECK (Dish_count > 0);
ALTER TABLE Dishes
ADD UNIQUE (Dish_title);
ALTER TABLE Dishes
ADD CONSTRAINT CH_Dish_cost CHECK (Dish_cost > 0);
ALTER TABLE Dishes
ADD CONSTRAINT CH_Dish_mass CHECK (Dish_mass > 0);
ALTER TABLE Menu
ADD UNIQUE (Menu_title);
ALTER TABLE Categories
ADD UNIQUE (Category_title);
ALTER TABLE Ingredients
ADD UNIQUE (Ingredients_title);
ALTER TABLE Ingredients_Dishes
ADD CONSTRAINT CH_Ingredient_Count CHECK (Ingredients_Count > 0);