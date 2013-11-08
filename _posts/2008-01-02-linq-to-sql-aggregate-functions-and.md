---
title: LINQ to SQL&#58; Aggregate Functions and more
layout: post
permalink: /2008/01/linq-to-sql-aggregate-functions-and.html
tags: linqtosql dotnet
guid: tag:blogger.com,1999:blog-25631453.post-2021649708940189750
tidied: true
---

In this post I am going to cover off how functions such as `Count()`, `Average()` and `Sum()` work, plus the different ways to call them. Then I will move onto some functions that are not from the domain of SQL but add great features.

#### Count()  
The `Count()` function is used to count the number of rows in a table or returned from a query. `Count()` can optionally take a single [Lambda Expression]({% post_url 2007-12-31-linq-to-sql-lambda-expressions %}) as a parameter that will evaluate to a bool and indicate whether to count each record.
Here are three examples.

```csharp
AdventureWorksDataContext db = new AdventureWorksDataContext();
db.Log = Console.Out;

// Count all records in a table
Console.WriteLine(db.SalesOrderHeaders.Count());

// Count all records in a table that match a condition
Console.WriteLine(db.SalesOrderHeaders.Count(s => s.OrderDate.Year == 2002));

// Count the results from a query
var query = from sales in db.SalesOrderHeaders
            where sales.OrderDate.Year == 2002
            select sales;
Console.WriteLine(query.Count());
```


#### Sum() and Average()
The `Sum()` and `Average()` functions are as simple to use as `Count()`. Both take a [Lambda Expression]({% post_url 2007-12-31-linq-to-sql-lambda-expressions %}) that evaluates into one of the numeric types (`int`, `decimal`, `long`...), this expression is calculated for each record. Note that `Min()` and `Max()` work in the same way also.  
Here are some examples using the in-line syntax.

```csharp
AdventureWorksDataContext db = new AdventureWorksDataContext();
db.Log = Console.Out;

// Sum SubTotal + Freight for all rows
Console.WriteLine(db.SalesOrderHeaders.Sum(s => s.SubTotal + s.Freight));
// Sum SubTotal + Freight for all orders from 2002
Console.WriteLine(db.SalesOrderHeaders.Where(s => s.OrderDate.Year == 2002).Sum(s => s.SubTotal + s.Freight));
// Average SubTotal + Freight for all rows
Console.WriteLine(db.SalesOrderHeaders.Average(s => s.SubTotal + s.Freight));
// Average SubTotal + Freight for all orders from 2002
Console.WriteLine(db.SalesOrderHeaders.Where(s => s.OrderDate.Year == 2002).Average(s => s.SubTotal + s.Freight));
```

It is important to note the SQL code that is generated from these queries

```sql
SELECT SUM([t0].[SubTotal] + [t0].[Freight]) AS [value]
FROM [Sales].[SalesOrderHeader] AS [t0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

'AdventureWorks.vshost.exe' (Managed): Loaded 'Anonymously Hosted DynamicMethods Assembly'
130520610.3644
SELECT SUM([t0].[SubTotal] + [t0].[Freight]) AS [value]
FROM [Sales].[SalesOrderHeader] AS [t0]
WHERE DATEPART(Year, [t0].[OrderDate]) = @p0
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [2002]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

36988590.6876
SELECT AVG([t0].[SubTotal] + [t0].[Freight]) AS [value]
FROM [Sales].[SalesOrderHeader] AS [t0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

4148.1204
SELECT AVG([t0].[SubTotal] + [t0].[Freight]) AS [value]
FROM [Sales].[SalesOrderHeader] AS [t0]
WHERE DATEPART(Year, [t0].[OrderDate]) = @p0
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [2002]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

10018.5781
```


LINQ-to-SQL ensures the processing is done on the SQL Server not on the client and keeps your performance up to scratch. Even in the case where I apply a filter it puts all my requests together and keeps the SQL statement clean.


#### All() and Any()
LINQ adds two functions that you may not be too used to using from a pure SQL perspective. `All()` and `Any()` both take a [Lambda Expression]({% post_url 2007-12-31-linq-to-sql-lambda-expressions %}) that evaluates to a `bool` and returns a `bool` based whether all or any of the records meet the expression. This is shown here with the resulting SQL code.

```csharp
// See if all the orders have a SubTotal > 0            
Console.WriteLine(db.SalesOrderHeaders.All(s => s.SubTotal > 0));

// See if any of the order have an order date of today
Console.WriteLine(db.SalesOrderHeaders.Any(s=> s.OrderDate == DateTime.Now));
```

```sql
SELECT 
    (CASE 
        WHEN NOT (EXISTS(
            SELECT NULL AS [EMPTY]
            FROM [Sales].[SalesOrderHeader] AS [t1]
            WHERE (
                (CASE 
                    WHEN [t1].[SubTotal] > @p0 THEN 1
                    ELSE 0
                 END)) = 0
            )) THEN 1
        WHEN NOT NOT (EXISTS(
            SELECT NULL AS [EMPTY]
            FROM [Sales].[SalesOrderHeader] AS [t1]
            WHERE (
                (CASE 
                    WHEN [t1].[SubTotal] > @p0 THEN 1
                    ELSE 0
                 END)) = 0
            )) THEN 0
        ELSE NULL
     END) AS [value]
-- @p0: Input Decimal (Size = 0; Prec = 33; Scale = 4) [0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

True
SELECT 
    (CASE 
        WHEN EXISTS(
            SELECT NULL AS [EMPTY]
            FROM [Sales].[SalesOrderHeader] AS [t0]
            WHERE [t0].[OrderDate] = @p0
            ) THEN 1
        ELSE 0
     END) AS [value]
-- @p0: Input DateTime (Size = 0; Prec = 0; Scale = 0) [2/01/2008 2:55:40 PM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

False
```


#### Skip() and Take()
The last two functions I will show are `Skip()` and `Take()`. These functions are most useful for a paging system. Both augment the resulting SQL statement in a way that allows a paging system to pull back just the records that are required. An example of this is given here where we generate 3 pages of 10 records per page from the `SalesOrderHeader` table.

```csharp
AdventureWorksDataContext db = new AdventureWorksDataContext();
db.Log = Console.Out;
int recPerPage = 10;

for (int page = 1; page <= 3; page++)
{
    var recs = db.SalesOrderHeaders.Skip((page - 1) * recPerPage).Take(recPerPage);
    Console.WriteLine("Page " + page.ToString() + ":");
    foreach (var rec in recs)
    {
        Console.Write(rec.SalesOrderID.ToString() + " ");
    }
}
```



```sql
Page 1:
SELECT TOP (10) [t0].[SalesOrderID], [t0].[RevisionNumber], [t0].[OrderDate], [t0].[DueDate], [t0].[ShipDate], [t0].[Status], [t0].[OnlineOrderFlag], [t0].[SalesOrderNumber], [t0].[PurchaseOrderNumber], [t0].[AccountNumber], [t0].[CustomerID], [t0].[ContactID], [t0].[SalesPersonID], [t0].[TerritoryID], [t0].[BillToAddressID], [t0].[ShipToAddressID], [t0].[ShipMethodID], [t0].[CreditCardID], [t0].[CreditCardApprovalCode], [t0].[CurrencyRateID], [t0].[SubTotal], [t0].[TaxAmt], [t0].[Freight], [t0].[TotalDue], [t0].[Comment], [t0].[rowguid], [t0].[ModifiedDate]
FROM [Sales].[SalesOrderHeader] AS [t0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8
43659 43660 43661 43662 43663 43664 43665 43666 43667 43668

Page 2:
SELECT [t1].[SalesOrderID], [t1].[RevisionNumber], [t1].[OrderDate], [t1].[DueDate], [t1].[ShipDate], [t1].[Status], [t1].[OnlineOrderFlag], [t1].[SalesOrderNumber], [t1].[PurchaseOrderNumber], [t1].[AccountNumber], [t1].[CustomerID], [t1].[ContactID], [t1].[SalesPersonID], [t1].[TerritoryID], [t1].[BillToAddressID], [t1].[ShipToAddressID], [t1].[ShipMethodID], [t1].[CreditCardID], [t1].[CreditCardApprovalCode], [t1].[CurrencyRateID], [t1].[SubTotal], [t1].[TaxAmt], [t1].[Freight], [t1].[TotalDue], [t1].[Comment], [t1].[rowguid], [t1].[ModifiedDate]
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY [t0].[SalesOrderID], [t0].[RevisionNumber], [t0].[OrderDate], [t0].[DueDate], [t0].[ShipDate], [t0].[Status], [t0].[OnlineOrderFlag], [t0].[SalesOrderNumber], [t0].[PurchaseOrderNumber], [t0].[AccountNumber], [t0].[CustomerID], [t0].[ContactID], [t0].[SalesPersonID], [t0].[TerritoryID], [t0].[BillToAddressID], [t0].[ShipToAddressID], [t0].[ShipMethodID], [t0].[CreditCardID], [t0].[CreditCardApprovalCode], [t0].[CurrencyRateID], [t0].[SubTotal], [t0].[TaxAmt], [t0].[Freight], [t0].[TotalDue], [t0].[Comment], [t0].[rowguid], [t0].[ModifiedDate]) AS [ROW_NUMBER], [t0].[SalesOrderID], [t0].[RevisionNumber], [t0].[OrderDate], [t0].[DueDate], [t0].[ShipDate], [t0].[Status], [t0].[OnlineOrderFlag], [t0].[SalesOrderNumber], [t0].[PurchaseOrderNumber], [t0].[AccountNumber], [t0].[CustomerID], [t0].[ContactID], [t0].[SalesPersonID], [t0].[TerritoryID], [t0].[BillToAddressID], [t0].[ShipToAddressID], [t0].[ShipMethodID], [t0].[CreditCardID], [t0].[CreditCardApprovalCode], [t0].[CurrencyRateID], [t0].[SubTotal], [t0].[TaxAmt], [t0].[Freight], [t0].[TotalDue], [t0].[Comment], [t0].[rowguid], [t0].[ModifiedDate]
    FROM [Sales].[SalesOrderHeader] AS [t0]
    ) AS [t1]
WHERE [t1].[ROW_NUMBER] BETWEEN @p0 + 1 AND @p0 + @p1
ORDER BY [t1].[ROW_NUMBER]
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [10]
-- @p1: Input Int (Size = 0; Prec = 0; Scale = 0) [10]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8
43669 43670 43671 43672 43673 43674 43675 43676 43677 43678

Page 3:
SELECT [t1].[SalesOrderID], [t1].[RevisionNumber], [t1].[OrderDate], [t1].[DueDate], [t1].[ShipDate], [t1].[Status], [t1].[OnlineOrderFlag], [t1].[SalesOrderNumber], [t1].[PurchaseOrderNumber], [t1].[AccountNumber], [t1].[CustomerID], [t1].[ContactID], [t1].[SalesPersonID], [t1].[TerritoryID], [t1].[BillToAddressID], [t1].[ShipToAddressID], [t1].[ShipMethodID], [t1].[CreditCardID], [t1].[CreditCardApprovalCode], [t1].[CurrencyRateID], [t1].[SubTotal], [t1].[TaxAmt], [t1].[Freight], [t1].[TotalDue], [t1].[Comment], [t1].[rowguid], [t1].[ModifiedDate]
FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY [t0].[SalesOrderID], [t0].[RevisionNumber], [t0].[OrderDate], [t0].[DueDate], [t0].[ShipDate], [t0].[Status], [t0].[OnlineOrderFlag], [t0].[SalesOrderNumber], [t0].[PurchaseOrderNumber], [t0].[AccountNumber], [t0].[CustomerID], [t0].[ContactID], [t0].[SalesPersonID], [t0].[TerritoryID], [t0].[BillToAddressID], [t0].[ShipToAddressID], [t0].[ShipMethodID], [t0].[CreditCardID], [t0].[CreditCardApprovalCode], [t0].[CurrencyRateID], [t0].[SubTotal], [t0].[TaxAmt], [t0].[Freight], [t0].[TotalDue], [t0].[Comment], [t0].[rowguid], [t0].[ModifiedDate]) AS [ROW_NUMBER], [t0].[SalesOrderID], [t0].[RevisionNumber], [t0].[OrderDate], [t0].[DueDate], [t0].[ShipDate], [t0].[Status], [t0].[OnlineOrderFlag], [t0].[SalesOrderNumber], [t0].[PurchaseOrderNumber], [t0].[AccountNumber], [t0].[CustomerID], [t0].[ContactID], [t0].[SalesPersonID], [t0].[TerritoryID], [t0].[BillToAddressID], [t0].[ShipToAddressID], [t0].[ShipMethodID], [t0].[CreditCardID], [t0].[CreditCardApprovalCode], [t0].[CurrencyRateID], [t0].[SubTotal], [t0].[TaxAmt], [t0].[Freight], [t0].[TotalDue], [t0].[Comment], [t0].[rowguid], [t0].[ModifiedDate]
    FROM [Sales].[SalesOrderHeader] AS [t0]
    ) AS [t1]
WHERE [t1].[ROW_NUMBER] BETWEEN @p0 + 1 AND @p0 + @p1
ORDER BY [t1].[ROW_NUMBER]
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [20]
-- @p1: Input Int (Size = 0; Prec = 0; Scale = 0) [10]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8
43679 43680 43681 43682 43683 43684 43685 43686 43687 43688
```


Note the difference in form between the Page 1 SQL statement which does a `Skip(0)` and hence just uses `TOP` to achieve the `Take(10)` compared with Page 2 and 3 that need to get a little more complicated. There are two companion functions `SkipWhile()` and `TakeWhile()` that allow you to apply a `bool` condition mix as well.

Having such simple-to-use functions abstract away the complexity of the SQL underneath provides a real boost to developer productivity.  
Keep in mind that all the above functions are part of LINQ, not special to LINQ-to-SQL and as such will work with all LINQ data sources. Very Nice!
