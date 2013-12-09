---
title: Learn Something New&#58; Nancy
layout: post
permalink: /2011/10/learn-something-new-nancy.html
tags: javascript nancy asp.net learn-something-new csharp knockout dotnet
guid: tag:blogger.com,1999:blog-25631453.post-2667713463273702490
tidied: true
---

Today my toolset of choice for a quick learning session is Nancy. 

Reading straight from the box

> Nancy is a lightweight, low-ceremony, framework for building HTTP based services on .Net and Mono. The goal of the framework is to stay out of the way as much as possible and provide a super-duper-happy-path to all interactions.

Got that? Think of it as a replacement for WebForms or ASP.NET MVC.

<!-- more -->

Nancy is available on [NuGet](http://nuget.org/List/Packages/Nancy) or on [GitHub](https://github.com/NancyFx/Nancy) if you want the source and docs. The docs are well worth a look over, and you are bound to need the aid of a sample project as you find your feet. Having said that, it is really quite simple so you should be up to speed in no time.

These posts are not supposed to be walkthroughs, so I won’t go into detail getting you started other than to say that you start with an “ASP.NET Empty Web Application”, add the Nancy bits from NuGet (grab the [AspNet](http://nuget.org/List/Packages/Nancy.Hosting.Aspnet) hosting package and [Razor view engine](http://nuget.org/List/Packages/Nancy.Viewengines.Razor) as well for simplicity), create a subclass of `NancyModule` and away you go.

You can see my demo live at [http://nancydemo-1.apphb.com/](http://nancydemo-1.apphb.com/) and grab the source from [https://github.com/csainty/NancyDemo](https://github.com/csainty/NancyDemo).

Where I think Nancy really shines is writing an API / REST service. As the box says, there is so little ceremony that you never feel like you are fighting the framework to perform simple tasks. Even in ASP.NET MVC I find this sort of thing a little clunky feeling. As for WebForms, I did my best to avoid them altogether.

My sample site performs the simple task of allowing the user to type in a message, saving it away and displaying it to other users on the site. All this is handled with a single page and some javascript. Using [Knockout]({% post_url 2011-10-07-learn-something-new-knockout-js %}) JS again.

The interesting code in this project mainly lies in the Modules.
First we have a `PageModule`, which is serving requests for regular pages.


```csharp
public class PageModule : NancyModule
{
	public PageModule()
	{
		Get["/"] = p => View["Default"];
	}
}
```  

It really is as simple as that to catch requests to `/` and serve up a view in response.

Second we have the `ApiModule`, which is handling the API requests being made by AJAX.


```csharp
public class ApiModule : NancyModule
{
	private readonly IDataStore _Data;

	public ApiModule(IDataStore data) : base("/api")
	{
		_Data = data;

		Get["/messages/list"] = p => Response.AsJson(_Data.GetMessages());

		Post["/messages/save"] = p => { _Data.AddMessage(Request.Form["Message"]); return "OK!"; };
	}
}
```  

Again, you can see that is very simple.

To demonstrate Dependency Injection using Ninject, there is a simple data store interface and an in memory implementation.


```csharp
public class CustomBootstrapper : NinjectNancyBootstrapper
{
	protected override void InitialiseInternal(IKernel container)
	{
		base.InitialiseInternal(container);
		container.Bind<IDataStore>().To<InMemoryDataStore>().InSingletonScope();
	}
}
```  

Here we are subclassing the Ninject bootstrapper, there are other implementations, and adding in the bindings we need.

Of course I have barely scratched the surface here on a very intriguing project. I am hoping to put it to real use in something very soon.

#### Tools and Services Used


[Knockout JS](http://knockoutjs.com/)  
[Nancy](https://github.com/NancyFx/Nancy)  
[AppHarbor](https://appharbor.com/)  
[jQuery](http://jquery.com/)  

