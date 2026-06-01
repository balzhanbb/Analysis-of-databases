create database practice5;
use practice5;

-- INSTRUCTOR
CREATE TABLE Instructor (
    Instructor_ID   INT PRIMARY KEY,
    Instructor_Name VARCHAR(200) NOT NULL
);

-- COURSE
CREATE TABLE Course (
    Course_ID     INT PRIMARY KEY,
    Course_Title  VARCHAR(200) NOT NULL,
    Instructor_ID INT NOT NULL,
    Course_Price  DECIMAL(12,2) NOT NULL CHECK (Course_Price >= 0),
    CONSTRAINT FK_Course_Instructor
        FOREIGN KEY (Instructor_ID) REFERENCES Instructor(Instructor_ID)
);

-- STUDENT
CREATE TABLE Student (
    Student_ID    INT PRIMARY KEY,
    Student_Name  VARCHAR(200) NOT NULL,
    Student_Email VARCHAR(320) NOT NULL UNIQUE
);

-- ENROLLMENT
CREATE TABLE Enrollment (
    Student_ID      INT NOT NULL,
    Course_ID       INT NOT NULL,
    Enrollment_Date DATE NOT NULL,
    CONSTRAINT PK_Enrollment PRIMARY KEY (Student_ID, Course_ID),
    CONSTRAINT FK_Enrollment_Student
        FOREIGN KEY (Student_ID) REFERENCES Student(Student_ID),
    CONSTRAINT FK_Enrollment_Course
        FOREIGN KEY (Course_ID) REFERENCES Course(Course_ID)
);