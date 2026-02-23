USE classicmodels;
select * from employees;
select * from products;
select * from customers;
select * from payments;
select * from orders;
select * from orderdetails;
select * from productlines;
select * from products;


#Q1. SELECT clause with WHERE, AND, DISTINCT, Wild Card (LIKE)
#a)
select employeeNumber,lastName,firstName from employees where jobTitle='Sales Rep' and reportsTo=1102;
#b)
select distinct productLine from products where productLine like '%Cars';

#2)CASE STATEMENTS for Segmentation

select customerNumber,customerName ,
case when country in ("USA","Canada") then "North America" 
	 when country in ('UK','France',"Germany") then "Europe"
     else 'other' 
end as CustomerSegment from customers;

#3)Group By with Aggregation functions and Having clause, Date and Time 
#a)
select productCode ,sum(quantityOrdered) as Total_orderd from orderdetails group by productCode order by total_orderd desc limit 10;

#b)
select monthAparna M V(paymentDate) as Payment_month,count(monthAparna M V(paymentDate)) as num_paymnet from payments  group by 1 having num_paymnet>20 order by 2 desc;


#4)CONSTRAINTS: Primary, key, foreign key, Unique, check, not null, default
#a)
create database Customers_Orders ;
use Customers_Orders ;

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_Aparna M V VARCHAR(50) NOT NULL,
    last_Aparna M V VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(20)
);


#b)
CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2) CHECK (total_amount > 0),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

#Q5. JOINS

select c.country ,count(o.customerNumber) as order_date 
from customers c  join orders o on c.customerNumber=o.customerNumber 
group by 1 
order by order_date desc 
limit 5;	


#Q6. SELF JOIN

create table project( 
EmployeeID int auto_increment primary key,
FullName varchar(50) not null,
Gender Varchar(20) not null,
CHECK (Gender IN ('Male', 'Female')),
ManagerID int);

INSERT INTO Project (FullName, Gender, ManagerID) VALUES
('Pranaya', 'Male', 3),
('Priyanka', 'Female', 1),
('Preety', 'Female', NULL),
('Anurag', 'Male', 1),
('Sambit', 'Male', 1),
('Rajesh', 'Male', 3),
('Hina', 'Female', 3);

select * from project;

SELECT 
    M.FullName AS `Manager Name`,
    E.FullName AS `Emp Name`
FROM 
    Project E
JOIN 
    Project M
ON 
    E.ManagerID = M.EmployeeID;
    
#Q7. DDL Commands: Create, Alter, ReAparna M V
create table facility(
Facility_ID int, 
Name varchar(100),
State varchar(100),
Country varchar(100));

alter table facility modify facility_ID int auto_increment primary key;
alter table facility add column City varchar(100) not null after Name ;

desc facility;

#8.Views in SQL

CREATE VIEW product_category_sales AS
SELECT 
    pl.productLine,
    SUM(od.quantityOrdered * od.priceEach) AS total_sales,
    COUNT(DISTINCT o.orderNumber) AS number_of_orders
FROM 
    ProductLines pl
JOIN 
    Products p ON pl.productLine = p.productLine
JOIN 
    OrderDetails od ON p.productCode = od.productCode
JOIN 
    Orders o ON od.orderNumber = o.orderNumber
GROUP BY 
    pl.productLine;
select * from product_category_sales;

#Q9. Stored Procedures in SQL with parameters

DELIMITER $$
CREATE  PROCEDURE `Get_country_payments`(
    IN in_year INT,
    IN in_country VARCHAR(50)
)
BEGIN
    SELECT 
        in_year AS payment_year,
        in_country AS country,
        CONCAT(ROUND(SUM(p.amount) / 1000, 0), 'K') AS total_amount
    FROM 
        Payments p
    JOIN 
        Customers c ON p.customerNumber = c.customerNumber
    WHERE 
        YEAR(p.paymentDate) = in_year
        AND c.country = in_country
    GROUP BY 
        in_year, in_country;
END$$
DELIMITER ;


call classicmodels.Get_country_payments(2003, 'France');






#Q10. Window functions - Rank, dense_rank, lead and lag

select * from customers;
select * from orders;
select * from orderdetails;
#a)
select c.customerName,count(o.orderNumber) as Order_count ,dense_rank() over (order by count(o.orderNumber) desc) order_frequence_rnk
from customers c inner join orders o on c.customerNumber=o.customerNumber group by 1 order by 2 desc;


#b)

select year,Month_Name,Total_Orders,concat(round((Total_Orders-L_count)/L_count*100,0),"",'%') as YOY from (
select  year(orderDate)as year,monthAparna M V(orderDate) as Month_Name ,count(orderNumber) as Total_Orders ,
lag(count(orderNumber)) over (order by year(orderDate) ) as L_count from orders group by 1,2) as AB;




#Q11.Subqueries and their applications

SELECT 
    productLine,
    COUNT(*) AS product_count
FROM Products
WHERE buyPrice > (SELECT AVG(buyPrice) FROM Products)
GROUP BY productLine order by 2 desc;



#Q12)ERROR HANDLING in SQL

DELIMITER //
CREATE TABLE Emp_EH (
    EmpID INT PRIMARY KEY,
    EmpName VARCHAR(100),
    EmailAddress VARCHAR(100)
);

CREATE PROCEDURE `Insert_Emp_EH`(
    IN p_EmpID INT,
    IN p_EmpName VARCHAR(100),
    IN p_EmailAddress VARCHAR(150)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred' AS ErrorMessage;
    END;

    START TRANSACTION;

    INSERT INTO Emp_EH (EmpID, EmpName, EmailAddress)
    VALUES (p_EmpID, p_EmpName, p_EmailAddress);

    COMMIT;
END $$
DELIMITER ;

CALL Insert_Emp_EH(1, 'Jeeva', 'Jeeva@example.com');
CALL Insert_Emp_EH(1, 'Virat', 'virat@example.com');



#Q13. TRIGGERS
DELIMITER //
drop table Emp_BIT;
create table Emp_BIT(Name varchar(20),Occupation varchar(20),Working_date date,Working_hours int );
 insert into Emp_BIT values
 ('Robin', 'Scientist', '2020-10-04', 12),  
('Warner', 'Engineer', '2020-10-04', 10),  
('Peter', 'Actor', '2020-10-04', 13),  
('Marco', 'Doctor', '2020-10-04', 14),  
('Brayden', 'Teacher', '2020-10-04', 12),  
('Antonio', 'Business', '2020-10-04', 11);  

CREATE DEFINER=`root`@`localhost` TRIGGER `emp_bit_BEFORE_INSERT` BEFORE INSERT ON `emp_bit` FOR EACH ROW BEGIN
if new.working_hours<0 then 
set new.working_hours=-new.Working_hours;
end if;
END$$
DELIMITER ;


insert into Emp_BIT values
 ('Virat', 'Data Analyst', '2025-10-04', -12) ;
 
 insert into Emp_BIT values
 ('Rohit', 'Data Science', '2024-11-05', -8) ;
 
 
 
 select * from Emp_BIT;
 

