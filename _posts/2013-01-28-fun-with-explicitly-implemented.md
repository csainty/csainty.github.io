---
title: Fun with Explicitly Implemented Interfaces
layout: post
permalink: /2013/01/fun-with-explicitly-implemented.html
tags: unittest C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-515965692519899508
tidied: true
---


I’ve picked up a new coding technique recently.  
I’ve always been a bit uncomfortable with the 1:1 relationship between class and interface. I’ve also been uncomfortable with large service classes like a repository.

When you take a dependency on a large service interface you are hiding all the details about what you are actually dependent on, which can cause you problems down the line with your tests and refactorings.  
Repositories in particular quickly escalate to large numbers of functions. If I am working on tests for a piece of code that takes a dependency on that repository I have no option other than to read the code to see what methods it is calling. Tedious.

So when I stumbled across the long forgotten (by me) practice of explicitly implementing an interface I saw potential to take a fresh look at some of these concerns.


I still don’t know exactly where this train of thought will take me but I’d like to throw it out there and see if it gets the gears turning for anyone else. I am using this heavily in a new personal project, so by the end of it I should have a good idea of whether it has helped or hindered me.  
A quick refresh on explicitly implementing and interface.  
 
```csharp
public interface IsEmailAlreadyInUse
{
  Task<bool> Execute(string emailAddress);
}

internal class SqlRepository : IsEmailAlreadyInUse
{
  Task<bool> IsEmailAlreadyInUse.Execute(string emailAddress)
  {
      // Implementation goes here
  }
}

```  

When you implement an interface like this (note the interface name in front of the method name) then it is only accessible when your instance of SqlRepository is cast as an `IsEmailAlreadyInUse`.  
Through a dependency injection container, which preferably includes an `AsImplemetedInterfaces()` option, this is very easily wired up.  
Notice how the `SqlRepository` is internal, this is saying that you shouldn’t be giving out instances cast as this type. You should be handing out a single instance (per appropriate lifetime scope) cast as its various interfaces.  
With this done, your code that is applying business logic around these persistence calls suddenly needs to be explicit about what functions it needs. It can no longer say _“give me a repository and I will do what I please with it”_.
 
```csharp
public interface IsEmailAlreadyInUse
{
  Task<bool> Execute(string emailAddress);
}

public interface CreateUser
{
  Task Execute(string username, string email);
}
 
internal class SqlRepository : IsEmailAlreadyInUse
{
  Task<bool> IsEmailAlreadyInUse.Execute(string emailAddress)
  {
      // Implementation goes here
  }
  
  Task CreateUser.Execute(string username, string emailAddress)
  {
    // Implementation goes here
  }
}

public class CreateUserCommand
{
  private readonly IsEmailAlreadyInUse isEmailAlreadyInUse;
  private readonly CreateUser createUser;
  
  // ctor
  
  public async Task<bool> Execute(string username, string emailAddress)
  {
    if (await this.isEmailAlreadyInUse(emailAddress)) return false;
    
    await this.createUser(username, emailAddress);
    return true;
  }
}
```  

When you are writing tests (whether before or after writing the implementation) it becomes very obvious what your code is actually dependent on. Which makes it easier to mock and easier to refactor or replace.  
An additional benefit is that if you end up with a lot of dependencies you should be stopping to consider if your pushing too much logic into a single code unit. Perhaps things can be broken down further and some reusability gained.

In my personal application I do all this in two code files. I have one where I define all my interfaces and one where I implement them all. Overall the approach is working well for me so far though, it has not been proven to be a burden to organise the code. I have very simple integration tests that ensure each command is doing what I expect it to. All my _“complicated”_ logic is then easily unit tested with FakeItEasy.

 
Finally I chose the repository as an example because it is a pattern I see often which could really benefit from a new approach. It is by no means the only example. At the same time don’t just go breaking interfaces apart for the sake of it, use them correctly as your units of abstraction.  
There is another interesting pattern you can use when implementing your interfaces like this. I will hopefully go into that next time.
