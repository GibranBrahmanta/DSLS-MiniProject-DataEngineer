WITH order_data AS (
	SELECT o.OrderID,
	YEAR(OrderDate) as year,
	MONTH(OrderDate) as month,
	DAY(OrderDate) as day,
	od.ProductID,
	p.ProductName,
	c.CategoryName,
	od.UnitPrice as order_price,
	p.UnitPrice as product_price,
	(p.UnitPrice - od.UnitPrice) as price_gap,
	od.Quantity,
	od.Discount,
	(od.UnitPrice * od.Quantity) as gross_sales,
	((od.UnitPrice - od.Discount) * od.Quantity) as nett_sales
	FROM dbo.Orders as o
	JOIN dbo.[Order Details] as od
		ON o.OrderID = od.OrderID
	JOIN dbo.Products as p 
		ON od.ProductID = p.ProductID
	JOIN dbo.Categories as c
		ON p.CategoryID = c.CategoryID
), grouped_data AS (
	SELECT year, month, ProductID, ProductName, CategoryName,
	COUNT(*) as transaction_count,
	ROUND(AVG(product_price), 2) as avg_product_price,
	ROUND(AVG(order_price), 2) as avg_order_price,
	ROUND(AVG(price_gap), 2) as avg_price_gap,
	ROUND(SUM(gross_sales), 2) as total_gross,
	ROUND(SUM(nett_sales),2) as total_nett, 
	ROUND(AVG(gross_sales), 2) as avg_total_gross,
	ROUND(AVG(nett_sales), 2) as avg_total_nett 
	FROM order_data
	GROUP BY year, month, ProductID, ProductName, CategoryName
)
SELECT * INTO ProductAnalyticsData FROM grouped_data;

SELECT * FROM ProductAnalyticsData;