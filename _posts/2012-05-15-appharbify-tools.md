---
title: AppHarbify Tools
layout: post
permalink: /2012/05/appharbify-tools.html
tags: appharbify appharbor C# ef
id: tag:blogger.com,1999:blog-25631453.post-3076838595044920362
tidied: true
---


An important goal of [AppHarbify](file:///Users/csainty/Code/Blogger2Markdown/appharbify.com) is to make as much open source software as possible be AppHarbor-friendly. To speed this process along I will be creating and/or finding many libraries to solve common problems.  

The first problem I have tackled is handling connection strings with Entity Framework. Specifically conventions based Code-First EF.  

AppHarbor already has quite an elegant solution where you log into the Sequelizer add-on and set your desired connection string, then at deployment that connection string is either inserted or updated with the connection details for your instance.  

Unfortunately AppHarbify can not rely on this mechanism as it can not set configuration variables inside an add-on.  

#### The solution

What I found was a static property `Database.DefaultConnectionFactory` which holds the factory EF uses to create its database connections.  

It was then a simple matter of detecting if we are on AppHarbor (by the presence of the AppSetting which AppHarbor stores the connection string in) and then replacing this factory with a new one that creates connections from the AppSetting.  

> [https://github.com/csainty/AppHarbify.Tools/blob/master/src/AppHarbify.EF/ConnectionFactory.cs](https://github.com/csainty/AppHarbify.Tools/blob/master/src/AppHarbify.EF/ConnectionFactory.cs)  

#### NuGet Package

To make this as simple as possible I then bundled this up as a NuGet package [AppHarbify.EF](http://nuget.org/packages/AppHarbify.EF).  

Once installed it is a one-liner to enable your application to use the connection string in web.config when not on AppHarbor, and switch across to their AppSetting when you are.  
 `AppHarbify.EF.ConnectionFactory.Enable();`

#### Migrations

There is one little snag with this approach. Migrations. The Migrations package, for reasons I have not yet investigated, chose to use their own mechanism for fetching the connection to the database. One that very strictly follows the convention of a connection string named after your DbContext.  

So for Migrations to work, you need to strip the connection string out of your web.config when it is deployed too AppHarbor. With no connection string present it will then fallback through other means of creating the connection and settle on one that works for us. If AppHarbor is your only deployment target, this is simple. See [https://github.com/csainty/JabbR/blob/AppHarbify/JabbR/Web.Release.config#L18](https://github.com/csainty/JabbR/blob/AppHarbify/JabbR/Web.Release.config#L18)  

If you need to handle multiple deployment locations then this is going to get more tricky. I am hoping that the EF team can unify behind one strategy for database connection creation and make it extensible.  
