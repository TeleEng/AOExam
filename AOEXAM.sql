-- First we create the tables, one with copying from excel and the other one from inserting directly
CREATE TABLE SaleTable
(
SalesID INT,
OrderID INT,
Customer VARCHAR(50),
Product	VARCHAR(50),
Date_ INT,	
Quantity INT,
UnitPrice INT
)

CREATE TABLE SaleProfit
(
Product VARCHAR(50),
ProfitRatio decimal(5,2)
)
insert into SaleProfit values ('P1', 0.05);
insert into SaleProfit values ('P2', 0.25);
insert into SaleProfit values ('P3', 0.10);
insert into SaleProfit values ('P4', 0.20);
insert into SaleProfit values ('P5', 0.10);
insert into SaleProfit values ('P6', 0.10);
------------------------------------------------------------------------------------
-- Questions Query
-- Q1 - Total Sale
ALTER TABLE [dbo].[SaleTable]
ADD Price as (Quantity * UnitPrice);
SELECT SUM(Price) AS TotalPrice
FROM [dbo].[SaleTable];
-- Answer: 35050
------------------------------------------------------------------------------------
-- Q2 - Unique Customer
SELECT DISTINCT Customer
FROM [dbo].[SaleTable];
-- Answer: C1 C2 C3 C4 C5 C6 C7 C8 C9
------------------------------------------------------------------------------------
-- Q3 - Sale Per Product
SELECT Product, SUM(Price) AS TotalSales
FROM [dbo].[SaleTable]
GROUP BY Product;
--Answer: P1: 3900, P2: 4050, P3: 4800, P4: 11550, P5: 8800, P6: 1950
------------------------------------------------------------------------------------
-- Q4 - Query for Customers With 1 purchase > 1500
SELECT Customer,
       COUNT(*) AS NumberOfPurchase,
       SUM(Price) AS TotalPrice,
       SUM(Quantity) AS TotalQuantity
FROM [dbo].[SaleTable]
WHERE Customer IN (
    SELECT Customer
    FROM [dbo].[SaleTable]
    WHERE Price > 1500
    GROUP BY Customer
)
GROUP BY Customer;
-- Answer: 
-- C1	5	5150	17
-- C2	11	9150	36
-- C3	4	4150	14
-- C4	5	5100	17
-- C5	5	3300	18
-- C6	3	3150	11
-- C8	3	3500	14
------------------------------------------------------------------------------------
-- Q5 - Profit Amount and Percentage
SELECT 
    SUM(Price * ProfitRatio) AS TotalProfitAmount,
    SUM(Price * ProfitRatio) / SUM(Price)*100 AS TotalProfitPercentage
FROM
    [dbo].[SaleTable]
JOIN
     [dbo].[SaleProfit] ON [dbo].[SaleTable].Product = [dbo].[SaleProfit].Product;
-- Answer: TotalProfitAmount = 5072.50, TotalProfitPercentage=14.4721
------------------------------------------------------------------------------------
-- Q6 (A) Unique Customer Per Date, Sum of Customer Per Date
SELECT
    Date_,
    COUNT(DISTINCT Customer) AS NumberOfUniqueCustomers
FROM
     [dbo].[SaleTable]
GROUP BY
    Date_;
-- Answer: Date1: 5, Date2: 4, Date3: 4
SELECT
    SUM(UniqueCustomersPerDay) AS TotalUniqueCustomers
FROM
    (SELECT
        Date_,
        COUNT(DISTINCT Customer) AS UniqueCustomersPerDay
    FROM
        [dbo].[SaleTable]
    GROUP BY
        Date_) AS Subquery;
-- Answer: TotalUniqueCustomers = 13
------------------------------------------------------------------------------------
-- Q6 (B) Organization Chart
CREATE TABLE OrganizationChart
(
ID INT,
Name_ VARCHAR(50),
Manager VARCHAR(50), 
ManagerID INT
)

WITH RecursiveCTE AS
(
    SELECT
        ID = O.ID,
        ManagerID = NULL,
        HierarchyLevel = 1,
        HierarchyRoute = CONVERT(VARCHAR(MAX), O.ID)
    FROM
        OrganizationChart AS O
    WHERE
        O.ManagerID IS NULL

    UNION ALL

    SELECT
        EmployeeID = O.ID,
        ManagerID = O.ManagerID,
        HierarchyLevel = R.HierarchyLevel + 1,
        HierarchyRoute = R.HierarchyRoute + '->' + CONVERT(VARCHAR(10), O.ID)
    FROM
        RecursiveCTE AS R
        INNER JOIN OrganizationChart AS O ON R.ID = O.ManagerID
)
SELECT
    R.HierarchyLevel,
    R.ID,
    R.ManagerID,
    R.HierarchyRoute
FROM
    RecursiveCTE AS R
ORDER BY
    R.HierarchyLevel,
    R.ID

-- Answer
-- LVL  ID		ManagerID	Route
-- 1	1		NULL		1
-- 1	2		NULL	    2
-- 2	12		1			1->12
-- 2	15		2			2->15
-- 3	5		12			1->12->5
-- 3	8		12			1->12->8
-- 3	9		15			2->15->9
-- 3	10		12			1->12->10
-- 3	13		15			2->15->13
-- 4	3		5			1->12->5->3
-- 4	4		13			2->15->13->4
-- 4	11		5			1->12->5->11
-- 4	14		13			2->15->13->14
-- 4	16		8			1->12->8->16
-- 4	17		10			1->12->10->17
-- 4	18		9			2->15->9->18
-- 4	20		10			1->12->10->20
-- 4	21		9			2->15->9->21
-- 4	22		9			2->15->9->22
-- 4	23		13			2->15->13->23
-- 5	6		21			2->15->9->21->6
-- 5	7		11			1->12->5->11->7
-- 5	19		11			1->12->5->11->19
-- 5	25		4			2->15->13->4->25
-- 6	24		6			2->15->9->21->6->24