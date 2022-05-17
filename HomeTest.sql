--A table that ranks the 10 best customers to date (without customers who only bought in 2015)--

WITH "CTE_Q1" AS										
(										
SELECT customerID, (CASE WHEN YEAR([Date]) ='2015' THEN 0 ELSE 1 END) AS Y2015, Income										
FROM Sheet										
)										
SELECT TOP 10 SUM(Y2015) AS YearYear, customerID, SUM(Income) AS TotalIncome										
FROM "CTE_Q1"										
GROUP BY customerID										
HAVING SUM(Y2015)!=0										
ORDER BY TotalIncome DESC;											
										
-----------------------------------------------------------   
--A table that ranks the best 3 months--

WITH "CTE_Q2" AS										
(										
SELECT SUM(Income) AS TotalIncome, MONTH([Date]) AS Months , YEAR([Date]) AS Years										
FROM Sheet										
GROUP BY MONTH([Date]), YEAR([Date])										
)										
SELECT TOP 3 TotalIncome, Months, Years										
FROM "CTE_Q2"										
ORDER BY TotalIncome DESC;			

------------------------------------------------														
--Table at the monthly level of 2016--	

SELECT DATEPART(MONTH, [Date]) AS MonthDate, COUNT(DISTINCT customerID) AS NumOfCustomers,										
	COUNT(DISTINCT InvoiceID) AS NumOfInvoices, COUNT(ProductID) AS NumOfProducts, SUM(Income) AS Total,									
	SUM(CASE WHEN ProductID ='A' THEN Income ELSE 0 END) AS TotalA 									
FROM Sheet										
WHERE [Date] BETWEEN '01/01/2016' AND '12/31/2016'										
GROUP BY DATEPART(MONTH, [Date]);							

-----------------------------------------------							
--A customer-level table that shows
--Customer ID, revenue in 2015, revenue in 2016, has he ever purchased product A (yes / no),
--has his total revenue to date been higher than 1,000 (yes / no), how many invoices does he have to date--

SELECT customerID, SUM(CASE WHEN YEAR([Date])='2015' THEN Income ELSE 0 END) AS Income_2015,										
	SUM(CASE WHEN YEAR([Date])='2016' THEN Income ELSE 0 END) AS Income_2016,									
	IIF(MAX(CASE WHEN ProductID ='A' THEN 1 ELSE 0 END)=1, 'Yes', 'No') AS PurchasedProductA,									
	( IIF(SUM(Income)<1000, 'No', 'Yes')) AS TotalIncomeAbove1000,									
	COUNT(invoiceID) AS TotalInvoiced									
FROM Sheet										
GROUP BY customerID;										
										
----------------------------------------------								
--Table of number of customers by number of invoices and shows number of invoices per customer and how many customers in total--

WITH "CTE_Q5" AS										
(										
SELECT customerID, COUNT(InvoiceID) AS NumOfInvoices										
FROM Sheet										
GROUP BY customerID										
)										
SELECT COUNT(customerID) AS Customers, NumOfInvoices										
FROM "CTE_Q5"										
GROUP BY NumOfInvoices										
ORDER BY Customers DESC										
										
-----------------------------------------------									
--Customer-level table showing customer ID, last purchase date, penultimate purchase date--

WITH "CTE_Q6" AS										
(										
SELECT customerID, [Date], DENSE_RANK () OVER (PARTITION BY customerID ORDER BY [Date] DESC) RankDate										
FROM Sheet										
)										
SELECT DISTINCT customerID,  [DATE], RankDate										
FROM "CTE_Q6"										
WHERE RankDate<3										
ORDER BY customerID, [Date] DESC										
