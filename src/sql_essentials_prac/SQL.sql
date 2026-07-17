CREATE DATABASE Practice;

USE Practice;

DROP TABLE IF EXISTS LoginHistory;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department
(
    DeptID INT PRIMARY KEY,
    DeptName VARCHAR(30)
);

CREATE TABLE Employee
(
    EmpID INT,
    EmpName VARCHAR(50),
    DeptID INT,
    Gender VARCHAR(10),
    Salary INT,
    JoinDate DATE
);

CREATE TABLE LoginHistory
(
    UserID INT,
    LoginTime DATETIME
);

INSERT INTO Department VALUES
(1,'HR'),
(2,'IT'),
(3,'Finance'),
(4,'Sales');

INSERT INTO Employee VALUES
(1,'John',1,'Male',50000,'2024-01-10'),
(2,'Mary',2,'Female',70000,'2023-02-20'),
(3,'David',1,'Male',65000,'2022-06-11'),
(4,'Lisa',2,'Female',80000,'2021-09-15'),
(5,'Tom',3,'Male',60000,'2024-04-08'),
(6,'Rose',NULL,'Female',55000,'2025-01-12'),
(7,'John',1,'Male',50000,'2024-01-10');

INSERT INTO LoginHistory VALUES
(1,'2026-07-17 09:00:00'),
(1,'2026-07-17 09:15:00'),
(1,'2026-07-17 10:10:00'),
(1,'2026-07-17 10:20:00'),
(2,'2026-07-17 11:00:00'),
(2,'2026-07-17 12:00:00');

SELECT EmpName, Salary
FROM Employee
WHERE Salary > 55000
ORDER BY Salary DESC;

SELECT e.EmpName, d.DeptName
FROM Employee e
INNER JOIN Department d
ON e.DeptID = d.DeptID;

SELECT e.EmpName, d.DeptName
FROM Employee e
LEFT JOIN Department d
ON e.DeptID = d.DeptID;

SELECT e.EmpName, d.DeptName
FROM Employee e
FULL JOIN Department d
ON e.DeptID = d.DeptID;

SELECT *
FROM Employee e
WHERE EXISTS
(
    SELECT 1
    FROM Department d
    WHERE d.DeptID = e.DeptID
);

SELECT *
FROM Employee e
WHERE NOT EXISTS
(
    SELECT 1
    FROM Department d
    WHERE d.DeptID = e.DeptID
);

WITH RankedEmployees AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY DeptID
               ORDER BY Salary DESC
           ) AS rn
    FROM Employee
)
SELECT *
FROM RankedEmployees
WHERE rn = 1;

SELECT *
FROM
(
    SELECT Gender, EmpID
    FROM Employee
) AS SourceTable
PIVOT
(
    COUNT(EmpID)
    FOR Gender IN ([Male], [Female])
) AS PivotTable;

SELECT STRING_AGG(DeptName, ', ') AS Departments
FROM Department;

SELECT
    DeptID,
    STRING_AGG(EmpName, ', ') AS Employees
FROM Employee
GROUP BY DeptID;

SELECT
    GETDATE() AS Today,
    YEAR(GETDATE()) AS Year,
    MONTH(GETDATE()) AS Month,
    DAY(GETDATE()) AS Day;

SELECT
    DATEADD(DAY,10,GETDATE()) AS TenDaysLater;

SELECT
    DATEDIFF(DAY,'2026-01-01',GETDATE()) AS DaysPassed;

SELECT
    EmpName,
    UPPER(EmpName) AS UpperCase,
    LOWER(EmpName) AS LowerCase,
    LEN(EmpName) AS Length,
    SUBSTRING(EmpName,1,3) AS FirstThree,
    REPLACE(EmpName,'o','0') AS ReplaceLetter,
    TRIM('   SQL Server   ') AS TrimText
FROM Employee;

WITH DuplicateRows AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY EmpName, DeptID, Salary, JoinDate
               ORDER BY EmpID
           ) AS rn
    FROM Employee
)
SELECT *
FROM DuplicateRows
WHERE rn = 1;

SELECT
    EmpName,
    Salary,
    SUM(Salary) OVER(ORDER BY EmpID) AS RunningTotal
FROM Employee;

WITH Ranked AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY DeptID
               ORDER BY Salary DESC
           ) AS rn
    FROM Employee
)
SELECT *
FROM Ranked
WHERE rn <= 2;

WITH Sessions AS
(
    SELECT
        UserID,
        LoginTime,
        LAG(LoginTime) OVER
        (
            PARTITION BY UserID
            ORDER BY LoginTime
        ) AS PreviousLogin
    FROM LoginHistory
)
SELECT
    UserID,
    LoginTime,
    PreviousLogin,
    CASE
        WHEN PreviousLogin IS NULL
             OR DATEDIFF(MINUTE, PreviousLogin, LoginTime) > 30
        THEN 'New Session'
        ELSE 'Same Session'
    END AS SessionStatus
FROM Sessions;

SELECT *
FROM Employee
WHERE Salary =
(
    SELECT MAX(Salary)
    FROM Employee
);

SELECT
    DeptID,
    AVG(Salary) AS AverageSalary
FROM Employee
GROUP BY DeptID;

SELECT
    EmpName,
    DeptID,
    Salary
FROM Employee e
WHERE Salary >
(
    SELECT AVG(Salary)
    FROM Employee
    WHERE DeptID = e.DeptID
);