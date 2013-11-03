---
title: LINQ to SQL&#58; GroupBy()
layout: post
permalink: /2008/01/linq-to-sql-groupby.html
tags: linqtosql dotnet
id: tag:blogger.com,1999:blog-25631453.post-1482896506005821729
tidied: true
---

One aspect of LINQ I have not covered yet is the equivalent of a `GROUP BY` in SQL. The `GroupBy()` function (which of course can be used from a LINQ expression as well as from the method syntax and I will show both) provides this functionality. One of the interesting things about grouping however is that there is a new interface introduced that you will want to understand, lets take a look at the method signature for `GroupBy()`.

![GroupBy()](/images/1382874053408.png) 

The function takes a single [Lambda Expression]({% post_url 2007-12-31-linq-to-sql-lambda-expressions %}) which returns the value to group by, this can be any basic data type and will flow through to the returned object.
The return type is a little complicated `IQueryable<IGrouping<TKey, Address>>` what this means is you will have an `IQueryable` collection of `IGrouping` objects.  
An `IGrouping` object is a collection of data records (in this case of type `Address`) with a special property added `Key`, which holds the grouped value that associated all of the records in that collection together.  Confused? Lets take a look at an example. I will start by using the `GroupBy()` function as I find it easier to read than LINQ Expressions.

```csharp
AdventureWorksDataContext db = new AdventureWorksDataContext();
db.Log = Console.Out;

var g = db.Addresses.GroupBy(a => a.PostalCode);
foreach (var pc in g)
{
    Console.WriteLine(pc.Key + " - " + pc.Count().ToString());
}
```

Now this is a terribly inefficient way to access this data, but it shows you the general structure of the the result of a `GroupBy()`.  
As you can see we are returned a Collection (of Groups) which we can iterate through, each element in that Collection is also a Collection (of Records) which we can perform standard LINQ functions on, so we can actually write something like `pc.Where(a => a.City == "Seattle")`.  
How does this work in a more traditional (and SQL efficient) manner? Well the best way is to drop it into a LINQ Expression. Here we get a list of Postal Codes, a `Count()` of all the orders shipped to that code and a `Sum()` of the value of these orders.  
You will need to make the changes I discussed [here]({% post_url 2007-12-31-linq-to-sql-customisation %}) to your DataContext before this example will work.

```csharp
AdventureWorksDataContext db = new AdventureWorksDataContext();
db.Log = Console.Out;

var pcs = from a in db.Addresses
          group a by a.PostalCode into g
          select new { 
              PostalCode = g.Key, 
              Orders = (int?)g.Sum(addr => addr.SalesOrderHeaders_ShipTo.Count) ?? 0, 
              OrderValue = (decimal?)g.Sum(addr => addr.SalesOrderHeaders_ShipTo.Sum(o => o.SubTotal + o.Freight)) ?? 0m 
          };
foreach (var pc in pcs) {
    Console.WriteLine(pc.PostalCode + " - " + pc.Orders.ToString() +  " orders - $" + pc.OrderValue.ToString());
}
```



```sql
SELECT [t5].[PostalCode], COALESCE([t5].[value],@p0) AS [Orders], COALESCE([t5].[value2],@p1) AS [OrderValue]
FROM (
    SELECT SUM([t4].[value2]) AS [value], SUM([t4].[value]) AS [value2], [t4].[PostalCode]
    FROM (
        SELECT (
            SELECT SUM([t3].[SubTotal] + [t3].[Freight])
            FROM [Sales].[SalesOrderHeader] AS [t3]
            WHERE [t3].[ShipToAddressID] = [t2].[AddressID]
            ) AS [value], [t2].[PostalCode], [t2].[value] AS [value2]
        FROM (
            SELECT (
                SELECT COUNT(*)
                FROM [Sales].[SalesOrderHeader] AS [t1]
                WHERE [t1].[ShipToAddressID] = [t0].[AddressID]
                ) AS [value], [t0].[AddressID], [t0].[PostalCode]
            FROM [Person].[Address] AS [t0]
            ) AS [t2]
        ) AS [t4]
    GROUP BY [t4].[PostalCode]
    ) AS [t5]
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [0]
'AdventureWorks.vshost.exe' (Managed): Loaded 'Anonymously Hosted DynamicMethods Assembly'
-- @p1: Input Decimal (Size = 0; Prec = 33; Scale = 4) [0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

RG41 1QW - 53 orders - $68570.0109
53131 - 52 orders - $34293.5160
80074 - 132 orders - $365231.6172
31770 - 46 orders - $564563.9205
78100 - 69 orders - $78081.7795
SL4 1RH - 56 orders - $222467.7091
92173 - 4 orders - $173634.3922
...
```

Note how the `Null` values are handled both in the LINQ Expression and the resulting SQL. You may not have seen the `??` operator before, it checks if the left hand side is null, if it is then it returns the right hand side, otherwise it returns the left hand side.  
This example is a little convoluted thanks to the way Addresses are joined to Orders `(Sum(Count())` and `Sum(Sum()))`, but I think it serves a good example of just how good LINQ-to-SQL is at building SQL from your LINQ Expression.  
You will always be using anonymous types when playing around with `GroupBy()` so its a good idea to have a feel for how they work. `var` will soon be your new best friend. Have a look [here]({% post_url 2007-12-27-linq-to-sql-getting-started %}) if you have missed them.
