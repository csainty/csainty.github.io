---
title: ASP.NET MVC Application Layout
layout: post
permalink: /2008/03/aspnet-mvc-application-layout.html
tags: mvc asp.net dotnet
id: tag:blogger.com,1999:blog-25631453.post-879390250247104179
---


I am slowly evolving my general layout for ASP.NET MVC applications as I come more and more to grips with the framework and they ways I am most comfortable using it.  
  
This post is going to be a bit of an overview of how I am laying out my project at the moment in case it is of use to anyone.  
  
#### Controllers
  
I have reduced the work-load of my controllers substantially since my early attempts. My average controller action now performs three simple steps. Create a Model, Pass the relevant state data from the URL to the Model, Choose and render a View.   When combined with the new ActionFilters to handle things like Authentication and SSL, I can really see my controllers being replaced by some form of Inversion-of-Control class that is configured up and simply runs the same piece of code for every action using the configuration as a guide.  
  
#### Models
  
As my controllers have become simpler, my models have become more complicated. I am still using LINQ-to-SQL to connect to the database, but there is a bit more to models than just this.   My models have two sets of properties, those that are get/set which provide an interface for the controller to tell the model what state the user has requested (ie ProductID = 1) and those that are only get. The later provide the interface the View should use to present it's data. Often I don't load each piece of this data unless it is requested.  
  
#### Views
  
I have killed off code behind files. I still think strong typing views is a good idea though.   Rather than having a code behind file on every page just to set up this strong typing, I am using a single Views.cs file for each directory of Views, it contains empty definitions for each page eg     public partial class Home : ViewPage<HomeModel> { }    The main benefit here is that it removes clutter, both in terms of files in the project and cuts down the @Page declaration in the .aspx files    For the project at hand this is very useful as I will need to deal with designers who will be making lots of pages based around a small number of models. So I will have a basic set of page models and you simply point that page at the one that provides the appropriate data set.  
  
#### Testing
  
Testing of Controllers and Models is a fairly straight forward task now as they both have well defined roles. Testing a controller involves checking the correct View has been chosen and the a model has been correctly chosen and sent to the View. Testing a model involves setting different state configurations and then checking to see the data public data to be used by the view is correctly set.   Views are still causing head-aches for testing though. Getting a view to render down to a string from the context of a Unit Test is proving difficult. I should get my hands on a spare box to set up as a Continuous Integration and Test box soon though and if nothing else I will be able to use one of the UAT web tools to test Views along with the whole process flow and performance of the app.    I am also finding that using subclasses of the new Http*Base classes is an easier proposition than Mocking these classes. I have completely removed Mocking from my tests for the moment, though I learnt a lot from the excursion and will definitely find a use for the technique in the future.  
  
#### Drawbacks
  
The only real concern I have at the moment is exposing LINQ-to-SQL classes through the model for the view to consume. This is effectively tightly coupling my views to the LINQ-to-SQL back-end. I believe to be a "truer" MVC application the data source should be easier to replace. If I wanted to switch to a disconnected web service based data source (for an extreme example) I would currently need to create a set of data classes that matched the LINQ-to-SQL classes, a massive task. It's near impossible to resist the lure of LINQ-to-SQL though, it is just so nice to work with.   I am hoping that the forth coming LINQ-to-Entities will reduce my concerns by at least offering a path to a different database on the back-end even if I can still not move to a totally different type of data source.  
  
#### Conclusion
  
The more I use the framework, the more I like it. The recent release of the source code for the framework is a nice bonus, it has made debugging a few things easier and will make extending the framework much easier.  
