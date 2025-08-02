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

call find_cust_info(1,100);

delimiter $
drop procedure if exists find_cust_info_sort $
create procedure find_cust_info_sort
(
	cust_id int,
    page_size int,
    sort_column text,
    sort_direction text
)
begin

	set @sql_query = concat('
		select cust.customer_id, cust.name, status, 
		date_format(order_date,"%d-%m-%y") order_date,
		prod.name, category, round(price * quantity,2) total
		from customers cust
		join orders ods on cust.customer_id = ods.customer_id
		join order_items o_its on ods.order_id = o_its.order_id
		join products prod on o_its.product_id = prod.product_id
		where cust.customer_id = ',cust_id,
        ' order by ',sort_column, 
        if(upper(sort_direction) = "DESC", " DESC"," ASC")
        ,
		' limit ', page_size
        );
        
        
        prepare stmnt from @sql_query;
        execute stmnt;
        deallocate prepare stmnt;
    
	
    
end $

delimiter ;
/*
Error Code: 1064. You have an error in your SQL syntax; 
check the manual that corresponds to your MySQL server version 
for the right syntax to use near '101' at line 1

*/
call find_cust_info_sort(1,100,"total","Desc");



drop procedure if exists find_cust_info;
drop procedure if exists find_cust_info_sort;


-- procedure with - out params

select * from orders;
select count(*) from orders
where status = "Returned";
select count(*) from orders
where status = "Delivered";
select distinct status from orders;
delimiter $$
create procedure count_by_status(
	prod_status varchar(50),
    out prod_count int
)
begin
	select count(*) into prod_count from orders
	where status = prod_status;
    
    
end $$
delimiter ;

select @count_of_prod;
call count_by_status("Delivered", @count_of_prod);
select @count_of_prod;

call count_by_status("Pending", @pending_prod);
select @pending_prod;

-- inout

select * from orders;
select count(*) from orders
where customer_id = 4;

delimiter $

create procedure count_by_id(
	inout variable int
)
begin
	select count(*) into variable from orders
	where customer_id = variable;
end $
delimiter ;


set @id = 10;
select @id;

call count_by_id(@id);

select @id;


-- Functions (Block Of SQL Statements which we can reuse again and again)
/*
User Defined Function
1. Function should return something single value (scalar function)
2. It is deterministic
*/

-- create a fn which acept customer_num and return its name

delimiter $

create function get_name(customer_number int)
returns varchar(50)
deterministic
begin
	declare cust_name varchar(50);
    
    select name into cust_name from customers
    where customer_id = customer_number;
    
    return cust_name;
    
end $

delimiter ;

select get_name(10);
select get_name(1000);

select *, get_name(customer_id) cust_name from orders;

select * from order_items
where product_id = 8;
select sum(quantity) from order_items
where product_id = 8;

delimiter $

create function get_total_quantity(prod_id int)
returns int 
deterministic
begin
	declare sold_quantity int;
    
    select sum(quantity) into sold_quantity from order_items
	where product_id = prod_id;
    
    return sold_quantity;
    
end $
delimiter ;

select get_total_quantity(8);

select *, get_total_quantity(product_id) sold_quantities 
from products;

select distinct category from products; 

select category, group_concat(name), count(*) from products
group by category; 
select category, group_concat(name separator ", "), count(*) from products
group by category; 