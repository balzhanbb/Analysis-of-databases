create database normalization1;
use normalization1;

create table cyclist_unf (
    cyclistno int not null,
    surname varchar(60) null,
    forename varchar(60) null,
    cyclistaddress varchar(200) null,
    cyclistphone varchar(30) null,
    raceno int null,
    racename varchar(120) null,
    racetype varchar(60) null,
    raceresult varchar(50) null,
    clubno int null,
    clubname varchar(100) null,
    clubaddress varchar(200) null
);
insert into cyclist_unf (
    cyclistno, surname, forename, cyclistaddress, cyclistphone,
    raceno, racename, racetype, raceresult,
    clubno, clubname, clubaddress
) values
(1, 'smith',  'john', '12 oak st',   '555-0101', 101, 'almaty classic', 'road', '1st', 10, 'eagle club',  '1 river rd'),
(1, 'smith',  'john', '12 oak st',   '555-0101', 102, 'steppe sprint', 'road', '3rd', 10, 'eagle club',  '1 river rd'),
(2, 'kim',    'mina', '9 pine ave',  '555-0102', 101, 'almaty classic', 'road', '5th', 10, 'eagle club',  '1 river rd'),
(3, 'ali',    'dina', '77 sun blvd', '555-0103', 102, 'steppe sprint', 'road', '2nd', 20, 'falcon club', '99 hill st'),
(3, 'ali',    'dina', '77 sun blvd', '555-0103', 103, 'mountain climb', 'mtb', '1st', 20, 'falcon club', '99 hill st');

select cyclistno, count(*) as rows_per_cyclist
from cyclist_unf
group by cyclistno
having count(*) > 1;
select clubno, count(*) as rows_per_club
from cyclist_unf
group by clubno
having count(*) > 1;

select clubno, clubname, clubaddress
from cyclist_unf
where clubno = 10;

create table cyclist_1nf (
    cyclistno int not null,
    raceno int not null,
    surname varchar(60) null,
    forename varchar(60) null,
    cyclistaddress varchar(200) null,
    cyclistphone varchar(30) null,
    racename varchar(120) null,
    racetype varchar(60) null,
    raceresult varchar(50) null,
    clubno int null,
    clubname varchar(100) null,
    clubaddress varchar(200) null,
    constraint pk_cyclist_1nf primary key (cyclistno, raceno)
);

insert into cyclist_1nf (
    cyclistno, raceno, surname, forename, cyclistaddress, cyclistphone,
    racename, racetype, raceresult, clubno, clubname, clubaddress
)
select
    cyclistno, raceno, surname, forename, cyclistaddress, cyclistphone,
    racename, racetype, raceresult, clubno, clubname, clubaddress
from cyclist_unf
where cyclistno is not null and raceno is not null;

select cyclistno, raceno, count(*) as dup_cnt
from cyclist_1nf
group by cyclistno, raceno
having count(*) > 1;

select *
from cyclist_1nf
order by cyclistno, raceno;

create table cyclist_2nf (
    cyclistno int not null primary key,
    surname varchar(60) not null,
    forename varchar(60) not null,
    cyclistaddress varchar(200) null,
    cyclistphone varchar(30) null,
    clubno int null,
    clubname varchar(100) null,
    clubaddress varchar(200) null
);
create table race_2nf (
    raceno int not null primary key,
    racename varchar(120) not null,
    racetype varchar(60) null
);
create table cyclistrace_2nf (
    cyclistno int not null,
    raceno int not null,
    raceresult varchar(50) null,
    constraint pk_cyclistrace_2nf primary key (cyclistno, raceno)
);
insert into cyclist_2nf (cyclistno, surname, forename, cyclistaddress, cyclistphone, clubno, clubname, clubaddress)
select distinct cyclistno, surname, forename, cyclistaddress, cyclistphone, clubno, clubname, clubaddress
from cyclist_1nf;

insert into race_2nf (raceno, racename, racetype)
select distinct raceno, racename, racetype
from cyclist_1nf;

insert into cyclistrace_2nf (cyclistno, raceno, raceresult)
select distinct cyclistno, raceno, raceresult
from cyclist_1nf;

select cyclistno, count(distinct surname) as surname_variants
from cyclist_1nf
group by cyclistno
having count(distinct surname) > 1;

select raceno, count(distinct racename) as racename_variants
from cyclist_1nf
group by raceno
having count(distinct racename) > 1;

select
    (select count(*) from cyclist_1nf) as rows_in_1nf,
    (select count(*) from cyclist_2nf) as rows_in_cyclist_2nf,
    (select count(*) from race_2nf) as rows_in_race_2nf,
    (select count(*) from cyclistrace_2nf) as rows_in_cyclistrace_2nf;
    
create table club_3nf (
    clubno int not null primary key,
    clubname varchar(100) not null,
    clubaddress varchar(200) null
);
create table cyclist_3nf (
    cyclistno int not null primary key,
    surname varchar(60) not null,
    forename varchar(60) not null,
    cyclistaddress varchar(200) null,
    cyclistphone varchar(30) null,
    clubno int null,
    constraint fk_cyclist_3nf_club foreign key (clubno) references club_3nf(clubno)
);
create table race_3nf (
    raceno int not null primary key,
    racename varchar(120) not null,
    racetype varchar(60) null
);
create table cyclistrace_3nf (
    cyclistno int not null,
    raceno int not null,
    raceresult varchar(50) null,
    constraint pk_cyclistrace_3nf primary key (cyclistno, raceno),
    constraint fk_cyclistrace_3nf_cyclist foreign key (cyclistno) references cyclist_3nf(cyclistno),
    constraint fk_cyclistrace_3nf_race foreign key (raceno) references race_3nf(raceno)
);
insert into club_3nf (clubno, clubname, clubaddress)
select distinct clubno, clubname, clubaddress
from cyclist_2nf
where clubno is not null;

insert into cyclist_3nf (cyclistno, surname, forename, cyclistaddress, cyclistphone, clubno)
select distinct cyclistno, surname, forename, cyclistaddress, cyclistphone, clubno
from cyclist_2nf;

insert into race_3nf (raceno, racename, racetype)
select distinct raceno, racename, racetype
from race_2nf;

insert into cyclistrace_3nf (cyclistno, raceno, raceresult)
select distinct cyclistno, raceno, raceresult
from cyclistrace_2nf;

select clubno, count(distinct clubname) as clubname_variants
from cyclist_2nf
group by clubno
having count(distinct clubname) > 1;

select clubno, clubname, clubaddress
from club_3nf
order by clubno;

select
    c.cyclistno,
    c.surname,
    c.forename,
    c.cyclistaddress,
    c.cyclistphone,
    r.raceno,
    r.racename,
    r.racetype,
    cr.raceresult,
    cl.clubno,
    cl.clubname,
    cl.clubaddress
from cyclist_3nf c
left join club_3nf cl on c.clubno = cl.clubno
inner join cyclistrace_3nf cr on c.cyclistno = cr.cyclistno
inner join race_3nf r on cr.raceno = r.raceno
order by c.cyclistno, r.raceno;



update club_3nf
set clubaddress = '777 new address'
where clubno = 10;

select clubno, clubname, clubaddress
from club_3nf
where clubno = 10;

select
    c.cyclistno, c.surname, cl.clubname, cl.clubaddress
from cyclist_3nf c
left join club_3nf cl on c.clubno = cl.clubno
where c.clubno = 10
order by c.cyclistno;

create table employee_unf (
    employeename varchar(120) not null,
    address varchar(200) null,
    age int null,
    department varchar(100) null,
    division varchar(100) null
);

insert into employee_unf (employeename, address, age, department, division) values
('ann lee',   '1 main st',  25, 'it',      'tech'),
('bob chen',  '2 main st',  31, 'it',      'tech'),
('carl zed',  '3 main st',  29, 'hr',      'admin'),
('dina ali',  '4 main st',  22, 'claims',  'operations'),
('eric kim',  '5 main st',  41, 'claims',  'operations');

select department, division, count(*) as rows_cnt
from employee_unf
group by department, division;

create table employee_1nf (
    employeename varchar(120) not null primary key,
    address varchar(200) null,
    age int null,
    department varchar(100) null,
    division varchar(100) null
);

insert into employee_1nf
select distinct * from employee_unf;

select division, count(*) as rows_cnt
from employee_1nf
group by division;

create table employee_2nf (
    employeename varchar(120) not null primary key,
    address varchar(200) null,
    age int null,
    department varchar(100) null,
    division varchar(100) null
);

insert into employee_2nf
select * from employee_1nf;

select department, count(distinct division) as division_variants
from employee_2nf
group by department
having count(distinct division) > 1;

create table department_3nf (
    department varchar(100) not null primary key,
    division varchar(100) not null
);
create table employee_3nf (
    employeename varchar(120) not null primary key,
    address varchar(200) null,
    age int null,
    department varchar(100) not null,
    constraint fk_employee_3nf_department
        foreign key (department) references department_3nf(department)
);

insert into department_3nf (department, division)
select distinct department, division
from employee_2nf
where department is not null;

insert into employee_3nf (employeename, address, age, department)
select distinct employeename, address, age, department
from employee_2nf;
create table employee_3nf (
    employeename varchar(120) not null primary key,
    address varchar(200) null,
    age int null,
    department varchar(100) not null,
    constraint fk_employee_3nf_department
        foreign key (department) references department_3nf(department)
);

insert into department_3nf (department, division)
select distinct department, division
from employee_2nf
where department is not null;

insert into employee_3nf (employeename, address, age, department)
select distinct employeename, address, age, department
from employee_2nf;

select * from department_3nf;

create table flight_unf (
    flightrefno varchar(40) not null,
    departuredate datetime null,
    pilotno int null,
    arrivaldate datetime null,
    aircraftid int null,
    flightdestination varchar(120) null,
    pilotname varchar(120) null,
    aircraftname varchar(120) null,
    aircraftcapacity int null,
    aircrafttype varchar(80) null,
    aircraftmaxspeed int null
);

insert into flight_unf values
('f100', '2026-02-01 08:00', 1, '2026-02-01 10:00', 10, 'almaty', 'pilot a', 'airbus a', 180, 'jet', 900),
('f101', '2026-02-02 09:00', 1, '2026-02-02 11:30', 10, 'astana', 'pilot a', 'airbus a', 180, 'jet', 900),
('f102', '2026-02-03 12:00', 2, '2026-02-03 16:00', 20, 'shymkent', 'pilot b', 'boeing b', 220, 'jet', 950);

select pilotno, pilotname, count(*) as flights_cnt
from flight_unf
group by pilotno, pilotname;

select aircraftid, aircraftname, count(*) as flights_cnt
from flight_unf
group by aircraftid, aircraftname;

create table flight_1nf (
    flightrefno varchar(40) not null primary key,
    departuredate datetime null,
    pilotno int null,
    arrivaldate datetime null,
    aircraftid int null,
    flightdestination varchar(120) null,
    pilotname varchar(120) null,
    aircraftname varchar(120) null,
    aircraftcapacity int null,
    aircrafttype varchar(80) null,
    aircraftmaxspeed int null
);

insert into flight_1nf
select distinct * from flight_unf;

select flightrefno, count(*) as dup_cnt
from flight_1nf
group by flightrefno
having count(*) > 1;

create table flight_2nf (
    flightrefno varchar(40) not null primary key,
    departuredate datetime null,
    pilotno int null,
    arrivaldate datetime null,
    aircraftid int null,
    flightdestination varchar(120) null,
    pilotname varchar(120) null,
    aircraftname varchar(120) null,
    aircraftcapacity int null,
    aircrafttype varchar(80) null,
    aircraftmaxspeed int null
);

insert into flight_2nf
select * from flight_1nf;

select pilotno, count(distinct pilotname) as pilotname_variants
from flight_2nf
group by pilotno
having count(distinct pilotname) > 1;

select aircraftid, count(distinct aircraftname) as aircraftname_variants
from flight_2nf
group by aircraftid
having count(distinct aircraftname) > 1;

create table pilot_3nf (
    pilotno int not null primary key,
    pilotname varchar(120) not null
);
create table aircraft_3nf (
    aircraftid int not null primary key,
    aircraftname varchar(120) not null,
    aircraftcapacity int null,
    aircrafttype varchar(80) null,
    aircraftmaxspeed int null
);
create table flight_3nf (
    flightrefno varchar(40) not null primary key,
    departuredate datetime not null,
    arrivaldate datetime null,
    flightdestination varchar(120) null,
    pilotno int not null,
    aircraftid int not null,
    constraint fk_flight_3nf_pilot foreign key (pilotno) references pilot_3nf(pilotno),
    constraint fk_flight_3nf_aircraft foreign key (aircraftid) references aircraft_3nf(aircraftid)
);
insert into pilot_3nf (pilotno, pilotname)
select distinct pilotno, pilotname
from flight_2nf
where pilotno is not null;

insert into aircraft_3nf (aircraftid, aircraftname, aircraftcapacity, aircrafttype, aircraftmaxspeed)
select distinct aircraftid, aircraftname, aircraftcapacity, aircrafttype, aircraftmaxspeed
from flight_2nf
where aircraftid is not null;

insert into flight_3nf (flightrefno, departuredate, arrivaldate, flightdestination, pilotno, aircraftid)
select distinct flightrefno, departuredate, arrivaldate, flightdestination, pilotno, aircraftid
from flight_2nf;

update pilot_3nf set pilotname = 'pilot a updated' where pilotno = 1;
select * from pilot_3nf where pilotno = 1;

create table teacher_unf (
    teacherno int not null,
    teachername varchar(120) null,
    schoolref varchar(40) null,
    schoolname varchar(200) null
);

insert into teacher_unf values
(1, 'tina',  's1', 'school one'),
(2, 'omar',  's1', 'school one'),
(3, 'lena',  's2', 'school two'),
(4, 'alen', 's2','school two');

select schoolref, schoolname, count(*) as teachers_cnt
from teacher_unf
group by schoolref, schoolname;

create table teacher_1nf (
    teacherno int not null primary key,
    teachername varchar(120) null,
    schoolref varchar(40) null,
    schoolname varchar(200) null
);

insert into teacher_1nf
select distinct * from teacher_unf;

create table teacher_2nf (
    teacherno int not null primary key,
    teachername varchar(120) null,
    schoolref varchar(40) null,
    schoolname varchar(200) null
);

insert into teacher_2nf
select * from teacher_1nf;

select schoolref, count(distinct schoolname) as schoolname_variants
from teacher_2nf
group by schoolref
having count(distinct schoolname) > 1;

create table school_3nf (
    schoolref varchar(40) not null primary key,
    schoolname varchar(200) not null
);
create table teacher_3nf (
    teacherno int not null primary key,
    teachername varchar(120) not null,
    schoolref varchar(40) not null,
    constraint fk_teacher_3nf_school foreign key (schoolref) references school_3nf(schoolref)
);

insert into school_3nf (schoolref, schoolname)
select distinct schoolref, schoolname
from teacher_2nf;

insert into teacher_3nf (teacherno, teachername, schoolref)
select distinct teacherno, teachername, schoolref
from teacher_2nf;

select t.teacherno, t.teachername, s.schoolref, s.schoolname
from teacher_3nf t
join school_3nf s on t.schoolref = s.schoolref
order by t.teacherno;

create table race_unf (
    raceid int not null,
    competitorid int not null,
    competitorname varchar(120) null,
    positionachieved int null,
    racedistance decimal(10,2) null
);

insert into race_unf values
(100, 1, 'ann',  1, 42.20),
(100, 2, 'bob',  2, 42.20),
(101, 1, 'ann',  3, 10.00),
(101, 3, 'carl', 1, 10.00);

select competitorid, competitorname, count(*) as rows_cnt
from race_unf
group by competitorid, competitorname;

select raceid, racedistance, count(*) as rows_cnt
from race_unf
group by raceid, racedistance;

create table race_1nf (
    raceid int not null,
    competitorid int not null,
    competitorname varchar(120) null,
    positionachieved int null,
    racedistance decimal(10,2) null,
    constraint pk_race_1nf primary key (raceid, competitorid)
);

insert into race_1nf
select distinct * from race_unf;

select raceid, competitorid, count(*) as dup_cnt
from race_1nf
group by raceid, competitorid
having count(*) > 1;

create table competitor_2nf (
    competitorid int not null primary key,
    competitorname varchar(120) not null
);


create table raceevent_2nf (
    raceid int not null primary key,
    racedistance decimal(10,2) not null
);

create table raceresult_2nf (
    raceid int not null,
    competitorid int not null,
    positionachieved int null,
    constraint pk_raceresult_2nf primary key (raceid, competitorid)
);

insert into competitor_2nf
select distinct competitorid, competitorname
from race_1nf;

insert into raceevent_2nf
select distinct raceid, racedistance
from race_1nf;

insert into raceresult_2nf
select distinct raceid, competitorid, positionachieved
from race_1nf;

select competitorid, count(distinct competitorname) as name_variants
from race_1nf
group by competitorid
having count(distinct competitorname) > 1;

select raceid, count(distinct racedistance) as distance_variants
from race_1nf
group by raceid
having count(distinct racedistance) > 1;

create table competitor_3nf (
    competitorid int not null primary key,
    competitorname varchar(120) not null
);


create table raceevent_3nf (
    raceid int not null primary key,
    racedistance decimal(10,2) not null
);


create table raceresult_3nf (
    raceid int not null,
    competitorid int not null,
    positionachieved int null,
    constraint pk_raceresult_3nf primary key (raceid, competitorid),
    constraint fk_raceresult_3nf_raceevent foreign key (raceid) references raceevent_3nf(raceid),
    constraint fk_raceresult_3nf_competitor foreign key (competitorid) references competitor_3nf(competitorid)
);

insert into competitor_3nf select * from competitor_2nf;
insert into raceevent_3nf select * from raceevent_2nf;
insert into raceresult_3nf select * from raceresult_2nf;

select
    re.raceid, rv.racedistance,
    re.competitorid, c.competitorname,
    re.positionachieved
from raceresult_3nf re
join competitor_3nf c on re.competitorid = c.competitorid
join raceevent_3nf rv on re.raceid = rv.raceid
order by re.raceid, re.positionachieved;

create table car_rally_result_unf (
    driverid int not null,
    drivername varchar(120) null,
    codriverid int null,
    codrivername varchar(120) null,
    driverranking int null,
    rallyname varchar(120) not null,
    stageno int null,
    stagetime time null
);

insert into car_rally_result_unf values
(1, 'driver a', 11, 'codriver x', 1, 'rally one', 1, '00:10:30'),
(1, 'driver a', 11, 'codriver x', 1, 'rally one', 2, '00:09:55'),
(2, 'driver b', 12, 'codriver y', 2, 'rally one', 1, '00:11:10'),
(2, 'driver b', 12, 'codriver y', 2, 'rally one', 2, '00:10:40'),
(1, 'driver a', 11, 'codriver x', 1, 'rally two', 1, '00:08:20');

select rallyname, driverid, count(*) as rows_cnt
from car_rally_result_unf
group by rallyname, driverid
having count(*) > 1;

create table rallyentry_1nf (
    rallyname varchar(120) not null,
    driverid int not null,
    drivername varchar(120) null,
    codriverid int null,
    codrivername varchar(120) null,
    driverranking int null,
    constraint pk_rallyentry_1nf primary key (rallyname, driverid)
);
create table rallystage_1nf (
    rallyname varchar(120) not null,
    driverid int not null,
    stageno int not null,
    stagetime time not null,
    constraint pk_rallystage_1nf primary key (rallyname, driverid, stageno)
);

insert into rallyentry_1nf
select distinct rallyname, driverid, drivername, codriverid, codrivername, driverranking
from car_rally_result_unf;

insert into rallystage_1nf
select distinct rallyname, driverid, stageno, stagetime
from car_rally_result_unf
where stageno is not null and stagetime is not null;

select * from rallyentry_1nf order by rallyname, driverid;
select * from rallystage_1nf order by rallyname, driverid, stageno;

create table person_2nf (
    personid int not null primary key,
    personname varchar(120) not null
);


create table rally_2nf (
    rallyname varchar(120) not null primary key
);


create table rallyentry_2nf (
    rallyname varchar(120) not null,
    driverid int not null,
    codriverid int null,
    driverranking int null,
    constraint pk_rallyentry_2nf primary key (rallyname, driverid)
);


create table rallystage_2nf (
    rallyname varchar(120) not null,
    driverid int not null,
    stageno int not null,
    stagetime time not null,
    constraint pk_rallystage_2nf primary key (rallyname, driverid, stageno)
);

insert into person_2nf (personid, personname)
select distinct driverid, drivername
from rallyentry_1nf
where driverid is not null and drivername is not null;

insert into person_2nf (personid, personname)
select distinct codriverid, codrivername
from rallyentry_1nf
where codriverid is not null and codrivername is not null
  and codriverid not in (select personid from person_2nf);

insert into rally_2nf
select distinct rallyname from rallyentry_1nf;

insert into rallyentry_2nf
select distinct rallyname, driverid, codriverid, driverranking
from rallyentry_1nf;

insert into rallystage_2nf
select distinct rallyname, driverid, stageno, stagetime
from rallystage_1nf;

select
    (select count(*) from car_rally_result_unf) as rows_unf,
    (select count(*) from rallystage_1nf) as rows_stage,
    (select count(*) from person_2nf) as rows_person;

create table person_3nf (
    personid int not null primary key,
    personname varchar(120) not null
);


create table rally_3nf (
    rallyname varchar(120) not null primary key
);


create table rallyentry_3nf (
    rallyname varchar(120) not null,
    driverid int not null,
    codriverid int null,
    driverranking int null,
    constraint pk_rallyentry_3nf primary key (rallyname, driverid),
    constraint fk_rallyentry_3nf_rally foreign key (rallyname) references rally_3nf(rallyname),
    constraint fk_rallyentry_3nf_driver foreign key (driverid) references person_3nf(personid),
    constraint fk_rallyentry_3nf_codriver foreign key (codriverid) references person_3nf(personid)
);


create table rallystage_3nf (
    rallyname varchar(120) not null,
    driverid int not null,
    stageno int not null,
    stagetime time not null,
    constraint pk_rallystage_3nf primary key (rallyname, driverid, stageno),
    constraint fk_rallystage_3nf_entry foreign key (rallyname, driverid)
        references rallyentry_3nf(rallyname, driverid)
);

insert into person_3nf select * from person_2nf;
insert into rally_3nf select * from rally_2nf;
insert into rallyentry_3nf select * from rallyentry_2nf;
insert into rallystage_3nf select * from rallystage_2nf;

select
    re.rallyname,
    re.driverid, d.personname as drivername,
    re.codriverid, cd.personname as codrivername,
    re.driverranking,
    st.stageno, st.stagetime
from rallyentry_3nf re
join person_3nf d on re.driverid = d.personid
left join person_3nf cd on re.codriverid = cd.personid
join rallystage_3nf st on re.rallyname = st.rallyname and re.driverid = st.driverid
order by re.rallyname, re.driverid, st.stageno;

create table computer_repair_unf (
    customerno int not null,
    customername varchar(120) null,
    customeraddress varchar(200) null,
    repairdate date not null,
    pcid int not null,
    make varchar(80) null,
    model varchar(80) null,
    technicianname varchar(120) null,
    techniciangrade varchar(40) null,
    repaircost decimal(12,2) null
);

insert into computer_repair_unf values
(1, 'ann', '1 main st', '2026-01-10', 100, 'dell', 'xps',   'tech a', 'g1', 120.00),
(1, 'ann', '1 main st', '2026-02-05', 100, 'dell', 'xps',   'tech b', 'g2', 200.00),
(2, 'bob', '2 main st', '2026-02-01', 200, 'hp',   'elite', 'tech a', 'g1',  90.00);

select customerno, customername, count(*) as repairs_cnt
from computer_repair_unf
group by customerno, customername;

select pcid, make, model, count(*) as repairs_cnt
from computer_repair_unf
group by pcid, make, model;

create table computer_repair_1nf (
    customerno int not null,
    customername varchar(120) null,
    customeraddress varchar(200) null,
    repairdate date not null,
    pcid int not null,
    make varchar(80) null,
    model varchar(80) null,
    technicianname varchar(120) null,
    techniciangrade varchar(40) null,
    repaircost decimal(12,2) null,
    constraint pk_computer_repair_1nf primary key (pcid, repairdate)
);

insert into computer_repair_1nf
select distinct * from computer_repair_unf;

select pcid, repairdate, count(*) as dup_cnt
from computer_repair_1nf
group by pcid, repairdate
having count(*) > 1;

create table customer_2nf (
    customerno int not null primary key,
    customername varchar(120) not null,
    customeraddress varchar(200) null
);

drop table if exists pc_2nf;
create table pc_2nf (
    pcid int not null primary key,
    make varchar(80) not null,
    model varchar(80) not null,
    customerno int not null
);

drop table if exists technician_2nf;
create table technician_2nf (
    technicianname varchar(120) not null primary key,
    techniciangrade varchar(40) not null
);

drop table if exists repair_2nf;
create table repair_2nf (
    pcid int not null,
    repairdate date not null,
    technicianname varchar(120) not null,
    repaircost decimal(12,2) null,
    constraint pk_repair_2nf primary key (pcid, repairdate)
);

insert into customer_2nf
select distinct customerno, customername, customeraddress
from computer_repair_1nf;

insert into pc_2nf
select distinct pcid, make, model, customerno
from computer_repair_1nf;

insert into technician_2nf
select distinct technicianname, techniciangrade
from computer_repair_1nf
where technicianname is not null;

insert into repair_2nf
select distinct pcid, repairdate, technicianname, repaircost
from computer_repair_1nf;

select
    (select count(*) from computer_repair_unf) as rows_unf,
    (select count(*) from customer_2nf) as rows_customer,
    (select count(*) from pc_2nf) as rows_pc,
    (select count(*) from repair_2nf) as rows_repair;
    
    create table techgrade_3nf (
    techniciangrade varchar(40) not null primary key,
    rate decimal(10,2) null
);

create table customer_3nf (
    customerno int not null primary key,
    customername varchar(120) not null,
    customeraddress varchar(200) null
);

create table pc_3nf (
    pcid int not null primary key,
    make varchar(80) not null,
    model varchar(80) not null,
    customerno int not null,
    constraint fk_pc_3nf_customer foreign key (customerno) references customer_3nf(customerno)
);

create table technician_3nf (
    technicianname varchar(120) not null primary key,
    techniciangrade varchar(40) not null,
    constraint fk_technician_3nf_grade foreign key (techniciangrade) references techgrade_3nf(techniciangrade)
);

create table repair_3nf (
    pcid int not null,
    repairdate date not null,
    technicianname varchar(120) not null,
    repaircost decimal(12,2) null,
    constraint pk_repair_3nf primary key (pcid, repairdate),
    constraint fk_repair_3nf_pc foreign key (pcid) references pc_3nf(pcid),
    constraint fk_repair_3nf_technician foreign key (technicianname) references technician_3nf(technicianname)
);

insert into customer_3nf select * from customer_2nf;
insert into pc_3nf select * from pc_2nf;

insert into techgrade_3nf (techniciangrade)
select distinct techniciangrade from technician_2nf;

update techgrade_3nf set rate = 12.00 where techniciangrade = 'g1';
select * from techgrade_3nf order by techniciangrade;

select
    r.pcid, p.make, p.model,
    c.customerno, c.customername, c.customeraddress,
    r.repairdate, r.repaircost,
    t.technicianname, t.techniciangrade, g.rate
from repair_3nf r
join pc_3nf p on r.pcid = p.pcid
join customer_3nf c on p.customerno = c.customerno
join technician_3nf t on r.technicianname = t.technicianname
join techgrade_3nf g on t.techniciangrade = g.techniciangrade
order by r.pcid, r.repairdate;

