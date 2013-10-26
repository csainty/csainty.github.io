---
title: LINQ to SQL&#58; Lambda Expressions
layout: post
permalink: /2007/12/linq-to-sql-lambda-expressions.html
tags: linqtosql dotnet
---

At first glance, Lambda Expressions are bound to confuse most people. Myself included. However, a little digging and experimenting will show they are a simple enough concept. I will cover them now to try remove any confusion in later code snippets.
Lets have a look at one of the overloads for the Where() method.    Note: All clauses in a LINQ expression can also be expressed as methods. They behave identically and are interchangeable, even within a LINQ expression!
![Where](http://lh4.google.com/saintyc/R3hbHUxWVmI/AAAAAAAAADY/_dhELuS43XU/Where%5B2%5D) 
You will see the parameter "predicate" is of type Func<SaleOrderHeader,bool>    What this means is that you pass the Where() method an anonymous function that takes a SaleOrderHeader object (representing a row from the table) and returns a bool that indicates is this row is to be included in the results.
The old (cumbersome) way of specifying this function was as follows

`AdventureWorksDataContext db = new AdventureWorksDataContext();
Func<SalesOrderHeader, bool> f = delegate(SalesOrderHeader s){return s.OnlineOrderFlag;};
db.SalesOrderHeaders.Where(f);`


What Lambda Expressions provide is an inline succinct way of achieving exactly the same result.

`AdventureWorksDataContext db = new AdventureWorksDataContext();
Func<SalesOrderHeader, bool> f = s => s.OnlineOrderFlag;
db.SalesOrderHeaders.Where(f);
// or //
db.SalesOrderHeaders.Where(s => s.OnlineOrderFlag);`


Reading a Lambda Expression is simple enough, the expression is separated into two parts either side of the "=>" operator. The left hand side defines the parameters, the types of which are usually implied. The right hand side is an expression that uses these parameters and evaluates to the defined return type. The whole expression is type checked, so intellisense will help you out, and the compiler will flag any problems.
Lambda Expressions are not unique to LINQ, they can be used anywhere you might already use an anonymous method. What they provide LINQ however is a far more readable syntax.
One last note, because LINQ uses delegates it gives you an opportunity to build logic into your queries that is quite useful and readable.

`AdventureWorksDataContext db = new AdventureWorksDataContext();
Func<SalesOrderHeader, bool> f;
bool b = true;
if (b)
    f = s => s.OrderDate == DateTime.Now;
else
    f = s => s.OrderDate < DateTime.Now;

var q = db.SalesOrderHeaders.Where(f);`


As this code snippet shows, applying different filters based on a condition is now a fairly simple task. The variable "q" of type IEnumerable<SalesOrderHeader> will contain all the orders either from today, or before today, depending on the value of b. 


I will be using this technique more often in future posts, and it is an important concept to understand, otherwise your queries are going to be difficult to piece together.