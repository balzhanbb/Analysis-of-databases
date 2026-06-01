create database RA;
use RA;

create table department (
    department_id int primary key,
    department_name varchar(50) not null,
    location varchar(50) not null
);

create table employee (
    employee_id int primary key,
    name varchar(50) not null,
    age int not null,
    department_id int not null,
    salary int not null,
    foreign key (department_id) references department(department_id)
);

create table project (
    project_id int primary key,
    project_name varchar(50) not null,
    budget int not null,
    department_id int not null,
    foreign key (department_id) references department(department_id)
);

create table works_on (
    employee_id int not null,
    project_id int not null,
    hours_worked int not null,
    foreign key (employee_id) references employee(employee_id),
    foreign key (project_id) references project(project_id)
);

insert into department (department_id, department_name, location) values
(1, 'Department_1', 'Berlin'),
(2, 'Department_2', 'Moscow'),
(3, 'Department_3', 'Berlin'),
(4, 'Department_4', 'Toronto'),
(5, 'Department_5', 'London'),
(6, 'Department_6', 'Berlin'),
(7, 'Department_7', 'New York'),
(8, 'Department_8', 'Tokyo'),
(9, 'Department_9', 'Beijing'),
(10, 'Department_10', 'Sydney');

insert into employee (employee_id, name, age, department_id, salary) values
(1, 'Employee_1', 33, 9, 9084),
(2, 'Employee_2', 54, 6, 3120),
(3, 'Employee_3', 33, 8, 8164),
(4, 'Employee_4', 39, 10, 9069),
(5, 'Employee_5', 22, 6, 4688),
(6, 'Employee_6', 52, 9, 6416),
(7, 'Employee_7', 56, 2, 8690),
(8, 'Employee_8', 59, 2, 8746),
(9, 'Employee_9', 52, 2, 7665),
(10, 'Employee_10', 37, 3, 6019),
(11, 'Employee_11', 57, 9, 5301),
(12, 'Employee_12', 47, 1, 5371),
(13, 'Employee_13', 26, 10, 7585),
(14, 'Employee_14', 22, 2, 7718),
(15, 'Employee_15', 34, 8, 3913),
(16, 'Employee_16', 39, 9, 9344),
(17, 'Employee_17', 23, 9, 5388),
(18, 'Employee_18', 44, 3, 4451),
(19, 'Employee_19', 46, 8, 5050),
(20, 'Employee_20', 50, 2, 8677),
(21, 'Employee_21', 31, 7, 9814),
(22, 'Employee_22', 38, 2, 6794),
(23, 'Employee_23', 54, 9, 8694),
(24, 'Employee_24', 48, 7, 7658),
(25, 'Employee_25', 27, 9, 4930),
(26, 'Employee_26', 26, 8, 8306),
(27, 'Employee_27', 56, 7, 6138),
(28, 'Employee_28', 22, 2, 3302),
(29, 'Employee_29', 44, 4, 8841),
(30, 'Employee_30', 36, 10, 3292);

insert into project (project_id, project_name, budget, department_id) values
(1, 'Project_1', 424116, 6),
(2, 'Project_2', 161350, 7),
(3, 'Project_3', 95202, 9),
(4, 'Project_4', 149703, 9),
(5, 'Project_5', 441866, 6),
(6, 'Project_6', 278039, 4),
(7, 'Project_7', 424090, 10),
(8, 'Project_8', 439356, 4),
(9, 'Project_9', 305171, 3),
(10, 'Project_10', 77925, 6),
(11, 'Project_11', 107822, 7),
(12, 'Project_12', 363035, 3),
(13, 'Project_13', 399307, 2),
(14, 'Project_14', 431455, 4),
(15, 'Project_15', 357896, 4);

insert into works_on (employee_id, project_id, hours_worked) values
(14, 3, 13),
(26, 12, 38),
(4, 12, 70),
(18, 6, 66),
(16, 6, 90),
(9, 12, 35),
(10, 15, 35),
(15, 3, 99),
(25, 5, 69),
(5, 12, 28),
(24, 13, 89),
(24, 10, 41),
(30, 9, 33),
(16, 7, 16),
(21, 13, 39),
(3, 7, 78),
(12, 10, 14),
(14, 6, 16),
(2, 13, 77),
(15, 7, 29),
(19, 12, 28),
(15, 7, 53),
(29, 1, 25),
(19, 3, 40),
(24, 1, 69),
(1, 4, 67),
(8, 9, 55),
(24, 15, 41),
(8, 15, 71),
(26, 3, 34);

#1
select *
from employee
where salary > 5000;

#2
select name, salary
from employee;

#3
select e.employee_id, e.name
from employee e
where e.employee_id not in (
    select w.employee_id
    from works_on w
);

#4
select *
from employee
cross join department;

#5
select e.name, d.department_name
from employee e
join department d
    on e.department_id = d.department_id;
    
#6
select
    d.department_name,
    avg(e.salary) as avg_salary
from employee e
join department d
    on e.department_id = d.department_id
group by d.department_name;

#7
select e.name
from employee e
join works_on w
    on e.employee_id = w.employee_id
join project p
    on w.project_id = p.project_id
where p.project_name = 'AI Research';

#8
with employee_hours as (
    select
        e.employee_id,
        e.name,
        sum(w.hours_worked) as total_hours
    from employee e
    join works_on w
        on e.employee_id = w.employee_id
    group by e.employee_id, e.name
)
select employee_id, name, total_hours
from employee_hours
where total_hours = (
    select max(total_hours)
    from employee_hours
);

#9
select d.department_id, d.department_name
from department d
where d.department_id not in (
    select p.department_id
    from project p
);

#10
select
    e.employee_id,
    e.name,
    count(distinct w.project_id) as project_count
from employee e
join works_on w
    on e.employee_id = w.employee_id
group by e.employee_id, e.name
having count(distinct w.project_id) > 2;