/* Telecom Customer Churn Analysis */

-- Check for duplicates
SELECT [Customer ID], COUNT(*) AS occurrences 
FROM [dbo].[telecom_customer_churn]
GROUP BY [Customer ID]
HAVING COUNT(*) > 1

-- How many customer joined the company during the last quarter
WITH LastQuarter AS (
			SELECT DATEADD(MONTH, -3, GETDATE()) AS "StartofLastQuarter"
			)
SELECT COUNT(*) AS  customer_joined_last_quarter
FROM [dbo].[telecom_customer_churn]
WHERE DATEADD(MONTH, -[Tenure in Months],GETDATE()) >=
		(SELECT StartofLastQuarter
		FROM LastQuarter);

--What are the key drivers of customer churn
SELECT [Customer Status], [Churn Reason], COUNT(*) AS customers
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned'
GROUP BY [Customer Status], [Churn Reason]
ORDER BY COUNT(*) DESC;

-- What contracts has the most churned
SELECT [Contract], 
		COUNT(*) AS customers,
		ROUND((COUNT(*) * 100 / SUM(COUNT(*)) OVER()), 1) AS per
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned'
GROUP BY [Contract]
ORDER BY COUNT(*) DESC

-- Did churn customers subscribed for premium tech support 
SELECT [Premium Tech Support], 
		COUNT(*) AS customers,
		ROUND((COUNT(*) * 100.0/ SUM(COUNT(*)) OVER()), 1) AS per
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned'
GROUP BY [Premium Tech Support]
ORDER BY COUNT(*) DESC

-- What internet type do churners subscribe for
SELECT [Internet Type], 
		COUNT(*) AS customers,
		ROUND((COUNT(*) * 100.0/ SUM(COUNT(*)) OVER()), 1) AS per
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned'
GROUP BY [Internet Type]
ORDER BY COUNT(*) DESC

-- what marketing offers are churners on
SELECT [Offer], 
		COUNT(*) AS customers,
		ROUND((COUNT(*) * 100.0/ SUM(COUNT(*)) OVER()), 1) AS per
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] = 'Churned'
GROUP BY [Offer]
ORDER BY COUNT(*) DESC

--Identify High-value customers at risk of churning
-- Offer 1
-- Internet Type 1
-- Contract 1
--Premium Tech Support 1

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY [Monthly Charge]) OVER () AS MedianMonthlyCharge
FROM [dbo].[telecom_customer_churn]

SELECT [Customer ID],
		[offer],
		[Internet Type],
		[Contract],
		[Premium Tech Support],
	CASE
		WHEN(
			CASE WHEN [Offer] = 'None' THEN 1 ELSE 0 END +
			CASE WHEN [Internet Type] = 'Fiber Optic' THEN 1 ELSE 0 END +
			CASE WHEN [Contract] = 'Month-to-Month' THEN 1 ELSE 0 END +
			CASE WHEN [Premium Tech Support] = 'No' THEN 1 ELSE 0 END)
			>= 3 THEN 'High Risk'
		WHEN(
			CASE WHEN [Offer] = 'None' THEN 1 ELSE 0 END +
			CASE WHEN [Internet Type] = 'Fiber Optic' THEN 1 ELSE 0 END +
			CASE WHEN [Contract] = 'Month-to-Month' THEN 1 ELSE 0 END +
			CASE WHEN [Premium Tech Support] = 'No' THEN 1 ELSE 0 END)
			= 2 THEN 'Medium Risk'
			ELSE 'Low Risk'
			END AS "Risk Level"
FROM [dbo].[telecom_customer_churn]
WHERE [Customer Status] != 'Churned'

--referrals > 0
--monthly charge > Median
--tenure in months > 9 Month
--Identify High-value customers at risk of churning

SELECT [Customer ID],
		[Number of Referrals],
		[Tenure in Months],
	CASE
		WHEN [Number of Referrals] > 0 
		AND [Monthly Charge] >= (SELECT TOP(1) PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY [Monthly Charge]) OVER ())
		AND [Tenure in Months] > 9
		THEN 'High Value'
		WHEN  [Tenure in Months] > 9
		THEN 'Medium Value'
		ELSE 'Low Value'
		END AS "CustomerValue",
		CASE
		WHEN(
			CASE WHEN [Offer] = 'None' THEN 1 ELSE 0 END +
			CASE WHEN [Internet Type] = 'Fiber Optic' THEN 1 ELSE 0 END +
			CASE WHEN [Contract] = 'Month-to-Month' THEN 1 ELSE 0 END +
			CASE WHEN [Premium Tech Support] = 'No' THEN 1 ELSE 0 END)
			>= 3 THEN 'High Risk'
		WHEN(
			CASE WHEN [Offer] = 'None' THEN 1 ELSE 0 END +
			CASE WHEN [Internet Type] = 'Fiber Optic' THEN 1 ELSE 0 END +
			CASE WHEN [Contract] = 'Month-to-Month' THEN 1 ELSE 0 END +
			CASE WHEN [Premium Tech Support] = 'No' THEN 1 ELSE 0 END)
			= 2 THEN 'Medium Risk'
			ELSE 'Low Risk'
			END AS "Risk Level"
FROM [dbo].[telecom_customer_churn]
