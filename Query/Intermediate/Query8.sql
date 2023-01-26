/**
8. Buatlah view untuk melihat Order Details yang berisi OrderID, ProductID, ProductName, 
UnitPrice, Quantity, Discount, Harga setelah diskon.
**/

CREATE VIEW dbo.OrderDetailsView
AS
SELECT o.OrderID, o.ProductID, p.ProductName,
o.UnitPrice, o.Quantity, 
o.Discount,(o.UnitPrice - o.Discount) as FinalPrice 
FROM dbo.[Order Details] as o
JOIN dbo.Products as p
	ON o.ProductID = p.ProductID

SELECT * FROM dbo.OrderDetailsView -- Check the view