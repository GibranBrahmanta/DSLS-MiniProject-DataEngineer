WITH product_data AS (
	SELECT p.ProductID,
	p.ProductName, c.CategoryName,
	s.CompanyName, p.Discontinued,
	p.UnitsInStock, (p.UnitsInStock + p.UnitsOnOrder) as future_unit,
	p.ReorderLevel, (p.UnitsInStock - p.ReorderLevel) as now_gap,
	((p.UnitsInStock + p.UnitsOnOrder) - p.ReorderLevel) as future_gap
	FROM dbo.Products as p
	JOIN dbo.Categories as c
		ON p.CategoryID = c.CategoryID
	JOIN dbo.Suppliers as s
		ON p.SupplierID = s.SupplierID
), order_data AS (
	SELECT ProductID, COUNT(DISTINCT OrderID) as order_count,
	ROUND(SUM((UnitPrice - Discount) * Quantity), 2) as total_gross_income
	FROM dbo.[Order Details]
	GROUP BY ProductID
), used_order_data AS (
	SELECT OrderID, OrderDate
	FROM dbo.Orders
	WHERE DATEDIFF(month, OrderDate, (
		SELECT MAX(OrderDate) FROM dbo.Orders)) <= 1
), one_month_demand AS (
	SELECT ProductID, SUM(Quantity) as total_demand, 
	COUNT(DISTINCT OrderID) as total_order
	FROM dbo.[Order Details]
	WHERE OrderID IN (
		SELECT OrderID FROM used_order_data
	)
	GROUP BY ProductID
), final_data AS (
	SELECT p.ProductID, p.ProductName, p.CategoryName,
	p.CompanyName, p.Discontinued, p.ReorderLevel,
	p.UnitsInStock, p.now_gap, 
	p.future_unit, p.future_gap,
	COALESCE(o.order_count, 0) as order_count,
	COALESCE(o.total_gross_income, 0) as total_gross_income,
	COALESCE(om.total_demand, 0) as prev_month_demand,
	COALESCE(om.total_order, 0) as prev_month_order
	FROM product_data as p
	LEFT JOIN order_data as o
		ON p.ProductID = o.ProductID
	LEFT JOIN one_month_demand as om
		ON p.ProductID = om.ProductID
)
SELECT * INTO SupplierAnalysisData FROM final_data;

SELECT * FROM SupplierAnalysisData;

