/**
9. Buatlah procedure Invoice untuk memanggil CustomerID, 
CustomerName/company name, 
OrderID, OrderDate, RequiredDate, ShippedDate jika terdapat inputan CustomerID tertentu.
**/

CREATE PROCEDURE dbo.GetInvoice
    @CustomerID nchar(5)   
AS  
SELECT c.CustomerID, c.CompanyName,
o.OrderID, o.OrderDate, 
o.RequiredDate, o.ShippedDate
FROM dbo.Orders as o
JOIN dbo.Customers as c
	ON o.CustomerID = c.CustomerID
WHERE c.CustomerID = @CustomerID

EXECUTE dbo.GetInvoice N'ANTON';  -- Check the Procedure
