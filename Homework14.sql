create database homework14week;
use homework14week;

create table students (
    student_id int primary key,
    full_name varchar(100) not null,
    city varchar(50) not null,
    age int not null,
    check (age between 16 and 40)
);

create table courses (
    course_id int primary key,
    course_name varchar(100) not null,
    credits int not null,
    check (credits between 2 and 6)
);

create table instructors (
    instructor_id int primary key,
    full_name varchar(100) not null,
    department varchar(100) not null
);

create table enrollments (
    enrollment_id int primary key,
    student_id int not null,
    course_id int not null,
    semester varchar(20) not null,
    grade decimal(5,2) not null,
    check (grade between 0 and 100),
    constraint fk_enrollments_student
        foreign key (student_id) references students(student_id),
    constraint fk_enrollments_course
        foreign key (course_id) references courses(course_id)
);

create table teaching (
    teaching_id int primary key,
    instructor_id int not null,
    course_id int not null,
    semester varchar(20) not null,
    constraint fk_teaching_instructor
        foreign key (instructor_id) references instructors(instructor_id),
    constraint fk_teaching_course
        foreign key (course_id) references courses(course_id)
);

insert into students (student_id, full_name, city, age) values
(1,  'Aruzhan Saparova',       'Almaty',      19),
(2,  'Dias Nurgaliyev',        'Astana',      20),
(3,  'Madina Tulegen',         'Shymkent',    18),
(4,  'Alibek Serik',           'Karaganda',   21),
(5,  'Dana Bekova',            'Aktobe',      22),
(6,  'Nursultan Akhmetov',     'Taraz',       20),
(7,  'Aigerim Ospan',          'Pavlodar',    19),
(8,  'Ruslan Imanov',          'Kostanay',    23),
(9,  'Amina Zhaksylyk',        'Kokshetau',   18),
(10, 'Timur Abdrakhmanov',     'Semey',       24),
(11, 'Kamila Yessengali',      'Atyrau',      20),
(12, 'Miras Zholdas',          'Turkistan',   19),
(13, 'Saniya Mukhtar',         'Almaty',      21),
(14, 'Yernar Kairat',          'Astana',      22),
(15, 'Aldana Iskakova',        'Shymkent',    20),
(16, 'Adil Tasmagambet',       'Karaganda',   23),
(17, 'Zarina Omarova',         'Aktau',       19),
(18, 'Bekzat Utepov',          'Uralsk',      21),
(19, 'Malika Kassen',          'Petropavl',   18),
(20, 'Askar Duisen',           'Taldykorgan', 20),
(21, 'Gaukhar Nurgazy',        'Almaty',      22),
(22, 'Sultan Rakhim',          'Astana',      19),
(23, 'Aruzhan Baimurat',       'Shymkent',    21),
(24, 'Yerbol Tleubay',         'Kyzylorda',   24),
(25, 'Indira Amanzhol',        'Taraz',       20),
(26, 'Olzhas Kudaibergen',     'Pavlodar',    22),
(27, 'Assel Maratkyzy',        'Kostanay',    18),
(28, 'Daniyar Sarsen',         'Semey',       23),
(29, 'Elmira Duisenova',       'Atyrau',      19),
(30, 'Marlen Bektas',          'Turkistan',   20);

insert into courses (course_id, course_name, credits) values
(1,  'Database Systems',           5),
(2,  'Computer Networks',          4),
(3,  'Operating Systems',          5),
(4,  'Web Development',            4),
(5,  'Linear Algebra',             3),
(6,  'Calculus I',                 4),
(7,  'Statistics',                 4),
(8,  'Data Structures',            5),
(9,  'Algorithms',                 5),
(10, 'Software Engineering',       4),
(11, 'Machine Learning',           5),
(12, 'Artificial Intelligence',    5),
(13, 'Physics',                    3),
(14, 'Discrete Mathematics',       4),
(15, 'Economics',                  3),
(16, 'Accounting Basics',          2),
(17, 'Business Communication',     3),
(18, 'Cybersecurity',              5),
(19, 'Cloud Computing',            4),
(20, 'Mobile Development',         4),
(21, 'Research Methods',           3),
(22, 'Project Management',         4),
(23, 'Human Computer Interaction', 3),
(24, 'Big Data Analytics',         5),
(25, 'Data Visualization',         4),
(26, 'Compiler Design',            5),
(27, 'Parallel Computing',         4),
(28, 'Numerical Methods',          3),
(29, 'Digital Logic',              4),
(30, 'Game Development',           4);

insert into instructors (instructor_id, full_name, department) values
(1,  'Dr. Kairat Nurgazin',      'Computer Science'),
(2,  'Dr. Asem Tulegenova',      'Mathematics'),
(3,  'Prof. Serik Zhumanov',     'Computer Science'),
(4,  'Dr. Gulmira Yessen',       'Information Systems'),
(5,  'Prof. Ruslan Beketov',     'Physics'),
(6,  'Dr. Dana Orazbayeva',      'Business'),
(7,  'Dr. Timur Sadykov',        'Computer Science'),
(8,  'Prof. Aigerim Kuat',       'Statistics'),
(9,  'Dr. Miras Akylbek',        'Cybersecurity'),
(10, 'Prof. Kamila Nurpeisova',  'Software Engineering'),
(11, 'Dr. Alibek Mukan',         'Artificial Intelligence'),
(12, 'Dr. Indira Suleimen',      'Economics'),
(13, 'Prof. Yernar Smagulov',    'Mathematics'),
(14, 'Dr. Assel Baigalieva',     'Business'),
(15, 'Dr. Bekzat Tursyn',        'Computer Engineering'),
(16, 'Prof. Zarina Serikkzy',    'Design'),
(17, 'Dr. Nursultan Rysbek',     'Cloud Technologies'),
(18, 'Dr. Madina Ospanova',      'Software Engineering'),
(19, 'Prof. Daniyar Abilov',     'Computer Science'),
(20, 'Dr. Amina Kassenova',      'Research'),
(21, 'Dr. Adil Kenzhebek',       'Game Design'),
(22, 'Prof. Gaukhar Tleulina',   'Mathematics'),
(23, 'Dr. Marat Ualikhan',       'Computer Science'),
(24, 'Dr. Saltanat Abylkassym',  'Information Security'),
(25, 'Prof. Olzhas Yermek',      'Data Science'),
(26, 'Dr. Malika Ibrayeva',      'Business'),
(27, 'Dr. Yerlan Dossan',        'Mobile Computing'),
(28, 'Prof. Aizhan Kudaibergen', 'Physics'),
(29, 'Dr. Sultan Khamit',        'Statistics'),
(30, 'Dr. Elmira Tazhibayeva',   'Computer Science');

insert into teaching (teaching_id, instructor_id, course_id, semester) values
(1,  1,  1,  'Fall 2025'),
(2,  3,  2,  'Fall 2025'),
(3,  7,  3,  'Fall 2025'),
(4,  10, 4,  'Fall 2025'),
(5,  2,  5,  'Fall 2025'),
(6,  13, 6,  'Fall 2025'),
(7,  8,  7,  'Fall 2025'),
(8,  19, 8,  'Fall 2025'),
(9,  23, 9,  'Fall 2025'),
(10, 18, 10, 'Fall 2025'),
(11, 11, 11, 'Fall 2025'),
(12, 11, 12, 'Fall 2025'),
(13, 5,  13, 'Fall 2025'),
(14, 22, 14, 'Fall 2025'),
(15, 12, 15, 'Fall 2025'),
(16, 14, 16, 'Fall 2025'),
(17, 26, 17, 'Fall 2025'),
(18, 9,  18, 'Fall 2025'),
(19, 17, 19, 'Fall 2025'),
(20, 27, 20, 'Fall 2025'),
(21, 20, 21, 'Fall 2025'),
(22, 6,  22, 'Fall 2025'),
(23, 16, 23, 'Fall 2025'),
(24, 25, 24, 'Fall 2025'),
(25, 25, 25, 'Fall 2025'),
(26, 30, 26, 'Fall 2025'),
(27, 15, 27, 'Fall 2025'),
(28, 22, 28, 'Fall 2025'),
(29, 15, 29, 'Fall 2025'),
(30, 21, 30, 'Fall 2025');

insert into enrollments (enrollment_id, student_id, course_id, semester, grade) values
(1,  1,  1,  'Fall 2025', 88.00),
(2,  1,  5,  'Fall 2025', 75.00),
(3,  1,  7,  'Fall 2025', 91.00),
(4,  2,  1,  'Fall 2025', 67.00),
(5,  2,  2,  'Fall 2025', 79.00),
(6,  2,  8,  'Fall 2025', 84.00),
(7,  3,  3,  'Fall 2025', 73.00),
(8,  3,  6,  'Fall 2025', 82.00),
(9,  4,  4,  'Fall 2025', 90.00),
(10, 4,  10, 'Fall 2025', 86.00),
(11, 5,  5,  'Fall 2025', 65.00),
(12, 5,  15, 'Fall 2025', 72.00),
(13, 6,  11, 'Fall 2025', 95.00),
(14, 6,  12, 'Fall 2025', 89.00),
(15, 6,  24, 'Fall 2025', 93.00),
(16, 7,  8,  'Fall 2025', 77.00),
(17, 7,  9,  'Fall 2025', 81.00),
(18, 8,  2,  'Fall 2025', 58.00),
(19, 8,  18, 'Fall 2025', 74.00),
(20, 9,  6,  'Fall 2025', 88.00),
(21, 9,  14, 'Fall 2025', 92.00),
(22, 10, 13, 'Fall 2025', 69.00),
(23, 10, 21, 'Fall 2025', 80.00),
(24, 11, 19, 'Fall 2025', 85.00),
(25, 11, 24, 'Fall 2025', 87.00),
(26, 12, 16, 'Fall 2025', 78.00),
(27, 12, 17, 'Fall 2025', 83.00),
(28, 13, 1,  'Fall 2025', 94.00),
(29, 13, 11, 'Fall 2025', 96.00),
(30, 14, 4,  'Fall 2025', 71.00),
(31, 14, 20, 'Fall 2025', 76.00),
(32, 15, 7,  'Fall 2025', 89.00),
(33, 15, 25, 'Fall 2025', 91.00),
(34, 16, 3,  'Fall 2025', 62.00),
(35, 16, 26, 'Fall 2025', 70.00),
(36, 17, 18, 'Fall 2025', 84.00),
(37, 17, 19, 'Fall 2025', 88.00),
(38, 18, 22, 'Fall 2025', 79.00),
(39, 18, 15, 'Fall 2025', 68.00),
(40, 19, 23, 'Fall 2025', 90.00),
(41, 19, 17, 'Fall 2025', 82.00),
(42, 20, 28, 'Fall 2025', 74.00),
(43, 20, 5,  'Fall 2025', 77.00),
(44, 21, 9,  'Fall 2025', 93.00),
(45, 21, 24, 'Fall 2025', 90.00),
(46, 21, 25, 'Fall 2025', 88.00),
(47, 22, 29, 'Fall 2025', 66.00),
(48, 22, 3,  'Fall 2025', 72.00),
(49, 23, 30, 'Fall 2025', 85.00),
(50, 23, 4,  'Fall 2025', 87.00),
(51, 24, 2,  'Fall 2025', 91.00),
(52, 24, 7,  'Fall 2025', 86.00),
(53, 25, 6,  'Fall 2025', 79.00),
(54, 25, 14, 'Fall 2025', 83.00),
(55, 26, 10, 'Fall 2025', 88.00),
(56, 26, 22, 'Fall 2025', 92.00),
(57, 27, 1,  'Fall 2025', 76.00),
(58, 27, 5,  'Fall 2025', 81.00),
(59, 28, 11, 'Fall 2025', 72.00),
(60, 28, 12, 'Fall 2025', 75.00),
(61, 29, 8,  'Fall 2025', 89.00),
(62, 29, 18, 'Fall 2025', 91.00),
(63, 30, 20, 'Fall 2025', 84.00),
(64, 30, 30, 'Fall 2025', 80.00),
(65, 4,  8,  'Fall 2025', 92.00),
(66, 9,  11, 'Fall 2025', 94.00),
(67, 14, 25, 'Fall 2025', 73.00),
(68, 18, 22, 'Spring 2026', 81.00),
(69, 6,  11, 'Spring 2026', 97.00),
(70, 13, 24, 'Spring 2026', 93.00);
-- 1
select
    s.student_id,
    s.full_name,
    count(distinct e.course_id) as number_of_courses
from students s
join enrollments e
    on s.student_id = e.student_id
group by
    s.student_id,
    s.full_name
having count(distinct e.course_id) > 1;
-- 2
select
    s.full_name,
    e.course_id,
    e.grade
from enrollments e
join students s
    on e.student_id = s.student_id
join (
    select
        course_id,
        avg(grade) as avg_grade
    from enrollments
    group by course_id
) a
    on e.course_id = a.course_id
where e.grade > a.avg_grade;

-- 3
select
    c.course_id,
    c.course_name
from courses c
left join enrollments e
    on c.course_id = e.course_id
where e.course_id is null;

-- 4
select
    s.full_name as student_name,
    c.course_name,
    i.full_name as instructor_name,
    e.semester,
    e.grade
from enrollments e
join students s
    on e.student_id = s.student_id
join courses c
    on e.course_id = c.course_id
join teaching t
    on e.course_id = t.course_id
   and e.semester = t.semester
join instructors i
    on t.instructor_id = i.instructor_id
where e.grade > 80
  and c.credits >= 4;
  
  -- 5
  select
    s.student_id,
    s.full_name
from students s
join enrollments e
    on s.student_id = e.student_id
join courses c
    on e.course_id = c.course_id
group by
    s.student_id,
    s.full_name
having min(c.credits) >= 4;

-- 6
select
    c.course_id,
    c.course_name,
    avg(e.grade) as average_grade
from courses c
join enrollments e
    on c.course_id = e.course_id
group by
    c.course_id,
    c.course_name
having avg(e.grade) > (
    select avg(grade)
    from enrollments
);

create index idx_enrollments_student_course
on enrollments (student_id, course_id);

create index idx_teaching_course_semester_instructor
on teaching (course_id, semester, instructor_id);