
DROP database IF EXISTS sql_assessment;

CREATE database IF NOT EXISTS sql_assessment;

-- creating the database schema

-- table salesman
CREATE TABLE IF NOT EXISTS salesman(
    salesman_id INT NOT NULL,
    name VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    commission REAL,
    PRIMARY KEY(salesman_id)
	
    );


-- table customer
CREATE TABLE IF NOT EXISTS customer(
    customer_id INT NOT NULL,
    cust_name VARCHAR(50) NOT NULL,
    city VARCHAR(50),
    grade SMALLINT,
	salesman_id INT,
    PRIMARY KEY(customer_id),
	CONSTRAINT fk_2_salesman_id FOREIGN KEY (salesman_id) REFERENCES salesman(salesman_id)
    );
	
	
-- table orders
CREATE TABLE IF NOT EXISTS orders(
    ord_no INT NOT NULL,
    purch_amt DECIMAL(10,2) NOT NULL,
    ord_date DATE,
    customer_id INT NOT NULL,
	salesman_id INT NOT NULL,
	
    PRIMARY KEY(ord_no),
	CONSTRAINT fk_customer_id FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
	CONSTRAINT fk_salesman_id FOREIGN KEY (salesman_id) REFERENCES salesman(salesman_id)
	
    );


-- table nobel_win
CREATE TABLE IF NOT EXISTS nobel_win(
    id INT NOT NULL AUTO_INCREMENT,
    year_won YEAR,
    subject VARCHAR(50),
	winner VARCHAR(80),
	country VARCHAR(50),
	category VARCHAR(50),
	
    PRIMARY KEY(id)
	
    );


-- loading the data

-- in the salesman table
LOAD DATA LOCAL INFILE 'D:\\Utilisateurs\\Aubery\\Downloads\\Python and SQL Quiz\\Python and SQL Quiz\\salesman.csv'  
INTO TABLE salesman
FIELDS TERMINATED BY ',' ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(salesman_id,name,city,commission);

-- in the customer table
LOAD DATA LOCAL INFILE 'D:\\Utilisateurs\\Aubery\\Downloads\\Python and SQL Quiz\\Python and SQL Quiz\\customer.csv' 
INTO TABLE customer
FIELDS TERMINATED BY ',' ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES 
(customer_id,cust_name,city,grade,salesman_id);
          


-- in the orders table
LOAD DATA LOCAL INFILE 'D:\\Utilisateurs\\Aubery\\Downloads\\Python and SQL Quiz\\Python and SQL Quiz\\orders.csv'  
INTO TABLE orders
FIELDS TERMINATED BY ',' ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ord_no,purch_amt,ord_date,customer_id,salesman_id);

-- in the nobel_win table
LOAD DATA LOCAL INFILE 'D:\\Utilisateurs\\Aubery\\Downloads\\Python and SQL Quiz\\Python and SQL Quiz\\nobel_win.csv'  
INTO TABLE nobel_win
FIELDS TERMINATED BY ',' ENCLOSED BY ''
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(year_won,subject,winner,country,category);



-- queries

-- Question 1:
	-- Using the nobel_win table, write a SQL query to show all the winners of Nobel prize in
	-- the year 1970 except the subject Physiology and Economics.

SELECT winner,subject FROM nobel_win
WHERE year_won='1970'
AND subject NOT IN( 'physiology','economics');


-- Question 2
    -- Using the `order` table, write a SQL statement to exclude the rows which satisfy:
    -- (1) Order dates are 2012-08-17 and purchase amount is below 1000
    -- OR
    -- (2) Customer id is greater than 3005 and purchase amount is below 1000.

SELECT * FROM orders
WHERE NOT((ord_date='2012-08-17' AND purch_amt <=1000)
			OR (customer_id>=3005 AND purch_amt<=1000) ) ;


-- Question 3
    -- Using the `customer` table, write a SQL statement to find the information of all
    -- customers whose first name and/or last name ends with "n".
    -- E.g. Ryan Reynolds, Ed Sheeran, Elton John (note: these names are just examples)

SELECT * FROM customer
WHERE cust_name LIKE "%n" ;


-- Question 4
    -- Using the `orders` table, write a SQL statement to find the highest purchase
    -- amount ordered by each customer on a particular date with their ID, order date,
    -- and highest purchase amount.

SELECT DISTINCT customer_id, ord_date AS order_date, (SELECT MAX(purch_amt) FROM orders AS o_sub WHERE o_main.customer_id= o_sub.customer_id) AS highest_purchase_amount
FROM orders AS o_main ;


-- Question 5
    -- Using the `salesman` and `customer` tables, write a SQL statement to prepare a list
    -- with the salesman name, customer name, and cities for the salesmen and customer who
    -- belong to the same city.

SELECT s.name AS salesman, c.cust_name AS customer,c.city
FROM customer AS c
INNER JOIN salesman AS s
ON c.salesman_id = s.salesman_id AND c.city=s.city
ORDER BY c.customer_id,s.salesman_id;

