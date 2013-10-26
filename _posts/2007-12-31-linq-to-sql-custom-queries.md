---
title: LINQ to SQL&#58; Custom Queries
layout: post
permalink: /2007/12/linq-to-sql-custom-queries.html
tags: linqtosql dotnet
---

Now I have some of the foundations out of the way, albeit in a rather brief overview that assumes a reasonable level of competency, it is time to move onto some of the more interesting code snippets.
One thing I never liked much about writing SQL in either FoxPro or with PassThrough technologies is how you piece together a complex query from a number of UI selections. The most common occurrence of this is in reporting. The number of ways you can usually slice and dice a sales report makes for some fairly nasty code to build a string based SQL statement. LINQ-to-SQL offers us a new paradigm for dealing with this sort of problem.    First we need to add a few options to our UI in Window1.xaml

`<Window x:Class="AdventureWorks.Window1"
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Window1" Height="233" Width="534">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="255*" />
            <ColumnDefinition Width="257*" />
        </Grid.ColumnDefinitions>
        <StackPanel Grid.Column="0">
            <CheckBox Name="chkOnline">Online Orders Only</CheckBox>
            <StackPanel Orientation="Horizontal">
                <Label Width="50">From</Label>
                <TextBox Width="200" Name="dateFrom">01/01/2001</TextBox>
            </StackPanel>
            <StackPanel Orientation="Horizontal">
                <Label Width="50">To</Label>
                <TextBox Width="200" Name="dateTo">31/12/2001</TextBox>
            </StackPanel>
            <StackPanel Orientation="Horizontal">
                <Label Width="50">City</Label>
                <TextBox Name="city" Width="200"></TextBox>
            </StackPanel>
        </StackPanel>
        <Button Name="button1" Click="button1_Click" Grid.Column="1">Button</Button>
    </Grid>
</Window>`


Then we replace the click event with the following code.

`private void button1_Click(object sender, RoutedEventArgs e)
{
    AdventureWorksDataContext db = new AdventureWorksDataContext();
    db.Log = Console.Out;
    DateTime dFrom;
    DateTime dTo;
    var query = db.SalesOrderHeaders.AsQueryable();

    if ((bool)chkOnline.IsChecked)
        query = query.Where(s => s.OnlineOrderFlag == true);
    if (DateTime.TryParse(dateFrom.Text, out dFrom))
        query = query.Where(s => s.OrderDate >= dFrom);
    if (DateTime.TryParse(dateTo.Text, out dTo))
        query = query.Where(s => s.OrderDate <= dTo);
    if (city.Text.Length > 0)
        query = query.Where(s => s.ShipToAddress.City == city.Text);

    var results = from sale in query
                  select new
                  {
                      OrderID = sale.SalesOrderNumber,
                      OrderValue = sale.SubTotal + sale.Freight,
                      City = sale.ShipToAddress.City
                  };
    if (results.Count() >= 1)
    {
        var rec = results.First();
        Console.WriteLine(rec.OrderID + " - " + rec.City + " - $" + rec.OrderValue);
    }
}`


Note: This code snippet assumes you have made the changes to your data model as discussed [here](http://csainty.blogspot.com/2007/12/linq-to-sql-customisation.html).
If we set this up, check the Online Order box and enter the city Seattle we get the following SQL generated. Note that because I only access the first record, LINQ-to-SQL executes a TOP 1. I hope you will agree this is pretty neat.

`SELECT TOP (1) [t2].[SalesOrderNumber] AS [OrderID], [t2].[value] AS [OrderValue], [t2].[City]
FROM (
    SELECT [t0].[SalesOrderNumber], [t0].[SubTotal] + [t0].[Freight] AS [value], [t1].[City], [t0].[OrderDate], [t0].[OnlineOrderFlag]
    FROM [Sales].[SalesOrderHeader] AS [t0]
    INNER JOIN [Person].[Address] AS [t1] ON [t1].[AddressID] = [t0].[ShipToAddressID]
    ) AS [t2]
WHERE ([t2].[City] = @p0) AND ([t2].[OrderDate] <= @p1) AND ([t2].[OrderDate] >= @p2) AND ([t2].[OnlineOrderFlag] = 1)
-- @p0: Input NVarChar (Size = 7; Prec = 0; Scale = 0) [Seattle]
-- @p1: Input DateTime (Size = 0; Prec = 0; Scale = 0) [31/12/2001 12:00:00 AM]
-- @p2: Input DateTime (Size = 0; Prec = 0; Scale = 0) [1/01/2001 12:00:00 AM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

SO43768 - Seattle - $3667.7268`


Now a few cool things to note. First, I did not specify the join. LINQ-to-SQL has seen my usage of the SalesOrderHeader.ShipToAddress.City field, and knows that to access that field it needs to JOIN to the address table using the ShipToAddressID field, because of this had I not used the field due to some set up of the conditions, no join would have been made. Very nice, especially if we are dealing with numerous tables that only become relevant if the user makes a certain selection.
The extension of a code snippet like this is to have multiple "query" variables. These should be viewed more so as filters, so I could have an order filter, customer filter, product filter. Each filter could be optionally whittled down with Where() statements and then the final LINQ query could express the general relationship between each filter and the projection (select) required from it.
There is one very important piece of information that also needs discussing here, the difference between IEnumerable and IQueryable. In the above code snippet, if you use .AsEnumerable() instead of .AsQueryable() although you will see the same result, the performance will be greatly impacted, this is because all of the Where() clauses will be evaluated on the Client instead of passed to the Sever as SQL. You can think of the difference as being immediate or Just-In-Time execution. There is obviously more to it than that and the Help has much to say on the topic. For our purposes however you simply need to be aware that there is a difference and you should watch out for it.