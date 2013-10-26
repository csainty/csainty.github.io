---
title: LINQ to SQL&#58; SQLMetal.exe
layout: post
permalink: /2008/02/linq-to-sql-sqlmetalexe.html
tags: linqtosql dotnet
---

I have recently switched over to using SQLMetal to generate my LINQ-to-SQL DBML and Context class. There are two things I like about it, one is that it is far faster. I just click a script on my desktop rather than open up the designer and recreate each table that has changed. I also prefer some of its naming conventions, it deals with multiple relationships to a  single table better.
Consider the case where you have an Orders table and it has two fields holding Address keys (ie ShippingAddressID and InvoiceAddressID). The LINQ-to-SQL generator in Visual Studio will create 4 properties ShippingAddressID,  InvoiceAddressID, Address, Address1. The last two being references to the Address entities. The problem being you cant work out which is which.   SQLMetal will detect this and one of them will be named ShippingAddress, sadly the other will still be simply Address. There is hope though.
SQLMetal.exe is a pretty straightforward console application that is installed alongside Visual Studio and can be used to generate your classes for you. For more details check out [MSDN](http://msdn2.microsoft.com/en-us/library/bb386987.aspx).    Creating your classes is a two step process, I have a .bat file on my desktop to do it for me.

`cd /d "C:\Program Files\Microsoft SDKs\Windows\v6.0A\bin"
SqlMetal /server:.\SQLEXPRESS /database:AdventureWorks /dbml:<DBML File>
SqlMetal /code:<Class File> <DBML File>`


Note: There are a number of other options you will want to investigate at the link above.
The other nice thing about this, though I have not investigated it yet, is that you get a hook on the DBML file before it is used to create the class file. This means if you wanted to you could run it through an XSLT processor with a stylesheet that defines all the changes you want to make to the data model. This gives you a great way of abstracting your changes away from the base model and saves you the time and hassle of making the every time you update the model. If I actually take the step of doing this I will be sure to blog about it with an example. One change you may want to consider is fixing the above issue of the double links being poorly named.