---
title: ASP.NET MVC - Testing
layout: post
permalink: /2008/03/aspnet-mvc-testing.html
tags: mvc asp.net C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-1535672534721661582
tidied: true
---

I have been further exploring the concepts of Test Driven Development of late, in particular around the ASP.NET MVC framework.  
  
One concept that is very new to me is mocking. I have been using [Rhino Mocks](http://ayende.com/projects/rhino-mocks.aspx). This is not going to be a post about mocking, I am far much of a novice to offer any useful advice on this front just yet. However, it is pretty cool stuff and worth a read.  

<!-- more -->
  
The MVC team have been talking a lot about testing and mocking lately, and I have found that trying to get a clear picture of exactly where they are at is quite difficult. Most examples and blogs pre-date the latest code refresh and either do or do-not work because of this. One useful resource so far though is this [post](http://www.hanselman.com/blog/ASPNETMVCSessionAtMix08TDDAndMvcMockHelpers.aspx) from [Scott Hanselman](http://feeds.feedburner.com/ScottHanselman).  
  
He provides a nice simple set of Mocks for the basic `HTTPContext` objects, which at this stage are very useful if you want to unit test your controllers.  
  
It is not a complete solution though. The real sticking point is the `RedirectToAction()` method. It is difficult to mock. Over on [MvcContrib](http://www.codeplex.com/MVCContrib/Wiki/View.aspx?title=TestHelper&referringTitle=Documentation) however they have an implementation that uses interception classes from the Castle project to intercept calls to `RedirectToAction()` to supply their own functionality. A clever if cumbersome approach.  
  
The following code snippets have a few dependencies. The Rhino Mocks dlls can be found at the URL I mentioned above, and the Castle.Core and Castle.DynamicProxy2 dlls can be found amongst the MvcContrib release.  
  
Now on to some code. I have a method in my controller unit test base class to create a controller for me, configure up the mocked HTTPContext objects from scott, add a fake ViewEngine and intercept the RedirectToAction() method. Works well so far, and looks a bit like this.


```csharp
public T CreateController<T>() where T : Controller, new()
{
    ProxyGenerator generator = new ProxyGenerator();
    T c = (T)generator.CreateClassProxy(typeof(T), new ControllerInterceptor(this));
    c.ViewEngine = new MockViewEngine();
    Mocks.SetFakeControllerContext(c);
    return c;
}
```

`ProxyGenerator` comes from Castle.  
`Mocks` is a `MockRepository` stored on the base class.  
`MockViewEngine` is an empty class that implements `IViewEngine` but does nothing yet, I want to implement something on this but I have not decided exactly what yet.  


The interceptor looks like this. I had to change the one from MvcContrib because it was not working on the new Preview 2 release of MVC. Also I still wanted it to let the ViewEngine get involved incase I wanted processing there, something the MvcContrib did not do.  



```csharp
public class ControllerInterceptor : IInterceptor
{
    private TestClassController _parent;

    public ControllerInterceptor(TestClassController parent)
    {
        _parent = parent;
    }

    public void Intercept(IInvocation invocation)
    {
        if (invocation.Method.Name == "RenderView" && invocation.Arguments.Length == 3)
        {
            string viewName = (string)invocation.Arguments[0];
            string masterName = (string)invocation.Arguments[1];
            object viewData = (object)invocation.Arguments[2];
            _parent.RenderViewData = new RenderViewData
            {
                ViewName = viewName,
                MasterName = masterName,
                ViewData = viewData
            };
            //return;
        }
        if (invocation.Method.Name == "RedirectToAction" && invocation.Arguments.Length == 1)
        {
            RouteValueDictionary value = invocation.Arguments[0] as RouteValueDictionary;
            string actionName = value.ContainsKey("Action") ? (string)value["Action"] : "";
            string controllerName = value.ContainsKey("Controller") ? (string)value["Controller"] : "";
            _parent.RedirectToActionData = new RedirectToActionData
            {
                ActionName = actionName,
                ControllerName = controllerName
            };
            return;
        }
        invocation.Proceed();
    }
}
```

With all this set up and hooked together (I have left a few bits out, you will need to create the `RenderViewData` and `RedirectToActionData` classes, just holders for the properties used) you can reduce your actual unit testing code down pretty small.  


```csharp
[TestMethod()]
public void IndexTest()
{
    var controller = CreateController<HomeController>();
    controller.Index();
    Assert.AreEqual("Index", RenderViewData.ViewName);
}


[TestMethod()]
public void ListNotFoundTest()
{
    var controller = CreateController<ProductController>();
    controller.List("1000", 1);
    Assert.AreEqual("ProductNotFound", RedirectToActionData.ActionName);
}
```

Its a shame that such simple tests currently require such elaborate mechanisms. The MVC guys assure us that they are listening and will be bundling in helpers or changing the framework to make these things simpler in the coming releases, for the time being though it is a bit of fun if you give it a chance.  

One thing I would like to do is integrate Route testing with Controller testing. So instead of calling `Controller.List("1000", 1);` I could `CallURL("/Product/List/1000/1");` and have the routing classes fire up and map the URL through.

I would also later like a simple way to compile the .aspx view. I dont really need to run it as I don't want to check its output at this stage. But simply checking it compiled would be a good start. This is why I have a placeholder `ViewEngine` at the moment instead of just mocking `RenderView()` to do nothing.  

Overall I am very happy with the framework, I am waiting to get my hands on a dedicated test server in the near future to set up  Continuous Integration and some load/performance tests. That should be fun.  
