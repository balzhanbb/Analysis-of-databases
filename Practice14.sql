create database practice14;
use practice14;

create table Customers (
    customer_id int primary key,
    name varchar(100) not null,
    email varchar(100) not null
);

create table Orders (
    order_id int primary key,
    customer_id int not null,
    order_date date not null,
    total_amount decimal(10,2) not null,
    constraint fk_orders_customers
        foreign key (customer_id)
        references Customers(customer_id)
);

create table Users (
    user_id int primary key,
    username varchar(50) not null,
    email varchar(100) not null,
    constraint uq_users_username unique (username),
    constraint uq_users_email unique (email)
);

create table Products (
    product_id int primary key,
    name varchar(100) not null,
    category_id int not null,
    price decimal(10,2) not null,
    stock_quantity int not null,
    constraint chk_products_price check (price >= 0),
    constraint chk_products_stock check (stock_quantity >= 0)
);
create table Employees (
    employee_id int primary key,
    department_id int not null,
    last_name varchar(100) not null,
    hire_date date not null
);
insert into Customers (customer_id, name, email) values
(1, 'Alice Johnson', 'alice@example.com'),
(2, 'Bob Smith', 'bob@example.com'),
(3, 'Charlie Brown', 'charlie@example.com'),
(101, 'David Lee', 'david101@example.com'),
(102, 'Emma Wilson', 'emma102@example.com');

insert into Orders (order_id, customer_id, order_date, total_amount) values
(1001, 1,   '2026-01-10', 120.50),
(1002, 2,   '2026-01-12', 89.99),
(1003, 101, '2026-02-01', 250.00),
(1004, 101, '2026-02-10', 75.25),
(1005, 3,   '2026-03-05', 310.40),
(1006, 101, '2026-03-18', 40.00),
(1007, 102, '2026-04-01', 560.00);

insert into Users (user_id, username, email) values
(1, 'tamirlan', 'tamirlan@example.com'),
(2, 'amira', 'amira@example.com'),
(3, 'nurs', 'nurs@example.com');

insert into Products (product_id, name, category_id, price, stock_quantity) values
(1, 'Laptop',      5, 1200.00, 10),
(2, 'Mouse',       5, 25.00,   100),
(3, 'Keyboard',    5, 80.00,   50),
(4, 'Monitor',     5, 220.00,  20),
(5, 'Desk Lamp',   3, 45.00,   30),
(6, 'Headphones',  5, 150.00,  15),
(7, 'USB Cable',   5, 12.00,   200),
(8, 'Office Chair',2, 300.00,  5);

insert into Employees (employee_id, department_id, last_name, hire_date) values
(1, 3, 'Jackson',  '2020-05-10'),
(2, 3, 'Johnson',  '2021-07-15'),
(3, 2, 'James',    '2022-01-20'),
(4, 3, 'Brown',    '2019-11-01'),
(5, 3, 'Jones',    '2023-03-12'),
(6, 1, 'Jordan',   '2024-06-30'),
(7, 3, 'Taylor',   '2025-02-14');

-- 1.
create index idx_orders_customer_id
on Orders(customer_id);

select order_id, customer_id, order_date, total_amount
from Orders
where customer_id = 101
order by order_date;

-- 2. 
create index idx_products_category_price
on Products(category_id, price);

select product_id, name, category_id, price, stock_quantity
from Products
where category_id = 5
  and price > 100
order by price asc;

-- 3.
create index idx_employees_department_lastname
on Employees(department_id, last_name);

select employee_id, department_id, last_name, hire_date
from Employees
where department_id = 3
  and last_name like 'J%';

-- 1.
insert into Orders (order_id, customer_id, order_date, total_amount)
values (2001, 9999, '2026-04-20', 99.99);

-- 2.
insert into Users (user_id, username, email)
values (4, 'tamirlan', 'newmail@example.com');

-- 3.
insert into Users (user_id, username, email)
values (5, 'another_user', 'tamirlan@example.com');

-- 4.
insert into Products (product_id, name, category_id, price, stock_quantity)
values (9, 'Broken Laptop', 5, -500.00, 3);

-- 5.
insert into Products (product_id, name, category_id, price, stock_quantity)
values (10, 'Phantom Mouse', 5, 15.00, -7);

