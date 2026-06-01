create database restaurant_db;
use restaurant_db;

create table customers (
    customer_id int primary key,
    customer_name varchar(100) not null,
    customer_phone varchar(20) not null
);

create table tables (
    table_id int primary key,
    capacity int not null
);

create table jobs (
    job_id int primary key,
    job_title varchar(100) not null
);

create table employees (
    employee_id int primary key,
    employee_name varchar(100) not null,
    employee_surname varchar(100) not null,
    employee_phone varchar(20) not null,
    employee_salary decimal(10,2) not null,
    job_id int not null,
    foreign key (job_id) references jobs(job_id)
);

create table foods (
    food_id int primary key,
    food_name varchar(100) not null,
    food_price decimal(10,2) not null,
    food_category varchar(100) not null
);

create table payment (
    payment_id int primary key,
    payment_amount decimal(10,2) not null,
    payment_status varchar(30) not null
);

create table orders (
    order_id int primary key,
    customer_id int not null,
    table_id int not null,
    employee_id int not null,
    order_datetime datetime not null,
    payment_id int not null,
    foreign key (customer_id) references customers(customer_id),
    foreign key (table_id) references tables(table_id),
    foreign key (employee_id) references employees(employee_id),
    foreign key (payment_id) references payment(payment_id)
);

create table reservations (
    reservation_id int primary key,
    customer_id int not null,
    table_id int not null,
    start_time datetime not null,
    end_time datetime not null,
    foreign key (customer_id) references customers(customer_id),
    foreign key (table_id) references tables(table_id)
);

create table order_items (
    order_id int not null,
    food_id int not null,
    quantity int not null,
    primary key (order_id, food_id),
    foreign key (order_id) references orders(order_id),
    foreign key (food_id) references foods(food_id)
);

insert into jobs (job_id, job_title) values
(1, 'waiter'),
(2, 'cashier'),
(3, 'manager'),
(4, 'chef'),
(5, 'host');

insert into employees (employee_id, employee_name, employee_surname, employee_phone, employee_salary, job_id) values
(1, 'amir', 'bekov', '87010000001', 280000, 1),
(2, 'dana', 'serikova', '87010000002', 290000, 1),
(3, 'askar', 'nurtasov', '87010000003', 320000, 2),
(4, 'malika', 'abisheva', '87010000004', 500000, 3),
(5, 'ruslan', 'imanov', '87010000005', 450000, 4),
(6, 'aigerim', 'toktar', '87010000006', 260000, 5);

insert into tables (table_id, capacity) values
(1, 2),
(2, 2),
(3, 4),
(4, 4),
(5, 4),
(6, 6),
(7, 6),
(8, 8);

insert into customers (customer_id, customer_name, customer_phone) values
(1, 'alina', '87070000001'),
(2, 'marat', '87070000002'),
(3, 'dina', '87070000003'),
(4, 'nurik', '87070000004'),
(5, 'aida', '87070000005'),
(6, 'arlan', '87070000006'),
(7, 'madina', '87070000007'),
(8, 'dias', '87070000008'),
(9, 'ayan', '87070000009'),
(10, 'saltanat', '87070000010'),
(11, 'timur', '87070000011'),
(12, 'kamila', '87070000012'),
(13, 'askar', '87070000013'),
(14, 'indira', '87070000014'),
(15, 'adil', '87070000015'),
(16, 'zarina', '87070000016'),
(17, 'sanzhar', '87070000017'),
(18, 'aliya', '87070000018'),
(19, 'miras', '87070000019'),
(20, 'anel', '87070000020'),
(21, 'diasa', '87070000021'),
(22, 'ramazan', '87070000022'),
(23, 'aiman', '87070000023'),
(24, 'yeldar', '87070000024'),
(25, 'meruert', '87070000025'),
(26, 'azamat', '87070000026'),
(27, 'samat', '87070000027'),
(28, 'gulnaz', '87070000028'),
(29, 'karina', '87070000029'),
(30, 'erlan', '87070000030');

insert into foods (food_id, food_name, food_price, food_category) values
(1, 'caesar salad', 3200, 'salad'),
(2, 'greek salad', 3000, 'salad'),
(3, 'beet salad', 2500, 'salad'),
(4, 'chicken soup', 2800, 'soup'),
(5, 'lentil soup', 2600, 'soup'),
(6, 'ramen', 4200, 'soup'),
(7, 'margherita pizza', 4500, 'pizza'),
(8, 'pepperoni pizza', 5200, 'pizza'),
(9, 'bbq pizza', 5600, 'pizza'),
(10, 'cheeseburger', 3900, 'burger'),
(11, 'double burger', 4900, 'burger'),
(12, 'chicken burger', 4100, 'burger'),
(13, 'ribeye steak', 9800, 'main course'),
(14, 'salmon steak', 9200, 'main course'),
(15, 'beef pasta', 5300, 'main course'),
(16, 'alfredo pasta', 4800, 'main course'),
(17, 'plov', 3700, 'main course'),
(18, 'manty', 3400, 'main course'),
(19, 'fries', 1800, 'side'),
(20, 'mashed potato', 1700, 'side'),
(21, 'grilled vegetables', 2200, 'side'),
(22, 'espresso', 1200, 'drink'),
(23, 'americano', 1400, 'drink'),
(24, 'cappuccino', 1700, 'drink'),
(25, 'latte', 1900, 'drink'),
(26, 'tea pot', 1600, 'drink'),
(27, 'cola', 1000, 'drink'),
(28, 'orange juice', 1500, 'drink'),
(29, 'water', 700, 'drink'),
(30, 'cheesecake', 2400, 'dessert'),
(31, 'tiramisu', 2600, 'dessert'),
(32, 'ice cream', 1800, 'dessert'),
(33, 'brownie', 2200, 'dessert'),
(34, 'sushi set mini', 6200, 'asian'),
(35, 'philadelphia roll', 3800, 'asian'),
(36, 'california roll', 3600, 'asian'),
(37, 'udon chicken', 4400, 'asian'),
(38, 'tempura shrimp', 4700, 'asian'),
(39, 'club sandwich', 3500, 'snack'),
(40, 'nachos', 2900, 'snack'),
(41, 'onion rings', 2100, 'snack'),
(42, 'shawarma plate', 4300, 'snack'),
(43, 'tom yum', 5100, 'soup'),
(44, 'mushroom soup', 2700, 'soup'),
(45, 'veggie pizza', 4700, 'pizza'),
(46, 'four cheese pizza', 5400, 'pizza'),
(47, 'crispy chicken', 4600, 'main course'),
(48, 'beef kebab', 5500, 'main course'),
(49, 'mojito', 2100, 'drink'),
(50, 'pancakes', 2300, 'dessert');

insert into payment (payment_id, payment_amount, payment_status) values
(1, 6400, 'paid'),
(2, 8200, 'paid'),
(3, 12400, 'paid'),
(4, 4700, 'paid'),
(5, 15800, 'paid'),
(6, 5400, 'paid'),
(7, 7600, 'paid'),
(8, 9100, 'paid'),
(9, 11200, 'paid'),
(10, 6700, 'paid'),
(11, 14500, 'paid'),
(12, 5200, 'paid'),
(13, 8800, 'paid'),
(14, 9900, 'paid'),
(15, 13400, 'paid'),
(16, 6100, 'paid'),
(17, 7200, 'paid'),
(18, 8100, 'paid'),
(19, 9600, 'paid'),
(20, 12000, 'paid'),
(21, 5400, 'paid'),
(22, 6300, 'paid'),
(23, 7800, 'paid'),
(24, 8900, 'paid'),
(25, 15500, 'paid'),
(26, 6200, 'paid'),
(27, 9700, 'paid'),
(28, 10800, 'paid'),
(29, 11300, 'paid'),
(30, 14900, 'paid'),
(31, 5100, 'paid'),
(32, 6900, 'paid'),
(33, 7600, 'paid'),
(34, 9400, 'paid'),
(35, 12800, 'paid'),
(36, 5600, 'paid'),
(37, 8700, 'paid'),
(38, 9200, 'paid'),
(39, 10100, 'paid'),
(40, 13700, 'paid'),
(41, 5900, 'paid'),
(42, 7300, 'paid'),
(43, 8400, 'paid'),
(44, 9500, 'paid'),
(45, 11900, 'paid'),
(46, 6100, 'paid'),
(47, 7900, 'paid'),
(48, 8600, 'paid'),
(49, 9800, 'paid'),
(50, 14000, 'paid'),
(51, 5300, 'paid'),
(52, 6800, 'paid'),
(53, 8200, 'paid'),
(54, 9300, 'paid'),
(55, 12500, 'paid'),
(56, 6000, 'paid'),
(57, 7700, 'paid'),
(58, 9100, 'paid'),
(59, 10400, 'paid'),
(60, 15100, 'paid');

insert into orders (order_id, customer_id, table_id, employee_id, order_datetime, payment_id) values
(1, 1, 1, 1, '2026-01-05 12:10:00', 1),
(2, 2, 3, 2, '2026-01-06 13:00:00', 2),
(3, 3, 4, 1, '2026-01-07 18:20:00', 3),
(4, 4, 2, 2, '2026-01-08 14:30:00', 4),
(5, 5, 6, 1, '2026-01-09 19:00:00', 5),
(6, 1, 3, 2, '2026-01-10 12:40:00', 6),
(7, 2, 4, 1, '2026-01-11 15:10:00', 7),
(8, 3, 5, 2, '2026-01-12 17:50:00', 8),
(9, 6, 1, 1, '2026-01-13 13:15:00', 9),
(10, 7, 7, 2, '2026-01-14 20:00:00', 10),
(11, 8, 2, 1, '2026-01-15 11:30:00', 11),
(12, 9, 3, 2, '2026-01-16 16:45:00', 12),
(13, 10, 4, 1, '2026-01-17 18:00:00', 13),
(14, 11, 5, 2, '2026-01-18 19:20:00', 14),
(15, 12, 6, 1, '2026-01-19 13:00:00', 15),
(16, 1, 1, 2, '2026-01-20 12:25:00', 16),
(17, 2, 3, 1, '2026-01-21 14:40:00', 17),
(18, 3, 7, 2, '2026-01-22 18:10:00', 18),
(19, 4, 8, 1, '2026-01-23 20:30:00', 19),
(20, 5, 2, 2, '2026-01-24 13:50:00', 20),
(21, 13, 4, 1, '2026-02-01 12:00:00', 21),
(22, 14, 5, 2, '2026-02-02 13:10:00', 22),
(23, 15, 6, 1, '2026-02-03 18:40:00', 23),
(24, 16, 2, 2, '2026-02-04 14:15:00', 24),
(25, 17, 3, 1, '2026-02-05 19:10:00', 25),
(26, 18, 1, 2, '2026-02-06 12:50:00', 26),
(27, 19, 7, 1, '2026-02-07 17:40:00', 27),
(28, 20, 8, 2, '2026-02-08 20:20:00', 28),
(29, 21, 4, 1, '2026-02-09 18:10:00', 29),
(30, 22, 5, 2, '2026-02-10 13:35:00', 30),
(31, 23, 6, 1, '2026-02-11 12:20:00', 31),
(32, 24, 3, 2, '2026-02-12 14:05:00', 32),
(33, 25, 2, 1, '2026-02-13 16:50:00', 33),
(34, 26, 1, 2, '2026-02-14 19:45:00', 34),
(35, 27, 7, 1, '2026-02-15 20:00:00', 35),
(36, 28, 8, 2, '2026-02-16 13:25:00', 36),
(37, 29, 5, 1, '2026-02-17 15:15:00', 37),
(38, 30, 4, 2, '2026-02-18 18:35:00', 38),
(39, 1, 6, 1, '2026-02-19 20:05:00', 39),
(40, 2, 2, 2, '2026-02-20 12:45:00', 40),
(41, 3, 3, 1, '2026-03-01 12:00:00', 41),
(42, 4, 4, 2, '2026-03-02 13:25:00', 42),
(43, 5, 5, 1, '2026-03-03 18:15:00', 43),
(44, 1, 1, 2, '2026-03-04 14:50:00', 44),
(45, 2, 6, 1, '2026-03-05 19:30:00', 45),
(46, 3, 7, 2, '2026-03-06 12:35:00', 46),
(47, 4, 2, 1, '2026-03-07 17:10:00', 47),
(48, 5, 3, 2, '2026-03-08 20:00:00', 48),
(49, 1, 5, 1, '2026-03-09 18:20:00', 49),
(50, 2, 8, 2, '2026-03-10 13:10:00', 50),
(51, 3, 6, 1, '2026-03-11 12:40:00', 51),
(52, 4, 4, 2, '2026-03-12 15:00:00', 52),
(53, 5, 1, 1, '2026-03-13 19:00:00', 53),
(54, 1, 2, 2, '2026-03-14 13:30:00', 54),
(55, 2, 3, 1, '2026-03-15 18:45:00', 55),
(56, 3, 7, 2, '2026-03-16 12:25:00', 56),
(57, 4, 8, 1, '2026-03-17 17:55:00', 57),
(58, 5, 6, 2, '2026-03-18 20:10:00', 58),
(59, 1, 4, 1, '2026-03-19 18:30:00', 59),
(60, 2, 5, 2, '2026-03-20 13:40:00', 60);

insert into order_items (order_id, food_id, quantity) values
(1, 8, 1),
(1, 24, 1),
(2, 13, 1),
(3, 7, 2),
(3, 30, 1),
(4, 10, 1),
(5, 14, 1),
(5, 25, 2),
(6, 15, 1),
(7, 1, 1),
(7, 23, 2),
(8, 34, 1),
(9, 11, 2),
(10, 31, 2),
(11, 16, 1),
(11, 27, 2),
(12, 17, 1),
(13, 18, 2),
(13, 22, 1),
(14, 43, 1),
(15, 46, 1),
(15, 24, 2),
(16, 35, 2),
(17, 39, 1),
(17, 49, 2),
(18, 8, 1),
(19, 13, 1),
(19, 30, 2),
(20, 10, 1),
(21, 14, 1),
(21, 28, 2),
(22, 15, 1),
(23, 7, 1),
(23, 32, 2),
(24, 11, 1),
(25, 38, 1),
(25, 25, 2),
(26, 45, 1),
(27, 47, 1),
(27, 26, 1),
(28, 48, 2),
(29, 34, 1),
(29, 23, 1),
(30, 40, 2),
(31, 1, 1),
(31, 50, 2),
(32, 4, 1),
(33, 6, 1),
(33, 27, 2),
(34, 9, 1),
(35, 12, 2),
(35, 24, 1),
(36, 16, 1),
(37, 18, 1),
(37, 29, 2),
(38, 35, 1),
(39, 36, 2),
(39, 49, 1),
(40, 46, 1),
(41, 13, 1),
(41, 33, 2),
(42, 7, 1),
(43, 15, 2),
(43, 23, 1),
(44, 8, 1),
(45, 14, 1),
(45, 30, 2),
(46, 37, 1),
(47, 10, 2),
(47, 28, 1),
(48, 17, 1),
(49, 34, 1),
(49, 25, 2),
(50, 48, 1),
(51, 5, 1),
(52, 43, 1),
(53, 11, 2),
(54, 31, 1),
(55, 45, 1),
(56, 38, 2),
(57, 47, 1),
(58, 50, 2),
(59, 13, 1),
(60, 14, 1);

insert into reservations (reservation_id, customer_id, table_id, start_time, end_time) values
(1, 1, 1, '2026-03-21 18:00:00', '2026-03-21 20:00:00'),
(2, 2, 3, '2026-03-21 19:00:00', '2026-03-21 21:00:00'),
(3, 5, 6, '2026-03-22 18:30:00', '2026-03-22 20:30:00'),
(4, 7, 2, '2026-03-22 13:00:00', '2026-03-22 14:30:00'),
(5, 10, 8, '2026-03-23 20:00:00', '2026-03-23 22:00:00');

select
    c.customer_id,
    c.customer_name,
    count(o.order_id) as total_orders,
    round(avg(p.payment_amount), 2) as avg_spent_per_order
from customers c
join orders o
    on c.customer_id = o.customer_id
join payment p
    on o.payment_id = p.payment_id
where p.payment_status = 'paid'
group by c.customer_id, c.customer_name
having count(o.order_id) >= 5
   and avg(p.payment_amount) > 5000
order by avg_spent_per_order desc, total_orders desc;




with dish_sales as (
    select
        f.food_category,
        f.food_id,
        f.food_name,
        sum(oi.quantity) as total_quantity
    from foods f
    join order_items oi
        on f.food_id = oi.food_id
    group by f.food_category, f.food_id, f.food_name
),
ranked_dishes as (
    select
        food_category,
        food_id,
        food_name,
        total_quantity,
        dense_rank() over (
            partition by food_category
            order by total_quantity desc
        ) as rnk
    from dish_sales
)
select
    food_category,
    food_id,
    food_name,
    total_quantity
from ranked_dishes
where rnk = 1
order by food_category, food_name;


select
    round(sum(p.payment_amount), 2) as total_revenue_last_3_months,
    round(avg(p.payment_amount), 2) as average_check_amount
from orders o
join payment p
    on o.payment_id = p.payment_id
where p.payment_status = 'paid'
  and o.order_datetime >= current_date - interval 3 month;