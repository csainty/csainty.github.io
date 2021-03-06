---
title: LINQ to SQL&#58; A Step Back
layout: post
permalink: /2007/12/linq-to-sql-step-back.html
tags: linqtosql dotnet
guid: tag:blogger.com,1999:blog-25631453.post-335903624741575742
tidied: true
---

In this, my third article on LINQ-to-SQL, I am going to be taking a step away from the code and delve into a discussion about what I will think most people will miss when they first approach this new technology.

<!-- more -->

What LINQ-to-SQL does is abstract the database away from the developer. It then provides a truly OO interface to your data.  
To take the view that LINQ-to-SQL lets you integrate a query straight into your code is to miss the point entirely.

Briefly, the wizard creates a new type for each table that represents a single record in the table with a property for each field. A top-level `DataContext` object is then created that acts as the starting point for your data access. To it is added a Collection for every table in the database. These Collections are typed to only accept objects of the appropriate record type. The Orders collection will only work with `Order` objects.

What this achieves is data access that is type checked every step of the way. `Tables`, `Fields`, `Stored Procs`. Every read/write/delete is properly type checked. Something sorely missing from 1st party data access in .NET all these years.

Where things get really special though, is in the mapping of relationships. If your database has an Order table with a relationship defined to a Customer table using a `CustomerID` field. Your `Order` type in LINQ-to-SQL will have two properties, a `CustomerID` property (likely you have used an int) and a `Customer` property that is of type `Customer`.  
This allows you to find the name of the customer from an order, in a very OO manner `myOrder.Customer.CustomerName` LINQ-to-SQL uses the relationship information to generate and execute a SQL statement that joins these two tables based on `CustomerID` and pull off the appropriate field. Take a moment here to contrast this with what you would need to do to achieve this with your current data access technology.  
_(This is where someone writes in to tell me about Framework X and its amazing data layer. Glad to hear it.)_

The important mental hurdle people will face is being able to stop thinking in SQL and start thinking in Objects. The benefits of doing so will be faster development, and thanks to type checking it will also be safer. I also believe it will greatly reduce the time it takes to bring a new developer up to speed on the database layout, they will be able to learn through intellisense as they go and avoid learning each table name, field name and join condition the old way (with a giant diagram).  
I am reminded of an old lecturer of mine that promoted storing data in serialised collections as a better mechanism than databases for some convoluted reason involving ease-of-use and a total lack of understanding indexes. I promptly pointed out the complete lack forethought in this notion, but I guess he could now have the best of both worlds.

Viewing a database as a giant connected set of objects and collections, brings it into line with how all other data is stored and accessed in applications. Passing objects around an application especially between a Presentation and Business Layer is very natural. Adding an object to a collection instead of serialising the object into an `INSERT` statement is equally natural. The same applies for deleting, sorting, filtering and many other standard SQL operations. We "get" objects, and although we may also "get" SQL there has long been a disconnect, two mind sets we needed to use.

I am only scratching the surface on how LINQ-to-SQL will change the way you code.

I am going to dig into building custom queries from UI selections (think about building the queries behind a complex reports using the old SQL string building methods), extending the base functionality of LINQ-to-SQL with Partial Classes and Partial Methods plus a whole host of other examples and techniques.
