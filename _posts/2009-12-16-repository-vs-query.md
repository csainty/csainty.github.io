---
title: Repository vs Query
layout: post
permalink: /2009/12/repository-vs-query.html
tags: C# dotnet
---


I’ve read a lot of blog posts about the Repository pattern. Whenever I have looked at implementing it, I always come away underwhelmed. It’s one of those things that displays nicely in a small example but in practice you end up with a huge number of methods that each query the data in a similar but slightly different manner, and for me it’s fault is with querying.    GetCustomersByFirstName();     GetCustomersByFirstAndLastName(); GetCustomersByFirstAndLastAndThreeOfTheirFourChildrensNames();  
  
Now granted I made that last one up, but I have seen Repository examples that are nearly as silly.  
  
The story is even worse when you are trying to bring back data in a form that does not exactly match your data structure. The pattern feels very restrictive to me with each repository matching an entity in the database.  
  
LINQ is a tempting way of getting around the querying problems by exposing a LINQ provider for your datasource to the other areas of the application. Which in certain cases I am all for, but in a large enough application this really isn’t that different from just letting the business layer execute it’s own SQL. Sure you might get some strong typing, but a basic structure change in the database can still see you hunting all over for references that need fixing.  
  
Then one day I saw in passing someone comment they preferred to use Query objects now over Repositories. A quick internet search didn’t turn up anything I considered a pattern so I set about thinking what might be meant by a Query object, and quickly convinced myself this is what I was really after.  
  
The basic requirements I had were a data layer that worked with POCO objects, able to be created as an interface to allow a secondary implementation and a focus on usable querying for both straight entities from the database and ad-hoc queries as needed.  
  
The objects I ended up with were fluent wrappers for basically a set of query options. These options are then used to construct a query using whatever method of database connection the app is using. Here is an example of a query to give you an idea of how it works.  
          `IList<Customer> = db.CustomerQuery()`



    `    .FirstName_Contains("Fred")`



    `    .LastName_Is("Blog")`



    `    .Age_Between(18, 35)`



    `    .FirstName_Sort(SortOrder.Ascending)`



    `    .List();`





  



And here is an example of how to implement FirstName_Contains() in an implementation of the query layer that uses NHibernate.Linq as it’s data provider.  



  
    `public ICustomerQuery FirstName_Contains(string name) {`



    `    if (!String.IsNullOrEmpty(name))`



    `        Query = Query.Where(d => d.FirstName.Contains(name));`



    `    return this;`



    `}`





  



Obviously that implementation code depends heavily on how you talk to your database. Before I started to utilise NHibernate.Linq it looked more like this  



  
    `Criteria.Add(Expression.Like("FirstName", name)`





So I now use a single database object that can load and save an entity from any table in the database, and it can also set up a query object for me to fill out with the appropriate options for that query and execute it.  



I find this a nice middle ground between needing every query to have it’s own method and the open slate that comes from exposing a LINQ provider or SQL statements.  



I won’t pull apart one of the projects that uses this to offer a full example of every method, but it is simple to add features like Top(), Take()/Skip(), even Count().  
  