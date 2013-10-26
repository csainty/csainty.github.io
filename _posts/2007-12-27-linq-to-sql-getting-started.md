---
title: LINQ to SQL&#58; Getting Started
layout: post
permalink: /2007/12/linq-to-sql-getting-started.html
tags: linqtosql dotnet
---

I am going to start by showing a few new language features that are important to LINQ (and hence LINQ-to-SQL) that you may not have come across yet if you are not already playing around with this stuff.
A great place to start is to bring up intellisense and have a look at the structure of the classes that have been created for you.
![Intellisense](http://lh5.google.com/saintyc/R3L_hExWVeI/AAAAAAAAACI/YKhJVjyRvOA/Intellisense4) 
Each table in the database is given a property on the Data Context object. The type of this property (using Addresses as the example) will be System.Data.Linq.Table<Address>. This class implements the IEnumerable<> and IQueryable<> interfaces that provides the underlying LINQ functionality.
![IEnumerable](http://lh5.google.com/saintyc/R3L_iExWVgI/AAAAAAAAACY/0tb0DzrtoYE/IEnumerable%5B1%5D) 
You will note a Count() method here, as well as a number of other interesting functions such as Average(), Contains() and DeleteAllOnSubmit(). We will take a look at a number of these later. First however I want to talk about what the <> symbols that are being scattered around.    When we define a class, for example List, as List<MyCustomClass> it tells the compiler that this List instance should substitute MyCustomClass for object in its definition. The actual definition of the List class decides where and how the Type is used, but we will not go into that detail here. What this means is that you can have a List whose methods will take/return the objects of type MyCustomClass without messing around with casting to/from object or creating a custom sub-class.     This technique is used heavily in LINQ-to-SQL to provide strong compile time type checking.     What this means for you in practice is that if you try to add an Order record to the Address table, it will pick this mistake up at compile-time, not with a run-time error.
Now lets put a few things together and add a record to one of the tables.

`private void button1_Click(object sender, RoutedEventArgs e)
{
    var db = new AdventureWorksDataContext();
    System.Windows.MessageBox.Show(db.AddressTypes.Count().ToString()); // 6
    var x = new AddressType()
    {
        Name= "New Address Type",
        ModifiedDate= DateTime.Now
    };
    db.AddressTypes.InsertOnSubmit(x);    // Queues up an insert
    db.SubmitChanges();    // Submits all the changes in a single transaction
    System.Windows.MessageBox.Show(db.AddressTypes.Count().ToString()); // 7
}`


The first question, some may ask, is what is that "var" keyword. Well rest easy, C# has not introduced some new variant type, var tells the compiler to look at the assignment expression and determine the type to assign to the new variable. 
  var x = new AddressType() is absolutely identical to AddressType x = new AddressType(), its just cleaner to read and easier to write. It has one other use, that we will see later. 

  Also of interest is the way I have set the property values for my new AddressType record. Again this is just a cleaner way of setting up a class and assigning properties to it. 

  You gain no benefit from using either of these new tricks other than cleaner (in my opinion) code. 
Let's now put together something a little more complex (and contrived) 
  

`private void button1_Click(object sender, RoutedEventArgs e)
{
    var db = new AdventureWorksDataContext();
    db.Log = Console.Out;
    var query = from c in db.Customers
                where c.CustomerAddresses.Count(a => a.Address.City == "Seattle") > 0
                select new 
                { 
                    AccountNumber= c.AccountNumber,
                    SaleValue = c.SalesOrderHeaders.Sum(o => o.SubTotal)
                };
    foreach (var customer in query)
    {
        Console.WriteLine(customer.AccountNumber + " - " + customer.SaleValue.ToString());
    }
}`


First things first, by hooking up db.Log to Console.Out, we can see the SQL statements that are being executed. You can just as easily hook this up to output to a file. 
  What this statement does is find customers with an address in Seattle, and sum up their orders. There are two new features here that need to be discussed. 

  First we have the Lambda Expression a => a.City == "Seattle". Lambda Expressions basically offer and in-line delegate method. In the case of the Count() method, you can pass it an expression that will take one parameter (in this case "a") of type "CustomerAddress" (CustomerAddresses is an IEnumerable<CustomerAddress>) and return a boolean value to indicate whether this element in the collection should be counted. Because intellisense knows the type of "a" from the definition of the class, it gives you full support. Exactly how a.Address works, we will see later, suffice to say there is no Address field in the CustomerAdress table, but there is a relationship from CustomerAddress to Address defined in the database schema. 

  Second we have the select new {} piece of code, you will note this uses a similar constructor to what I used above when creating my AddressType object, in this case we are actually creating an in-line type definition. Our type will have two properties, that we use in the foreach loop below, and comes with full intellisense support!! 

  This is where the "var" keyword really comes into play, because we are defining an Anonymous Type, we do not actually have a type we can provide up-front when declaring our object, but the compiler can use the expression to determine the type and provide us with intellisense and type checking.
Another point worth noting is that the LINQ syntax is just a wrapper for the underlying IEnumerable/IQueryable methods and that statements can be written using either.

`var query = db.Customers.Where(c => c.CustomerAddresses.Count(a => a.Address.City == "Seattle") > 0).Select(c => new { AccountNumber = c.AccountNumber, SaleValue = c.SalesOrderHeaders.Sum(o => o.SubTotal) });`


Last of all, lets see the output generated. I hope you will agree they have done a fantastic job converting a rather obtuse query like the one above into solid SQL.

`SELECT [t0].[AccountNumber], (
    SELECT SUM([t3].[SubTotal])
    FROM [Sales].[SalesOrderHeader] AS [t3]
    WHERE [t3].[CustomerID] = [t0].[CustomerID]
    ) AS [SaleValue]
FROM [Sales].[Customer] AS [t0]
WHERE ((
    SELECT COUNT(*)
    FROM [Sales].[CustomerAddress] AS [t1]
    INNER JOIN [Person].[Address] AS [t2] ON [t2].[AddressID] = [t1].[AddressID]
    WHERE ([t2].[City] = @p0) AND ([t1].[CustomerID] = [t0].[CustomerID])
    )) > @p1
-- @p0: Input NVarChar (Size = 7; Prec = 0; Scale = 0) [Seattle]
-- @p1: Input Int (Size = 0; Prec = 0; Scale = 0) [0]

AW00000001 - 102351.7966
AW00000146 - 872520.1608
AW00000236 - 649987.2813
AW00000397 - 178854.5230
.
.
.`


That will cover us for this article. Next I am going to take a step back from the code and talk a little about the mind set you should be using with LINQ-to-SQL and hopefully help you understand just why I am so excited by it.