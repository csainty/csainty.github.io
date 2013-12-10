---
title: OWIN - Am I missing something?
layout: post
permalink: /2013/12/owin-am-i-missing-something.html
tags: csharp dotnet owin opinions
---

Time for some opinion. In the last few days I have taken my first serious look at [OWIN](http://owin.org/) and I can't help but feel the whole idea is being polluted by the [Katana](http://katanaproject.codeplex.com/) project.

<!-- more -->

> *Update:* I made a slight mistake in laying all these problems at the feet of Katana. The origins of the practices I don't agree with lie with the reference implementations on the [OWIN github](https://github.com/owin) account. I mistakenly thought these had been *moved* to Katana, but that was a mistake, Katana is simply built on top of these concepts.

My motivator to take a closer look came from checking in on how the [Glimpse](http://getglimpse.com/) middleware for OWIN is coming along. The first thing I see is that the `Glimpse.Owin` library has 3 nuget dependencies - `Owin`, `Owin.Extensions` and `Owin.Types`. *"WTF? OWIN doesn't have packages!"*, I thought to myself. Worse still, it isn't even a real piece of OWIN middleware, it is an `IAppBuilder` from one of these packages.

So I asked myself why this approach had been taken. I did a bit of searching on Nuget, on GitHub and on blogs. Almost everyone is doing the same thing. Almost all introductory posts pull in these libraries and build against them.

The Katana project is a sprawling mass of libraries, abstractions and dependencies. Taking a single piece of their middleware out to use in your project will drag in a ton of cruft. *Sigh*. This isn't how it should be!

#### If you only remember one thing...

OWIN doesn't need a library, it has no dependencies. OWIN middleware is simply a function with the signature `public Task MyMiddleware(IDictionary<string, object> environment)`. That is all. If this isn't the signature of your middleware, then you are doing the wrong thing.

#### State of the community

What I expected to find when I went looking were dozens upon dozens of small independent pieces of middleware that could be pieced together to build my own *"framework"* that suited my development needs.  
Maybe I want attribute-based routing, no view engine, and content negotiation to build a nice simple API. Maybe for my next project I want convention-based routing, razor views, and a coffeescript compiler for my static content.

What I found was just another misguided and all-encompassing library dominating the ecosystem.

Am I missing something here? Do my ideas for OWIN not match those of the community?
