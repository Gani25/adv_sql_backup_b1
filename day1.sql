create database sql_backup;

use sql_backup;

show tables;
desc customers;
select * from customers;

-- Joins (It is used to combine result set of 2 or more tables)

select * from customers;
select * from orders;
select * from order_items;
select * from products;

select cust.customer_id, cust.name, status, 
date_format(order_date,"%d-%m-%y") order_date,
prod.name, category, round(price * quantity,2) total
from customers cust
join orders ods on cust.customer_id = ods.customer_id
join order_items o_its on ods.order_id = o_its.order_id
join products prod on o_its.product_id = prod.product_id
order by total desc;

-- VIEWS 
/*
1. It is a virtual table based on select statement
2. It is a database object.
*/

-- Stored Procedure
/*
1. Precompiled SQL statements where we can pass parameters
2. It is a Database Object
3. Types of Parameters are
	a. in
    b. out
    c. inout
*/

delimiter $

create procedure pr1()
begin
	select * from customers;
	select * from orders;
	select * from order_items;
	select * from products;
end $

delimiter ;

call pr1();
call pr1();
drop procedure pr1;
-- Procedure with in parameters

delimiter $
drop procedure if exists find_cust_info $
create procedure find_cust_info
(
	cust_id int,
    page_size int
)
begin
	select cust.customer_id, cust.name, status, 
	date_format(order_date,"%d-%m-%y") order_date,
	prod.name, category, round(price * quantity,2) total
	from customers cust
	join orders ods on cust.customer_id = ods.customer_id
	join order_items o_its on ods.order_id = o_its.order_id
	join products prod on o_its.product_id = prod.product_id
    where cust.customer_id = cust_id
    limit page_size;
    
end $

delimiter ;

call find_cust_info(10,2);