create database practiceRA;
use practiceRA;

create table students (
    student_id int primary key,
    name varchar(100),
    age int,
    major varchar(100)
);

create table courses (
    course_id int primary key,
    course_name varchar(100),
    credits int
);

create table professors (
    professor_id int primary key,
    name varchar(100),
    department varchar(100)
);

create table enrollments (
    enrollment_id int primary key,
    student_id int,
    course_id int,
    grade char(1) null,
    foreign key (student_id) references students(student_id),
    foreign key (course_id) references courses(course_id)
);

create table teaching (
    teaching_id int primary key,
    professor_id int,
    course_id int,
    semester varchar(50),
    foreign key (professor_id) references professors(professor_id),
    foreign key (course_id) references courses(course_id)
);

insert into students (student_id, name, age, major) values
(1, 'alice johnson', 22, 'computer science'),
(2, 'bob smith', 19, 'mathematics'),
(3, 'charlie brown', 21, 'physics'),
(4, 'david lee', 20, 'computer science'),
(5, 'emma stone', 23, 'mathematics'),
(6, 'fiona clark', 22, 'physics'),
(7, 'george white', 18, 'mathematics'),
(8, 'hannah black', 24, 'economics'),
(9, 'isaac green', 19, 'computer science'),
(10, 'jack blue', 21, 'biology');

insert into courses (course_id, course_name, credits) values
(101, 'data science', 4),
(102, 'machine learning', 3),
(103, 'linear algebra', 4),
(104, 'quantum physics', 5),
(105, 'macroeconomics', 3);

insert into professors (professor_id, name, department) values
(201, 'dr. thompson', 'computer science'),
(202, 'dr. miller', 'mathematics'),
(203, 'dr. carter', 'physics'),
(204, 'dr. watson', 'economics');

insert into teaching (teaching_id, professor_id, course_id, semester) values
(301, 201, 101, 'fall 2023'),
(302, 201, 102, 'fall 2023'),
(303, 202, 103, 'spring 2023'),
(304, 203, 104, 'spring 2023'),
(305, 204, 105, 'fall 2023');

insert into enrollments (enrollment_id, student_id, course_id, grade) values
(401, 1, 101, 'c'),
(402, 1, 102, 'c'),
(403, 2, 101, 'b'),
(404, 2, 103, 'f'),
(405, 3, 104, 'c'),
(406, 4, 105, 'b'),
(407, 5, 102, 'c'),
(408, 6, 101, null),
(409, 7, 104, 'a'),
(410, 8, 105, 'b');

select s.student_id, s.name
from students s
where not exists (
    select t.course_id
    from teaching t
    join professors p
        on p.professor_id = t.professor_id
    where p.name = 'dr. thompson'
      and not exists (
          select 1
          from enrollments e
          where e.student_id = s.student_id
            and e.course_id = t.course_id
      )
);

select s.name
from students s
where s.major = (
    select major
    from students
    where name = 'ethan carter'
);

select s.student_id, s.name
from students s
join enrollments e
    on s.student_id = e.student_id
group by s.student_id, s.name
having count(distinct e.course_id) >= 2;

select distinct p.professor_id, p.name
from professors p
join teaching t
    on p.professor_id = t.professor_id
join enrollments e
    on t.course_id = e.course_id
join students s
    on s.student_id = e.student_id
where s.name = 'emma stone';

select s.student_id, s.name
from students s
left join enrollments e
    on s.student_id = e.student_id
where e.student_id is null;

select
    s.student_id,
    s.name,
    count(e.course_id) as course_count
from students s
left join enrollments e
    on s.student_id = e.student_id
group by s.student_id, s.name
order by s.student_id;


select
    p.professor_id,
    p.name,
    count(distinct t.course_id) as course_count
from professors p
join teaching t
    on p.professor_id = t.professor_id
group by p.professor_id, p.name
having count(distinct t.course_id) > 1;

select s.student_id, s.name
from students s
join enrollments e
    on s.student_id = e.student_id
where e.grade in ('A', 'B', 'C', 'D', 'F')
group by s.student_id, s.name
having count(distinct e.grade) = 5;