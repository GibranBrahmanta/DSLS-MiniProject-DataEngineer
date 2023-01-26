WITH date_data AS (
	SELECT MAX(OrderDate) as lastest_date,
	MIN(OrderDate) as earliest_date,
	DATEDIFF(day, MIN(OrderDate), MAX(OrderDate)) as gap
	FROM dbo.Orders
), customer_data AS (
	SELECT CustomerID,
	City, Region, Country
	FROM dbo.Customers
), lastest_order AS (
	SELECT CustomerID, MAX(OrderDate) as last_order
	FROM dbo.Orders
	GROUP BY CustomerID
), recency_data AS (
	SELECT CustomerID, 
	DATEDIFF(day, last_order, (SELECT lastest_date FROM date_data)) as recency
	FROM lastest_order
), frequency_data AS (
	SELECT CustomerID, COUNT(OrderID) as frequency
	FROM dbo.Orders
	GROUP BY CustomerID
), grouped_od AS (
	SELECT OrderID,
	ROUND(SUM((UnitPrice - Discount) * Quantity), 2) as total_sales
	FROM dbo.[Order Details]
	GROUP BY OrderID
), monetary_data AS (
	SELECT o.CustomerID,
	SUM(gd.total_sales) as monetary 
	FROM dbo.Orders as o
	JOIN grouped_od as gd
		ON o.OrderID = gd.OrderID
	GROUP BY o.CustomerID
), rfm_data AS (
	SELECT c.CustomerID, c.City, c.Region, c.Country,
	COALESCE(r.recency, (SELECT gap FROM date_data)) as recency,
	COALESCE(f.frequency, 0) as frequency,
	COALESCE(m.monetary, 0) as monetary
	FROM customer_data as c
	LEFT JOIN recency_data as r
		ON c.CustomerID = r.CustomerID
	LEFT JOIN frequency_data as f
		ON r.CustomerID = f.CustomerID
	LEFT JOIN monetary_data as m
		ON f.CustomerID = m.CustomerID
)
SELECT * INTO CustomerAnalyticsData FROM rfm_data;

SELECT * FROM CustomerAnalyticsData;