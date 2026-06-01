create database practice7;
use practice7;



create table student (
    sid int primary key,
    name varchar(100),
    major varchar(100),
    gpa decimal(3,2)
);

insert into student (sid, name, major, gpa) values
(1,'amir','computer science',3.80),
(2,'aida','mathematics',3.40),
(3,'dias','physics',3.90),
(4,'malika','biology',3.20),
(5,'nursultan','engineering',3.60),
(6,'askar','computer science',3.10),
(7,'aliya','mathematics',3.75),
(8,'temir','physics',3.55),
(9,'dana','chemistry',3.95),
(10,'ruslan','engineering',3.45),
(11,'azamat','biology',3.70),
(12,'saltanat','physics',3.25),
(13,'arman','computer science',3.88),
(14,'karina','mathematics',3.67),
(15,'marat','engineering',3.15),
(16,'zhanar','biology',3.82),
(17,'erlan','physics',3.58),
(18,'dinara','chemistry',3.48),
(19,'alisher','computer science',3.92),
(20,'gulnaz','engineering',3.33);


create table course (
    courseid int primary key,
    title varchar(100)
);

insert into course (courseid, title) values
(101,'databases'),
(102,'algorithms'),
(103,'statistics'),
(104,'linear algebra'),
(105,'operating systems'),
(106,'machine learning'),
(107,'network security'),
(108,'data science');



create table enrolled (
    sid int,
    courseid int,
    primary key (sid, courseid),
    foreign key (sid) references student(sid),
    foreign key (courseid) references course(courseid)
);

insert into enrolled (sid, courseid) values
(1,101),(1,102),
(2,103),(2,104),
(3,101),(3,105),
(4,103),(5,102),
(6,106),(7,101),
(8,104),(9,106),
(10,105),(11,102),
(12,107),(13,108),
(14,104),(15,105),
(16,103),(17,101),
(18,106),(19,108),
(20,107);



create table customers (
    customerid int primary key,
    region varchar(50)
);

insert into customers (customerid, region) values
(1,'asia'),
(2,'europe'),
(3,'asia'),
(4,'america'),
(5,'asia'),
(6,'europe'),
(7,'america'),
(8,'asia'),
(9,'europe'),
(10,'asia'),
(11,'america'),
(12,'asia'),
(13,'europe'),
(14,'asia'),
(15,'america');



create table orders (
    orderid int primary key,
    customerid int,
    amount decimal(10,2),
    foreign key (customerid) references customers(customerid)
);

insert into orders (orderid, customerid, amount) values
(1001,1,1500.00),
(1002,2,800.00),
(1003,3,2000.00),
(1004,4,500.00),
(1005,5,1200.00),
(1006,6,300.00),
(1007,7,4500.00),
(1008,8,700.00),
(1009,9,950.00),
(1010,10,2500.00),
(1011,11,1100.00),
(1012,12,1700.00),
(1013,13,400.00),
(1014,14,2200.00),
(1015,15,600.00),
(1016,1,900.00),
(1017,3,1800.00),
(1018,5,1300.00),
(1019,8,1400.00),
(1020,10,3000.00);


create table books (
    bookid int primary key,
    title varchar(200),
    author varchar(100),
    year int,
    genre varchar(50)
);

insert into books (bookid, title, author, year, genre) values
(1,'clean code','robert martin',2008,'programming'),
(2,'design patterns','gamma',1994,'programming'),
(3,'war and peace','tolstoy',1869,'novel'),
(4,'the hobbit','tolkien',1937,'fantasy'),
(5,'data science handbook','field cady',2017,'data'),
(6,'deep learning','goodfellow',2016,'ai'),
(7,'crime and punishment','dostoevsky',1866,'novel'),
(8,'effective java','bloch',2001,'programming'),
(9,'harry potter','rowling',1997,'fantasy'),
(10,'thinking in systems','meadows',2008,'science'),
(11,'python crash course','matthes',2015,'programming'),
(12,'lord of the rings','tolkien',1954,'fantasy'),
(13,'anna karenina','tolstoy',1877,'novel'),
(14,'artificial intelligence','russell',2010,'ai'),
(15,'statistical learning','hastie',2009,'data'),
(16,'refactoring','fowler',1999,'programming'),
(17,'the martian','weir',2011,'sci-fi'),
(18,'dune','herbert',1965,'sci-fi'),
(19,'foundation','asimov',1951,'sci-fi'),
(20,'clean architecture','robert martin',2017,'programming');

create index idx_books_author on books(author);
create index idx_books_genre on books(genre);
create index idx_books_year on books(year);



create table flights (
    flightid int primary key,
    origin varchar(100),
    destination varchar(100),
    duration decimal(4,2),
    airline varchar(100)
);

insert into flights (flightid, origin, destination, duration, airline) values
(1,'almaty','astana',1.50,'airastana'),
(2,'almaty','astana',2.30,'scat'),
(3,'almaty','astana',1.80,'airastana'),
(4,'astana','almaty',1.60,'airastana'),
(5,'almaty','shymkent',1.20,'airastana'),
(6,'astana','shymkent',2.10,'scat'),
(7,'almaty','aktau',2.50,'airastana'),
(8,'almaty','astana',1.40,'airastana'),
(9,'shymkent','astana',2.00,'scat'),
(10,'almaty','astana',1.70,'airastana'),
(11,'almaty','taraz',1.10,'airastana'),
(12,'aktau','almaty',2.40,'airastana'),
(13,'almaty','astana',1.90,'flyarystan'),
(14,'almaty','astana',1.55,'airastana'),
(15,'astana','aktobe',1.45,'airastana'),
(16,'almaty','astana',1.65,'airastana'),
(17,'almaty','kokshetau',1.30,'airastana'),
(18,'almaty','astana',1.75,'airastana'),
(19,'almaty','astana',2.20,'scat'),
(20,'almaty','astana',1.85,'airastana');

SELECT
  SID,
  Name,
  Major,
  GPA
FROM Student
WHERE GPA > 3.5;

SELECT
  s.Name,
  c.Title
FROM Student AS s
JOIN Enrolled AS e
  ON e.SID = s.SID
JOIN Course AS c
  ON c.CourseID = e.CourseID;
  
  SELECT
  o.OrderID
FROM Orders AS o
JOIN Customers AS c
  ON c.CustomerID = o.CustomerID
WHERE c.Region = 'Asia'
  AND o.Amount > 1000;
  
  WITH asia_customers AS (
  SELECT CustomerID
  FROM Customers
  WHERE Region = 'Asia'
),
big_orders AS (
  SELECT OrderID, CustomerID
  FROM Orders
  WHERE Amount > 1000
)
SELECT bo.OrderID
FROM big_orders AS bo
JOIN asia_customers AS ac
  ON ac.CustomerID = bo.CustomerID;
  



CREATE INDEX idx_books_genre_year ON Books (Genre, Year);

SELECT
  FlightID,
  Origin,
  Destination,
  Duration,
  Airline
FROM Flights
WHERE Airline = 'AirAstana'
  AND Origin = 'Almaty'
  AND Destination = 'Astana'
  AND Duration < 2;
  
  SELECT
  FlightID,
  Origin,
  Destination,
  Duration,
  Airline
FROM Flights
WHERE Airline = 'AirAstana'
  AND Origin = 'Almaty'
  AND Destination = 'Astana'
  AND Duration < 120;
