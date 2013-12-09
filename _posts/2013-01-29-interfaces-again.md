---
title: Interfaces again
layout: post
permalink: /2013/01/interfaces-again.html
tags: csharp dotnet
guid: tag:blogger.com,1999:blog-25631453.post-2325482393140941532
tidied: true
---


In my recent post about [interfaces]({% post_url 2013-01-28-fun-with-explicitly-implemented %}) I showed one approach to breaking up and consuming your interfaces that I am finding interesting at the moment. The idea was born out placing restrictions on myself and trying to be explicit about my dependencies. I wanted to structure the code in a way where I couldn’t get lazy and just start firing off database code from anywhere in the codebase.

<!-- more -->

In an earlier iteration of that same thought process I had a different structure that was quite interesting in its own right. I don’t think either is better than the other. But I do find them both interesting and hopefully someone reading this does as well.

So what is my second example for you? Well again it involves tricks of code organisation to change the way the functionality of a class is consumed. This one is more about taking a class that implements multiple interfaces but exposing them in a more structured way. Again I will work in the repository space. For the same reasons as last time, it is a service type we all understand and that we have all seen go wrong at some point. Don’t read this as a guide on how you should structure code it is merely a thought exercise at this point.


```csharp
public interface IQueries
{
  Foo GetFoo(int fooId);
  IEnumerable<Foo> QueryFooByBar(int barId);
}

public interface ICommands
{
  void AddFooToBar(int barId, Foo foo);
}

public class Repository : IQueries, ICommands
{
  public IQueries Queries { get { return this; } }
  public ICommands Commands { get { return this; } }

  Foo IQueries.GetFoo(int fooId) {
    // Implementation
  }

  // Other interface implementations
}

// Some other code
{
  var repository = new Repository();
  var foo = repository.Queries.GetFoo(1);
  repository.Commands.AddFooTobar(2, foo);
}

```


So in this case we take a dependency on the large service class, the repository, but even though that class potentially implements a lot of code we use explicit interfaces and getters to cut down the surface of the class and help a consumer find their way through it.

Unlike my previous article this doesn’t give you much in your testing or make your code more explicit about it’s dependencies. It’s doesn’t do as much for refactoring or replacing implementations of individual interfaces. It is all about IntelliSense really and making a class which, for whatever reason needs to be this complex, a little more manageable.

Going back to where all this started, I am thinking a lot lately about how I manage abstraction. Where my interfaces sit, what boundaries they have and how their implementations are structured. It is nice to take a step back like this at times and look at our tools, ask what else can I do with this and how else “could” it look.

There are a lot of opposing opinions out there, opinions that are constantly changing and evolving. In the end we need to find the processes that are working for us, our teams and our codebase. Situations are never the same, so learn as much as you can and apply it where it makes sense.

In that spirit it must be about time for another “[Learn Something New]({{ 'learn' | tag_url }})” post.
