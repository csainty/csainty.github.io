---
title: LINQ to SQL: Be careful of CreateDatabase()
layout: post
permalink: /2008/02/linq-to-sql-be-careful-of.html
tags: linqtosql C# dotnet
---

I have recently started work on what will become our first production application using LINQ-to-SQL and had hoped to use the CreateDatabase() function that is found on the generated DataContext to simplify the process of setting up the database on the client machine.
Ideally I wanted a nice simple piece of code like this

`AdventureWorksDataContext db = new AdventureWorksDataContext();
if (!db.DatabaseExists())
{
    db.CreateDatabase();
}`


At first glance this works great, you get a shiny new database created with all the right tables and relationships. The devil however is in the detail.
Because LINQ-to-SQL only models the database relationships, some important information is not stored in the DataContext and therefore will not propagate with a CreateDatabase() call. This includes (but is not limited to) Default Field Values and Triggers.
  Now it is possible to code around this. If you like, both can be handled in code by hooking into the OnValidate() partial method of your generated data classes. See [here](http://csainty.blogspot.com/2008/01/linq-to-sql-extending-data-classes.html) for a previous post about partial methods, though not specifically that method.
However the next problem is not so easy to code around. Although a relationship such as FK_OrderItems_Orders will be created in your new database, it will not necessarily have the same name as the relationship in your master database. In fact the two don't even follow the same naming standard (LINQ-to-SQL leaves out the FK_) so they are almost certain not to have the same name.
  What this means is that you can not write a SQL script against the master database to be rolled out onto the client databases with a future upgrade.
Sadly this renders the CreateDatabase() call basically useless in anything other than the simplest applications.
I would love to see LINQ-to-SQL in the future ship with a set of tools that wrapped up proper database creation and upgrades for you and could reduce it to a piece of code as simple as that above. Now that would be pretty special.