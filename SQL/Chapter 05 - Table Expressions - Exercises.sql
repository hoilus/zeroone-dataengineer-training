---------------------------------------------------------------------
-- Microsoft SQL Server 2012 T-SQL Fundamentals
-- Chapter 05 - Table Expressions
-- Exercises

---------------------------------------------------------------------

-- 1-1
-- Write a query that returns the maximum order date for each employee
-- Tables involved: TSQL2012 database, Sales.Orders table

Select * From Sales.Orders

-- my solution (output 10 rows)
Select SO1.empid, SO1.orderdate as maxorderdate
From Sales.Orders as SO1
Where SO1.orderdate = 
	(Select MAX(orderdate)
	 From Sales.Orders as SO2
	 Where SO2.empid = SO1.empid
	 )
Order By SO1.empid

-- solution reference
SELECT empid, MAX(orderdate) AS maxorderdate
FROM Sales.Orders
GROUP BY empid;

--Desired output
empid       maxorderdate
----------- -----------------------
3           2008-04-30 00:00:00.000
6           2008-04-23 00:00:00.000
9           2008-04-29 00:00:00.000
7           2008-05-06 00:00:00.000
1           2008-05-06 00:00:00.000
4           2008-05-06 00:00:00.000
2           2008-05-05 00:00:00.000
5           2008-04-22 00:00:00.000
8           2008-05-06 00:00:00.000

(9 row(s) affected)

-- 1-2
-- Encapsulate the query from exercise 1-1 in a derived table
-- Write a join query between the derived table and the Sales.Orders
-- table to return the Sales.Orders with the maximum order date for 
-- each employee
-- Tables involved: Sales.Orders

-- my solution
Select SO1.empid, SO1.orderdate as maxorderdate, SO1.orderid, SO1.custid
From Sales.Orders as SO1
Where SO1.orderdate = 
	(Select MAX(orderdate)
	 From Sales.Orders as SO2
	 Where SO2.empid = SO1.empid
	 );

-- Solution reference
SELECT O.empid, O.orderdate, O.orderid, O.custid
FROM Sales.Orders AS O
  JOIN (SELECT empid, MAX(orderdate) AS maxorderdate
        FROM Sales.Orders
        GROUP BY empid) AS D
    ON O.empid = D.empid
    AND O.orderdate = D.maxorderdate;

-- Desired output:
empid       orderdate               orderid     custid
----------- ----------------------- ----------- -----------
9           2008-04-29 00:00:00.000 11058       6
8           2008-05-06 00:00:00.000 11075       68
7           2008-05-06 00:00:00.000 11074       73
6           2008-04-23 00:00:00.000 11045       10
5           2008-04-22 00:00:00.000 11043       74
4           2008-05-06 00:00:00.000 11076       9
3           2008-04-30 00:00:00.000 11063       37
2           2008-05-05 00:00:00.000 11073       58
2           2008-05-05 00:00:00.000 11070       44
1           2008-05-06 00:00:00.000 11077       65

(10 row(s) affected)

-- 2-1
-- Write a query that calculates a row number for each order
-- based on orderdate, orderid ordering
-- Tables involved: Sales.Orders

Select * From Sales.Orders

Select orderid, orderdate, custid, empid, 
	ROW_NUMBER() Over(Order By orderdate, orderid) as rownum 
From Sales.Orders;

-- Desired output:
orderid     orderdate               custid      empid       rownum
----------- ----------------------- ----------- ----------- -------
10248       2006-07-04 00:00:00.000 85          5           1
10249       2006-07-05 00:00:00.000 79          6           2
10250       2006-07-08 00:00:00.000 34          4           3
10251       2006-07-08 00:00:00.000 84          3           4
10252       2006-07-09 00:00:00.000 76          4           5
10253       2006-07-10 00:00:00.000 34          3           6
10254       2006-07-11 00:00:00.000 14          5           7
10255       2006-07-12 00:00:00.000 68          9           8
10256       2006-07-15 00:00:00.000 88          3           9
10257       2006-07-16 00:00:00.000 35          4           10
...

(830 row(s) affected)

-- 2-2
-- Write a query that returns rows with row numbers 11 through 20
-- based on the row number definition in exercise 2-1
-- Use a CTE to encapsulate the code from exercise 2-1
-- Tables involved: Sales.Orders

-- my solution
Select orderid, orderdate, custid, empid, 
	ROW_NUMBER() Over(Order By orderdate, orderid) as rownum 
From Sales.Orders
Order By rownum
	OFFSET 10 Rows Fetch Next 10 Rows Only;

-- Solution reference
WITH OrdersRN AS
(
  SELECT orderid, orderdate, custid, empid,
    ROW_NUMBER() OVER(ORDER BY orderdate, orderid) AS rownum
  FROM Sales.Orders
)
SELECT * FROM OrdersRN WHERE rownum BETWEEN 11 AND 20;

-- Desired output:
orderid     orderdate               custid      empid       rownum
----------- ----------------------- ----------- ----------- -------
10258       2006-07-17 00:00:00.000 20          1           11
10259       2006-07-18 00:00:00.000 13          4           12
10260       2006-07-19 00:00:00.000 56          4           13
10261       2006-07-19 00:00:00.000 61          4           14
10262       2006-07-22 00:00:00.000 65          8           15
10263       2006-07-23 00:00:00.000 20          9           16
10264       2006-07-24 00:00:00.000 24          6           17
10265       2006-07-25 00:00:00.000 7           2           18
10266       2006-07-26 00:00:00.000 87          3           19
10267       2006-07-29 00:00:00.000 25          4           20

(10 row(s) affected)

-- 3 (Optional, Advanced)
-- Write a solution using a recursive CTE that returns the 
-- management chain leading to Zoya Dolgopyatova (employee ID 9)
-- Tables involved: HR.Employees

Select * From HR.Employees

Declare @empid As Int = 9;

With MgrChain As
(
 Select empid, mgrid, firstname, lastname
 From HR.Employees
 Where empid = @empid

 Union All

 Select P.empid, P.mgrid, P.firstname, P.lastname
 From Mgrchain As C
	Inner Join HR.Employees As P
	On P.empid = C.mgrid
)
Select empid, mgrid, firstname, lastname
From MgrChain;


-- Solution reference
WITH EmpsCTE AS
(
  SELECT empid, mgrid, firstname, lastname
  FROM HR.Employees
  WHERE empid = 9
  
  UNION ALL
  
  SELECT P.empid, P.mgrid, P.firstname, P.lastname
  FROM EmpsCTE AS C
    JOIN HR.Employees AS P
      ON C.mgrid = P.empid
)
SELECT empid, mgrid, firstname, lastname
FROM EmpsCTE;


-- Desired output:
empid       mgrid       firstname  lastname
----------- ----------- ---------- --------------------
9           5           Zoya       Dolgopyatova
5           2           Sven       Buck
2           1           Don        Funk
1           NULL        Sara       Davis

(4 row(s) affected)

-- 4-1
-- Create a view that returns the total qty
-- for each employee and year
-- Tables involved: Sales.Orders and Sales.OrderDetails
Use TSQL2012
Select * From Sales.Orders
Select * From Sales.OrderDetails

-- my solution
If OBJECT_ID('Sales.VEmpOrders') is Not Null
	Drop View Sales.VEmpOrders;
Go
Create View Sales.VEmpOrders
As

Select empid, Year(orderdate) as orderyear, 
	Sum(qty) As qty
From Sales.Orders As SO
	Inner Join Sales.OrderDetails As SOD
	On SO.orderid = SOD.orderid
Group By empid, Year(orderdate);

Select * From Sales.VEmpOrders
Order By empid, orderyear;

-- Desired output when running:
-- SELECT * FROM  Sales.VEmpOrders ORDER BY empid, orderyear
empid       orderyear   qty
----------- ----------- -----------
1           2006        1620
1           2007        3877
1           2008        2315
2           2006        1085
2           2007        2604
2           2008        2366
3           2006        940
3           2007        4436
3           2008        2476
4           2006        2212
4           2007        5273
4           2008        2313
5           2006        778
5           2007        1471
5           2008        787
6           2006        963
6           2007        1738
6           2008        826
7           2006        485
7           2007        2292
7           2008        1877
8           2006        923
8           2007        2843
8           2008        2147
9           2006        575
9           2007        955
9           2008        1140

(27 row(s) affected)

-- 4-2 (Optional, Advanced)
-- Write a query against Sales.VEmpOrders
-- that returns the running qty for each employee and year
-- Tables involved: TSQL2012 database, Sales.VEmpOrders view

-- my solution
Select empid, orderyear, qty,
	(Select Sum(qty)
	 From Sales.VEmpOrders As V1
	 Where V1.empid = V2.empid
		And V1.orderyear <= V2.orderyear) As runqty
From Sales.VEmpOrders As V2
Order By empid, orderyear;

-- Desired output:
empid       orderyear   qty         runqty
----------- ----------- ----------- -----------
1           2006        1620        1620
1           2007        3877        5497
1           2008        2315        7812
2           2006        1085        1085
2           2007        2604        3689
2           2008        2366        6055
3           2006        940         940
3           2007        4436        5376
3           2008        2476        7852
4           2006        2212        2212
4           2007        5273        7485
4           2008        2313        9798
5           2006        778         778
5           2007        1471        2249
5           2008        787         3036
6           2006        963         963
6           2007        1738        2701
6           2008        826         3527
7           2006        485         485
7           2007        2292        2777
7           2008        1877        4654
8           2006        923         923
8           2007        2843        3766
8           2008        2147        5913
9           2006        575         575
9           2007        955         1530
9           2008        1140        2670

(27 row(s) affected)

-- 5-1
-- Create an inline function that accepts as inputs
-- a supplier id (@supid AS INT), 
-- and a requested number of products (@n AS INT)
-- The function should return @n products with the highest unit prices
-- that are supplied by the given supplier id
-- Tables involved: Production.Products

-- Desired output when issuing the following query:
-- SELECT * FROM Production.TopProducts(5, 2)

-- my solution
Use TSQL2012;
Go
Select * From Production.Products
IF OBJECT_ID('Production.TopProducts') is Not Null
	Drop Function Production.TopProducts;
Go

Create Function Production.TopProducts
	(@supid As INT, @n As INT)
	Returns Table
As
Return
	Select Top (@n) productid, productname, unitprice
	From Production.Products
	Where supplierid = @supid 
	Order By unitprice Desc

Select * From Production.TopProducts(5, 2)

productid   productname                              unitprice
----------- ---------------------------------------- ---------------------
12          Product OSFNS                            38.00
11          Product QMVUN                            21.00

(2 row(s) affected)

-- 5-2
-- Using the CROSS APPLY operator
-- and the function you created in exercise 5-1,
-- return, for each supplier, the two most expensive products

-- my solution
Select P.supplierid, P.companyname, T.productid, T.productname, T.unitprice
From Production.Suppliers As P
	Cross Apply Production.TopProducts(supplierid, 2) As T;

-- Desired output 
supplierid  companyname     productid   productname     unitprice
----------- --------------- ----------- --------------- ----------
8           Supplier BWGYE  20          Product QHFFP   81.00
8           Supplier BWGYE  68          Product TBTBL   12.50
20          Supplier CIYNM  43          Product ZZZHR   46.00
20          Supplier CIYNM  44          Product VJIEO   19.45
23          Supplier ELCRN  49          Product FPYPN   20.00
23          Supplier ELCRN  76          Product JYGFE   18.00
5           Supplier EQPNC  12          Product OSFNS   38.00
5           Supplier EQPNC  11          Product QMVUN   21.00
...

(55 row(s) affected)

-- When you抮e done, run the following code for cleanup:
IF OBJECT_ID('Sales.VEmpOrders') IS NOT NULL
  DROP VIEW Sales.VEmpOrders;
IF OBJECT_ID('Production.TopProducts') IS NOT NULL
  DROP FUNCTION Production.TopProducts;
