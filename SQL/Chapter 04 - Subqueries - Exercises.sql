---------------------------------------------------------------------
-- Microsoft SQL Server 2012 T-SQL Fundamentals
-- Chapter 04 - Subqueries
-- Exercises
---------------------------------------------------------------------

-- 1 
-- Write a query that returns all orders placed on the last day of
-- activity that can be found in the Orders table
-- Tables involved: TSQL2012 database, Orders table

Select orderid, orderdate, custid, empid
From Sales.Orders
Where orderdate = (Select MAX(O.orderdate) From Sales.Orders As O)

--Desired output
orderid     orderdate               custid      empid
----------- ----------------------- ----------- -----------
11077       2008-05-06 00:00:00.000 65          1
11076       2008-05-06 00:00:00.000 9           4
11075       2008-05-06 00:00:00.000 68          8
11074       2008-05-06 00:00:00.000 73          7

(4 row(s) affected)

-- 2 (Optional, Advanced)
-- Write a query that returns all orders placed
-- by the customer(s) who placed the highest number of orders
-- * Note: there may be more than one customer
--   with the same number of orders
-- Tables involved: TSQL2012 database, Orders table

Select * From Sales.Orders

-- Solution reference
Select custid, orderid, orderdate, empid
From Sales.Orders
Where custid In
	(Select Top(1) with Ties O.custid
	 From Sales.Orders as O
	 Group By O.custid
	 Order By Count(*) Desc);

-- Desired output:
custid      orderid     orderdate               empid
----------- ----------- ----------------------- -----------
71          10324       2006-10-08 00:00:00.000 9
71          10393       2006-12-25 00:00:00.000 1
71          10398       2006-12-30 00:00:00.000 2
71          10440       2007-02-10 00:00:00.000 4
71          10452       2007-02-20 00:00:00.000 8
71          10510       2007-04-18 00:00:00.000 6
71          10555       2007-06-02 00:00:00.000 6
71          10603       2007-07-18 00:00:00.000 8
71          10607       2007-07-22 00:00:00.000 5
71          10612       2007-07-28 00:00:00.000 1
71          10627       2007-08-11 00:00:00.000 8
71          10657       2007-09-04 00:00:00.000 2
71          10678       2007-09-23 00:00:00.000 7
71          10700       2007-10-10 00:00:00.000 3
71          10711       2007-10-21 00:00:00.000 5
71          10713       2007-10-22 00:00:00.000 1
71          10714       2007-10-22 00:00:00.000 5
71          10722       2007-10-29 00:00:00.000 8
71          10748       2007-11-20 00:00:00.000 3
71          10757       2007-11-27 00:00:00.000 6
71          10815       2008-01-05 00:00:00.000 2
71          10847       2008-01-22 00:00:00.000 4
71          10882       2008-02-11 00:00:00.000 4
71          10894       2008-02-18 00:00:00.000 1
71          10941       2008-03-11 00:00:00.000 7
71          10983       2008-03-27 00:00:00.000 2
71          10984       2008-03-30 00:00:00.000 1
71          11002       2008-04-06 00:00:00.000 4
71          11030       2008-04-17 00:00:00.000 7
71          11031       2008-04-17 00:00:00.000 6
71          11064       2008-05-01 00:00:00.000 1

(31 row(s) affected)

-- 3
-- Write a query that returns employees
-- who did not place orders on or after May 1st, 2008
-- Tables involved: TSQL2012 database, Employees and Orders tables

Select * From HR.Employees
Select * From Sales.Orders

-- my solution
Select HRE1.empid, HRE1.firstname, HRE1.lastname
From HR.Employees as HRE1
	Left Outer Join
	(Select HRE.empid, HRE.firstname, HRE.lastname
	  From HR.Employees as HRE
		Right Outer Join
		Sales.Orders as SO
		on HRE.empid = SO.empid
	  Where SO.orderdate > '20080501'
	  ) as derived_t1
	on derived_t1.empid = HRE1.empid
Where derived_t1.empid is Null;

-- solution reference
SELECT empid, FirstName, lastname
FROM HR.Employees
WHERE empid NOT IN
  (SELECT O.empid
   FROM Sales.Orders AS O
   WHERE O.orderdate >= '20080501');

-- Desired output:
empid       FirstName  lastname
----------- ---------- --------------------
3           Judy       Lew
5           Sven       Buck
6           Paul       Suurs
9           Zoya       Dolgopyatova

(4 row(s) affected)

-- 4
-- Write a query that returns
-- countries where there are customers but not employees
-- Tables involved: TSQL2012 database, Customers and Employees tables

Select * From HR.Employees
Select * From Sales.Customers

Select Distinct SC.country
From Sales.Customers as SC
Where SC.country Not In
	(Select HRE.country
	 From HR.Employees as HRE
	 )
Order By SC.country ASC;

-- Desired output:
country
---------------
Argentina
Austria
Belgium
Brazil
Canada
Denmark
Finland
France
Germany
Ireland
Italy
Mexico
Norway
Poland
Portugal
Spain
Sweden
Switzerland
Venezuela

(19 row(s) affected)

-- 5
-- Write a query that returns for each customer
-- all orders placed on the customer's last day of activity
-- Tables involved: TSQL2012 database, Orders table

Select * From Sales.Orders
Where custid = 40

-- my solution
Select * From (
Select custid, orderid, orderdate, empid,
	Rank() Over(Partition By custid Order By orderdate Desc) as ranking
From Sales.Orders
) as a
Where a.ranking = 1

-- Solution reference
SELECT custid, orderid, orderdate, empid
FROM Sales.Orders AS O1
WHERE orderdate =
  (SELECT MAX(O2.orderdate)
   FROM Sales.Orders AS O2
   WHERE O2.custid = O1.custid)
ORDER BY custid;

-- Desired output:
custid      orderid     orderdate               empid
----------- ----------- ----------------------- -----------
1           11011       2008-04-09 00:00:00.000 3
2           10926       2008-03-04 00:00:00.000 4
3           10856       2008-01-28 00:00:00.000 3
4           11016       2008-04-10 00:00:00.000 9
5           10924       2008-03-04 00:00:00.000 3
...
87          11025       2008-04-15 00:00:00.000 6
88          10935       2008-03-09 00:00:00.000 4
89          11066       2008-05-01 00:00:00.000 7
90          11005       2008-04-07 00:00:00.000 2
91          11044       2008-04-23 00:00:00.000 4

(90 row(s) affected)

-- 6
-- Write a query that returns customers
-- who placed orders in 2007 but not in 2008
-- Tables involved: TSQL2012 database, Customers and Orders tables

Select * From Sales.Customers
Select * From Sales.Orders

-- my solution
Select custid, companyname
From Sales.Customers
Where custid In (
Select a.custid From 
	 (Select Distinct custid
	  From Sales.Orders
	  Where Year(orderdate) = '2007') as a
	Left Outer Join
	 (Select Distinct custid
	  From Sales.Orders
	  Where Year(orderdate) = '2008') as b
	On a.custid = b.custid
Where b.custid is Null
);

-- Solution reference
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
     AND O.orderdate >= '20070101'
     AND O.orderdate < '20080101')
  AND NOT EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
     AND O.orderdate >= '20080101'
     AND O.orderdate < '20090101');

-- Desired output:
custid      companyname
----------- ----------------------------------------
21          Customer KIDPX
23          Customer WVFAF
33          Customer FVXPQ
36          Customer LVJSO
43          Customer UISOJ
51          Customer PVDZC
85          Customer ENQZT

(7 row(s) affected)

-- 7 (Optional, Advanced)
-- Write a query that returns customers
-- who ordered product 12
-- Tables involved: TSQL2012 database,
-- Customers, Orders and OrderDetails tables

Select * From Sales.Customers
Select * From Sales.Orders
Select * From Sales.OrderDetails

-- my solution
Select custid, companyname
From Sales.Customers
Where custid In
	(Select custid
	 From Sales.Orders as SO
	   Left Outer Join
	 Sales.OrderDetails as SOD
	 on SO.orderid = SOD.orderid
	 Where SOD.productid = 12
	 )

-- Solution reference
SELECT custid, companyname
FROM Sales.Customers AS C
WHERE EXISTS
  (SELECT *
   FROM Sales.Orders AS O
   WHERE O.custid = C.custid
     AND EXISTS
       (SELECT *
        FROM Sales.OrderDetails AS OD
        WHERE OD.orderid = O.orderid
          AND OD.ProductID = 12));

-- Desired output:
custid      companyname
----------- ----------------------------------------
48          Customer DVFMB
39          Customer GLLAG
71          Customer LCOUJ
65          Customer NYUHS
44          Customer OXFRU
51          Customer PVDZC
86          Customer SNXOJ
20          Customer THHDP
90          Customer XBBVR
46          Customer XPNIK
31          Customer YJCBX
87          Customer ZHYOS

(12 row(s) affected)

-- 8 (Optional, Advanced)
-- Write a query that calculates a running total qty
-- for each customer and month using subqueries
-- Tables involved: TSQL2012 database, Sales.CustOrders view

Select * From Sales.CustOrders
Order By custid, ordermonth

--
Select custid, ordermonth, qty,
	(Select SUM(O2.qty)
	 From Sales.CustOrders As O2
	 Where O2.custid = O1.custid
	   And O2.ordermonth <= O1.ordermonth) as runqty
From Sales.CustOrders As O1
ORder By custid, ordermonth;

-- Desired output:
custid      ordermonth              qty         runqty
----------- ----------------------- ----------- -----------
1           2007-08-01 00:00:00.000 38          38
1           2007-10-01 00:00:00.000 41          79
1           2008-01-01 00:00:00.000 17          96
1           2008-03-01 00:00:00.000 18          114
1           2008-04-01 00:00:00.000 60          174
2           2006-09-01 00:00:00.000 6           6
2           2007-08-01 00:00:00.000 18          24
2           2007-11-01 00:00:00.000 10          34
2           2008-03-01 00:00:00.000 29          63
3           2006-11-01 00:00:00.000 24          24
3           2007-04-01 00:00:00.000 30          54
3           2007-05-01 00:00:00.000 80          134
3           2007-06-01 00:00:00.000 83          217
3           2007-09-01 00:00:00.000 102         319
3           2008-01-01 00:00:00.000 40          359
...

(636 row(s) affected)
