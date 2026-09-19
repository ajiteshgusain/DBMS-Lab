
create  database College_Record_Management_System;
use  College_Record_Management_System;
 
CREATE TABLE Faculty (
    FacultyID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Department VARCHAR(50)
);

-- 2. Create Student table with UNIQUE Email constraint
CREATE TABLE Student (
    StudentID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Branch VARCHAR(50),
    Year INT,
    Email VARCHAR(100) UNIQUE
);

-- 3. Create Course table with Foreign Key to Faculty
CREATE TABLE Course (
    CourseID INT PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    FacultyID INT,
    Credits INT,
    FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID)
);

-- 4. Create Exam table with Foreign Keys to Student and Course
CREATE TABLE Exam (
    ExamID INT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    Marks INT,
    FOREIGN KEY (StudentID) REFERENCES Student(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Course(CourseID)
);

-- 5. Verification using DESCRIBE
DESCRIBE Faculty;
DESCRIBE Student;
DESCRIBE Course;
DESCRIBE Exam;



-- Step 1: Populate Faculty Table
INSERT INTO Faculty (FacultyID, Name, Department) VALUES 
(1, 'Dr. Rao', 'CSE'),
(2, 'Dr. Iyer', 'CSE'),
(3, 'Dr. Mehta', 'ECE'),
(4, 'Dr. Singh', 'ECE');

-- Step 2: Populate Student Table (StudentID 108 left without exams for join tests)
INSERT INTO Student (StudentID, Name, Branch, Year, Email) VALUES 
(101, 'Aarav', 'CSE', 2, 'aarav@univ.edu'),
(102, 'Diya', 'CSE', 3, 'diya@univ.edu'),
(103, 'Kabir', 'ECE', 2, 'kabir@univ.edu'),
(104, 'Meera', 'ECE', 1, 'meera@univ.edu'),
(105, 'Sara', 'CSE', 3, 'sara@univ.edu'),
(106, 'Aman', 'CSE', 2, 'aman@univ.edu'),
(107, 'Riya', 'ECE', 1, 'riya@univ.edu'),
(108, 'Rohan', 'CSE', 4, 'rohan@univ.edu');

-- Step 3: Populate Course Table
INSERT INTO Course (CourseID, CourseName, FacultyID, Credits) VALUES 
(201, 'DBMS', 1, 4),
(202, 'Operating Systems', 2, 4),
(203, 'Networks', 3, 3),
(204, 'AI', 4, 3),
(205, 'Compilers', 1, 3);

-- Step 4: Populate Exam Table
INSERT INTO Exam (ExamID, StudentID, CourseID, Marks) VALUES 
(301, 101, 201, 78),
(302, 102, 201, 85),
(303, 105, 201, 81),
(304, 106, 201, 60),
(305, 101, 202, 70),
(306, 102, 202, 92),
(307, 104, 202, 55),
(308, 103, 203, 88),
(309, 106, 203, 74),
(310, 107, 203, 70),
(311, 105, 205, 90),
(312, 103, 204, 65);

-- Step 5: (a) Update Student Branch
UPDATE Student 
SET Branch = 'AIML' 
WHERE StudentID = 101;

-- Step 6: (b) Delete Exam Record (ExamID 312)
DELETE FROM Exam 
WHERE ExamID = 312;

-- Step 7: (c) Foreign Key Constraint Failure Test
INSERT INTO Exam (ExamID, StudentID, CourseID, Marks) 
VALUES (399, 999, 201, 90);




select  *  from  faculty,course,exam,student;


-- Question 3: Filtering, Sorting, and Aggregation SQL
-- (a) Filter students by Branch
SELECT * 
FROM Student 
WHERE Branch = 'CSE';

-- (b) Sort exam records by Marks descending
SELECT * 
FROM Exam 
ORDER BY Marks DESC;

-- (c) Average Marks per CourseID
SELECT CourseID, AVG(Marks) AS AvgMarks 
FROM Exam 
GROUP BY CourseID;

-- (d) Highest Marks per CourseID
SELECT CourseID, MAX(Marks) AS TopMarks 
FROM Exam 
GROUP BY CourseID;
-- Question 4: Join Operations SQL
-- (a) INNER JOIN: Exam results with Student Name and Course Name
SELECT e.ExamID, s.Name, c.CourseName, e.Marks 
FROM Exam e
JOIN Student s ON e.StudentID = s.StudentID
JOIN Course c ON e.CourseID = c.CourseID;

-- (b) LEFT JOIN: Every Student with Exam records (includes students without exams)
SELECT s.StudentID, s.Name, e.CourseID, e.Marks 
FROM Student s
LEFT JOIN Exam e ON s.StudentID = e.StudentID;

-- (c) RIGHT JOIN: Every Course with enrolled students' exam records
SELECT c.CourseID, c.CourseName, e.StudentID, e.Marks 
FROM Exam e
RIGHT JOIN Course c ON e.CourseID = c.CourseID;

-- (d) SELF JOIN: Pairs of faculty in the same Department
SELECT f1.Name AS Faculty1, f2.Name AS Faculty2, f1.Department 
FROM Faculty f1
JOIN Faculty f2 ON f1.Department = f2.Department 
               AND f1.FacultyID < f2.FacultyID;

-- Question 5: Subqueries and Set Operations SQL
-- 1. Subquery equivalent of Q4 INNER JOIN (Correlated Subquery)
SELECT ExamID, Marks, 
       (SELECT Name FROM Student WHERE StudentID = Exam.StudentID) AS StudentName
FROM Exam;

-- 2. Subquery equivalent of Q4 LEFT JOIN (Find students with no exams)
SELECT * 
FROM Student 
WHERE StudentID NOT IN (
    SELECT StudentID 
    FROM Exam 
    WHERE StudentID IS NOT NULL
);

-- 3. UNION: Combine high scorers (Marks >= 85) and students who took Course 201
SELECT StudentID FROM Exam WHERE Marks >= 85
UNION
SELECT StudentID FROM Exam WHERE CourseID = 201;

-- 4. INTERSECT (Emulated using IN for MySQL compatibility): High scorers in Course 201
SELECT StudentID 
FROM Exam 
WHERE Marks >= 85 
  AND StudentID IN (SELECT StudentID FROM Exam WHERE CourseID = 201);

-- 5. MINUS / EXCEPT (Emulated using NOT IN): Students in Student table but not in Exam
SELECT StudentID FROM Student 
WHERE StudentID NOT IN (SELECT StudentID FROM Exam);


-- Question 6: Views and Indexing SQL
-- 1. Create View for Q3 average marks query
CREATE VIEW CourseAverages AS 
SELECT CourseID, AVG(Marks) AS AvgMarks 
FROM Exam 
GROUP BY CourseID;

-- Query the view
SELECT * FROM CourseAverages;

-- 2. Check EXPLAIN before index creation
EXPLAIN SELECT * FROM Exam WHERE CourseID = 201;

-- 3. Create Index on Exam.CourseID
CREATE INDEX idx_exam_courseid ON Exam(CourseID);

-- 4. Check EXPLAIN after index creation (should show type=ref instead of ALL)
EXPLAIN SELECT * FROM Exam WHERE CourseID = 201;


-- Question 7: Window Functions and CTEs  SQL
-- 1. Rank students by Marks within each Course using RANK()
SELECT StudentID, CourseID, Marks,
       RANK() OVER (PARTITION BY CourseID ORDER BY Marks DESC) AS CourseRank
FROM Exam;

-- 2. Multi-stage CTE report combining total students, above-average counts, and pass rate
WITH CourseTotals AS (
    SELECT CourseID, COUNT(*) AS TotalStudents
    FROM Exam
    GROUP BY CourseID
),
CourseAvg AS (
    SELECT CourseID, AVG(Marks) AS AvgMarks
    FROM Exam
    GROUP BY CourseID
),
AboveAvg AS (
    SELECT e.CourseID, COUNT(*) AS AboveAvgCount
    FROM Exam e
    JOIN CourseAvg a ON e.CourseID = a.CourseID
    WHERE e.Marks > a.AvgMarks
    GROUP BY e.CourseID
),
PassStats AS (
    SELECT CourseID, 
           SUM(CASE WHEN Marks >= 40 THEN 1 ELSE 0 END) AS Passed,
           COUNT(*) AS Total
    FROM Exam
    GROUP BY CourseID
)
SELECT t.CourseID, 
       t.TotalStudents, 
       COALESCE(a.AboveAvgCount, 0) AS AboveAvgCount,
       ROUND(p.Passed * 100.0 / p.Total, 2) AS PassPercentage
FROM CourseTotals t
LEFT JOIN AboveAvg a ON t.CourseID = a.CourseID
JOIN PassStats p ON t.CourseID = p.CourseID;













