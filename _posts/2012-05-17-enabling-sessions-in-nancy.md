---
title: Enabling sessions in Nancy
layout: post
permalink: /2012/05/enabling-sessions-in-nancy.html
tags: appharbify nancy appharbor C#
guid: tag:blogger.com,1999:blog-25631453.post-5401735484008996387
tidied: true
---


As you may know, [AppHarbify](http://appharbify.com) is built with [Nancy](http://nancyfx.org/). One of the reasons I decided to build it in Nancy, other than the fact that Nancy is awesome, was that I wanted to put together a real project that can be used as an example of Nancy in action. All the code for AppHarbify is available on [GitHub](https://github.com/csainty/Apphbify).

To go with that I am planning to put together some blog posts talking about various aspects of the code.
To start with I am looking at sessions.

#### Getting Started

Nancy ships with a single session provider implemented, `CookieBasedSessions`. You can of course add your own.
This provider stores the session, encrypted, in the users cookies. Which is really not too bad of a solution to get started. You are up and running with a single line of code added to your `ApplicationStartup` method in your Bootstrapper.


```csharp
public class Bootstrapper : DefaultNancyBootstrapper
{
    protected override void ApplicationStartup(TinyIoCContainer container, IPipelines pipelines)
    {
        CookieBasedSessions.Enable(pipelines);
    }
}
```


Once enabled, you can simply access the Session property on Request.

`Request.Session["Key"]`

Now you don’t want to store too much data in a cookie-based session like this, as every request is sending the data back across the wire. Also it is theoretically possible the encryption could be broken.  
__Side note:__ You can control the encryption provider with an optional second parameter to `.Enable()`. If you do not, then a new key is generated each time the app starts, invalidating all existing sessions.

#### Testing

If you do any work with sessions, you are likely to need to test them eventually. While the mechanism is a bit awkward, it is essentially pretty easy. My preferred method is to attach an event to the `.Before` pipeline in your testing Bootstrapper that injects the required session into the request.


```csharp
public static class BootstrapperExtensions
{
    public static void WithSession(this IPipelines pipeline, IDictionary<string, object> session)
    {
        pipeline.BeforeRequest.AddItemToEndOfPipeline(ctx =>
        {
            ctx.Request.Session = new Session(session);
            return null;
        });
    }
}

[Fact]
public void TestSession()
{
	var boot = new ConfigurableBootstrapper(with => { with.Module<PagesModule>(); });
	boot.WithSession(new Dictionary<string, object>() { { "key", "value" }, { "number", 2 } });
	var browser = new Browser(boot);

	var response = browser.Get("/Test");


	Assert.NotNull(response.Context.Request.Session);
	Assert.Equal(response.Context.Request.Session["key"], "value");
	Assert.Equal(response.Context.Request.Session["number"], 2);
}
```

By adding this simple extension method and calling it on your Bootstrapper whenever you want to test a route that needs session information, you can very simply abstract away your real session storage mechanism without adding more layers of abstraction to your actual codebase.

#### Future

While AppHarbify is currently running along fine using these cookie based session, for the reasons I have stated above it is not ideal. So the plan is to write Redis based session mechanism and take advantage of the easily installed Redis add-on at AppHarbor. Of course this code will be open-source and released independently of AppHarbify as a nuget package. So watch out for that!

