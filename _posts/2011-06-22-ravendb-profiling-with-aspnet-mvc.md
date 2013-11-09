---
title: RavenDB Profiling with ASP.NET MVC
layout: post
permalink: /2011/06/ravendb-profiling-with-aspnet-mvc.html
tags: ravendb mvc asp.net C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-8023995134833538387
tidied: true
---


I have recently been using (and occasionally contributing to) [RavenDB](http://www.ravendb.net/), a NoSQL (or Document) database for .NET written by Oren Eini, aka [ayende](http://ayende.com/).  
  
My biggest contribution yet has been to help with the basic "glue" to drive the new UI for profiling RavenDB requests in an ASP.NET MVC web application.  

<!-- more -->

There is a live demo up on Oren's blog right now, simply look for and click on the RavenDB Profiler box in the top left hand corner.  
  
If you are working with RavenDB and want to add this to your own project, it is really simple. As of right now you are going to need to grab an [unstable build](http://builds.hibernatingrhinos.com/builds/ravendb-unstable), at least 391. But these changes will make it into the stable builds soon enough.  
  
You then need to explicitly add a reference to `Raven.Client.MvcIntegration` to your project. There are security risks with showing the profiling data to just anyone, so you need to explicitly add the support.  
  
Next go to the code where you create your DocumentStore and pass a reference off to the profiler.  
  
`Raven.Client.MvcIntegration.RavenProfiler.InitializeFor(myDocumentStore);`
  
Finally in your master page <head> section add (assuming the Razor view engine)  
  
`@Raven.Client.MvcIntegration.RavenProfiler.CurrentRequestSessions()`
  
The only other dependency is jQuery, if you are not already using jQuery you can add it off the Google CDN, or from Nuget.  
  
It is as simple as that, all the sessions and requests involved in producing your page will be visible for you to drill into. Also if your page makes any AJAX requests (using jQuery) these will be picked up and their sessions added to the results window! That was one of my contributions :)  
  
The profiler is still very much in it's early stages, there is a lot more to come yet, but the base is now firmly in place I believe and ready to be built on top of.  
  
