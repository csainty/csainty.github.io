---
title: LINQ to SQL&#58; Generic Primary Key function
layout: post
permalink: /2008/04/linq-to-sql-generic-primary-key.html
tags: linqtosql csharp dotnet
guid: tag:blogger.com,1999:blog-25631453.post-6501746339448683482
tidied: true
---

An issue I have seen blogged about a number of times with LINQ-to-SQL is that by strong typing queries, you lose the ability to create generic functions for processes such as fetching records by their Primary Key.

<!-- more -->

A recent example is [Rick Strahl](http://west-wind.com/weblog/posts/314663.aspx) who offers a number of good options for getting around this, while not being particularly happy with any of them. In the comments of Rick's post Richard Deeming offers a solution very similar to my own, which is to use the Meta-data provided by LINQ-to-SQL and the functionality of `System.Linq.Expressions` to create a simple and robust solution.

Here is an [extension method]({% post_url 2008-01-13-extension-methods %}) you can pop onto your `DataContext` object to facilitate the pulling of records from the database by their Primary Key.

```csharp
public static class DataContextHelpers
{
    public static T GetByPk<T>(this DataContext context, object pk) where T : class {
        var table = context.GetTable<T>();
        var mapping = context.Mapping.GetTable(typeof(T));
        var pkfield = mapping.RowType.DataMembers.SingleOrDefault(d => d.IsPrimaryKey);
        if (pkfield == null)
            throw new Exception(String.Format("Table {0} does not contain a Primary Key field", mapping.TableName));
        var param = Expression.Parameter(typeof(T), "e");
        var predicate = Expression.Lambda<Func<T, bool>>(Expression.Equal(Expression.Property(param, pkfield.Name), Expression.Constant(pk)), param);
        return table.SingleOrDefault(predicate);
    }
}
```


You can then run this code by doing the following

```csharp
MyDataContext db = new MyDataContext();
Product p = db.GetByPk<Product>(1);
```

**Note:** Excuse the excessive use of `var`. However it can be useful in the context of a code-snippet as it removes the need for you to work out all the using statements needed to make the code work.

So what does this code do, first we get a reference to the LINQ-to-SQL meta data store for the table we are querying, then pull out the Primary Key field for the table. It then builds a lambda expression tree that compares the Primary Key field of the parameter (that will be passed to the expression later) against the constant id passed to the function. This expression is then passed into LINQ-to-SQL where it can be decomposed and turned into SQL code. This is effectively the same as writing the lambda  `e => e.PK == id`, except that we work out the name for PK at run-time.

I have attached this as an extension method on the `DataContext`, but if you are using a base class for your entities, or writing a generic business object, you should be able to manipulate this fairly easily to do as you wish.

I have only scratched the surface of what may be possible with this technique of building code through Expression Tress, there is bound to be some interesting work done in this area as people get more and more accustomed to the concept.
