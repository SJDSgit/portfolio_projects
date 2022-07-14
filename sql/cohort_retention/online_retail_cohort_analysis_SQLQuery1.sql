SELECT * 
FROM OnlineRetail;

--Cleaning Data

--Total Records = 541909
SELECT COUNT(*) total_records 
FROM OnlineRetail;

--135080 records have no CustomerID
SELECT COUNT(*) cust_no_id 
FROM OnlineRetail 
WHERE CustomerID IS NULL;

--406829 records have CustomerID
SELECT COUNT(*) cust_id 
FROM OnlineRetail 
WHERE CustomerID IS NOT NULL;

--CTE
WITH online_retail AS
(
	SELECT * 
	FROM OnlineRetail 
	WHERE CustomerID IS NOT NULL
), 
quantity_unit_price AS
(
	SELECT * 
	FROM online_retail 
	WHERE Quantity > 0 and UnitPrice > 0
), 
dup_check AS
(
	--Duplicate check
	SELECT *, ROW_NUMBER() OVER(partition by InvoiceNo, StockCode, Quantity ORDER BY InvoiceNo) dup_flag 
	FROM quantity_unit_price
)
	SELECT * 
	INTO #online_retail_main 
	FROM dup_check 
	WHERE dup_flag=1;
/*
The online_retail temporary table  reduces the records to 406829 records where customerid is not null
The quantity_unit_price temporary table  reduces the records to 397884 records where quantity and unit price > 0
The dup_check temporary table  reduces the records to 392669 records where all entries are unique
5215 duplicate record
*/

--Clean Dataset
SELECT * 
FROM #online_retail_main;

/*
Unique Identifier (CustomerID)
Initial Start Date (First Invoice Date)
Revenue Data
*/

SELECT CustomerID, MIN(InvoiceDate) first_purchase_date, DATEFROMPARTS(YEAR(MIN(InvoiceDate)),MONTH(MIN(InvoiceDate)),1) cohort_date
INTO #cohort
FROM #online_retail_main
GROUP BY CustomerID;

SELECT * 
FROM #cohort;

--Create Cohort Index
Select sub1.*, cohort_index = year_diff * 12 + month_diff + 1
INTO #cohort_retention
FROM	(
		SELECT sub.*, year_diff = invoice_year - cohort_year, month_diff = invoice_month - cohort_month
		FROM	(
				SELECT m.*, c.cohort_date, YEAR(m.InvoiceDate) invoice_year, MONTH(m.InvoiceDate) invoice_month, YEAR(c.cohort_date) cohort_year, MONTH(c.cohort_date) cohort_month
				FROM #online_retail_main m left join #cohort c ON m.CustomerID = c.CustomerID
				) sub
		) sub1;


SELECT * FROM #cohort_retention

--Pivot Data to see cohort table
SELECT *
INTO #cohort_pivot
FROM
		(
		SELECT DISTINCT CustomerID, Cohort_Date, Cohort_index 
		FROM #cohort_retention
		) sub
PIVOT (
COUNT(CustomerID) FOR Cohort_Index IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13])
) AS pivot_table
ORDER BY cohort_Date;

SELECT 	Cohort_Date,	
		CAST((1.0 * [1]/[1] * 100) AS DECIMAL (5,2)) AS [1],
		CAST((1.0 * [2]/[1] * 100) AS DECIMAL (5,2)) AS [2], 
		CAST((1.0 * [3]/[1] * 100) AS DECIMAL (5,2)) AS [3], 
		CAST((1.0 * [4]/[1] * 100) AS DECIMAL (5,2)) AS [4], 
		CAST((1.0 * [5]/[1] * 100) AS DECIMAL (5,2)) AS [5], 
		CAST((1.0 * [6]/[1] * 100) AS DECIMAL (5,2)) AS [6], 
		CAST((1.0 * [7]/[1] * 100) AS DECIMAL (5,2)) AS [7],
		CAST((1.0 * [8]/[1] * 100) AS DECIMAL (5,2)) AS [8],
		CAST((1.0 * [9]/[1] * 100) AS DECIMAL (5,2)) AS [9],
		CAST((1.0 * [10]/[1] * 100) AS DECIMAL (5,2)) AS [10],
		CAST((1.0 * [11]/[1] * 100) AS DECIMAL (5,2)) AS [11],
		CAST((1.0 * [12]/[1] * 100) AS DECIMAL (5,2)) AS [12],
		CAST((1.0 * [13]/[1] * 100) AS DECIMAL (5,2)) AS [13] 
FROM #cohort_pivot 
ORDER BY Cohort_Date