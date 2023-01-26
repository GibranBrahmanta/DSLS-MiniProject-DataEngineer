/**
1. Tulis query untuk mendapatkan jumlah customer tiap bulan yang melakukan order pada tahun 1997.
**/

WITH used_data AS (
	SELECT CustomerID, MONTH(OrderDate) as MonthOrder
	FROM dbo.Orders
	WHERE YEAR(OrderDate) = 1997
)
SELECT MonthOrder, COUNT(DISTINCT CustomerID) as CostumerCount
FROM used_data
GROUP BY MonthOrder
ORDER BY MonthOrder;

/**
2. Tulis query untuk mendapatkan nama employee yang termasuk Sales Representative.
**/

SELECT CONCAT(FirstName, ' ', LastName) as EmployeeName
FROM dbo.Employees
WHERE Title = 'Sales Representative';

/**
3. Tulis query untuk mendapatkan top 5 nama produk yang quantitynya paling banyak diorder pada bulan Januari 1997.
**/

WITH january_order AS (
	SELECT *
	FROM dbo.Orders 
	WHERE MONTH(OrderDate) = 1 AND YEAR(OrderDate) = 1997
), order_detail AS (
	SELECT o.OrderID, od.ProductID
	FROM dbo.Orders as o
	JOIN dbo.[Order Details] as od
		ON o.OrderID = od.OrderID
), top_5_order AS (
	SELECT ProductID, COUNT(*) as OrderCount
	FROM order_detail
	GROUP BY ProductID
	ORDER BY OrderCount DESC
	OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY
), product_detail AS (
	SELECT p.ProductName
	FROM top_5_order as t5
	JOIN dbo.Products as p
		ON t5.ProductID = p.ProductID
)
SELECT * FROM product_detail;

/**
4. Tulis query untuk mendapatkan nama company yang melakukan order Chai pada bulan Juni 1997.
**/

WITH chai_data AS (
	SELECT ProductID
	FROM dbo.Products
	WHERE ProductName = 'Chai'
), filtered_order_detail AS (
	SELECT * 
	FROM dbo.[Order Details]
	WHERE ProductID = (
		SELECT ProductID FROM chai_data
	)
), filtered_order AS (
	SELECT *
	FROM dbo.Orders
	WHERE MONTH(OrderDate) = 6 AND YEAR(OrderDate) = 1997
), used_order AS (
	SELECT o.OrderID, o.CustomerID
	FROM filtered_order as o
	JOIN filtered_order_detail as od
		ON o.OrderID = od.OrderID
), company_detail AS (
	SELECT DISTINCT c.CompanyName
	FROM used_order as uo
	JOIN dbo.Customers as c
		ON uo.CustomerID = c.CustomerID
)
SELECT CompanyName FROM company_detail;

/**
5. Tulis query untuk mendapatkan jumlah OrderID yang pernah melakukan pembelian 
(unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500.
**/

WITH merged_data AS (
	SELECT o.OrderID, SUM(od.UnitPrice * od.Quantity) as sales
	FROM dbo.Orders as o
	JOIN dbo.[Order Details] as od
		ON o.OrderID = od.OrderID
	GROUP BY o.OrderID
), categorized_data AS (
	SELECT OrderID, sales,
	CASE 
		WHEN sales <= 100 THEN '<= 100'
		WHEN 100 < sales AND sales <= 250 THEN '100 < x <= 250'
		WHEN 250 < sales AND sales <= 500 THEN '250 < x <= 500'
		WHEN sales > 500 THEN '> 500'
	END as category
	FROM merged_data
), grouped_data AS (
	SELECT category, COUNT(OrderID) as count
	FROM categorized_data
	GROUP BY category
)
SELECT * FROM grouped_data;

/**
6. Tulis query untuk mendapatkan Company name pada tabel customer yang melakukan pembelian di atas 500 pada tahun 1997.
**/

WITH filtered_order AS (
	SELECT *
	FROM dbo.Orders
	WHERE YEAR(OrderDate) = 1997
), merged_data AS (
	SELECT o.OrderID, o.CustomerID, SUM(od.UnitPrice * od.Quantity) as sales
	FROM filtered_order as o
	JOIN dbo.[Order Details] as od
		ON o.OrderID = od.OrderID
	GROUP BY o.OrderID, o.CustomerID
	HAVING SUM(od.UnitPrice * od.Quantity) > 500
), company_data AS (
	SELECT DISTINCT c.CompanyName
	FROM merged_data as m
	JOIN dbo.Customers as c
		ON m.CustomerID = c.CustomerID
)
SELECT * FROM company_data;

/**
7. Tulis query untuk mendapatkan nama produk yang merupakan Top 5 sales tertinggi tiap bulan di tahun 1997.
**/

WITH used_order AS (
	SELECT *
	FROM dbo.Orders
	WHERE YEAR(OrderDate) = 1997
), order_data AS (
	SELECT o.OrderID, MONTH(o.OrderDate) as month,
	od.ProductID, (od.Quantity * od.UnitPrice) as sales
	FROM used_order as o
	JOIN dbo.[Order Details] as od
		ON o.OrderID = od.OrderID
), grouped_data AS (
	SELECT month, ProductID, SUM(sales) as total_sales
	FROM order_data
	GROUP BY month, ProductID
), ranked_data AS (	
	SELECT *,
	ROW_NUMBER() OVER(PARTITION BY month ORDER BY total_sales DESC) as rank
	FROM grouped_data
), filtered_data AS (
	SELECT month, ProductID, total_sales
	FROM ranked_data
	WHERE rank < 6
), final_data AS (
	SELECT fd.month, fd.ProductID,
	p.ProductName, fd.total_sales
	FROM filtered_data as fd
	JOIN dbo.Products as p
		ON fd.ProductID = p.ProductID
)
SELECT * FROM final_data
ORDER BY month, total_sales DESC
