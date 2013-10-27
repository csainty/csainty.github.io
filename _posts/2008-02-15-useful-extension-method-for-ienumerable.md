---
title: Useful Extension Method for IEnumerable
layout: post
permalink: /2008/02/useful-extension-method-for-ienumerable.html
tags: linqtosql linq C# dotnet
id: tag:blogger.com,1999:blog-25631453.post-6951048548340824969
---


I have written a useful (in my opinion) [Extension Method](http://csainty.blogspot.com/2008/01/extension-methods.html) for the IEnumerable<> objects used in LINQ that I will share in this post.  
  
I call it CastAs() and it basically performs a casting operation on every item in a collection, returning a second collection of the results.  
  
The LINQ classes ship with a Cast() function that will work if the compiler knows how to cast between the two objects, but in the cases that it does not this one will help you out.  
  
Note: I avoided calling the method Cast() as Intellisense did not like it and hid the original Cast() method even though they had different signatures.  
  
Now for the function.  
     `public static List<T2> CastAs<T1,T2>(this IEnumerable<T1> list, Func<T1, T2> fn)
{
    List<T2> list2 = new List<T2>();
    foreach (T1 item in list)
    {
        list2.Add(fn(item));
    }
    return list2;
}`




I am currently returning a List as this has been the form I wanted the results in every time I have used it so far. Feel free to make your own decision on a return type however. You might even be able to make its return type anonymous, though I had no luck trying that.  



The function takes a single parameter which is a [Lambda Expression](http://csainty.blogspot.com/2007/12/linq-to-sql-lambda-expressions.html) representing a function mapping the first type to the second type. Here is an example converting a List<string> into a List<int>.  



  `List<string> x = new List<string>();
x.Add("1"); x.Add("2"); x.Add("5");
List<int> y = x.CastAs(s => Int32.Parse(s));`




Trivial, but useful.  



However a place you might find this more useful is when dealing with Many-to-Many joins in LINQ-to-SQL. Sadly the modelling leaves a little to be desired.
  Imagine you have two tables Users and Roles. Then you have a Many-to-Many table joining the two called UserRoles. In LINQ-to-SQL an instance of a User record will have a collection of UserRole's attached to it, where as what you really want is a collection the Roles themselves. Well using our above function you can do just that with a single line of code.  



  `List<Role> roles = myUser.UserRoles.CastAs(d => d.Role);`




The lambda expression tells the function how to "cast" each UserRole into the Role on the other side of the join.  



Note: This does not have any neat mapping into SQL on the server side for performance help, so if you were to run this against a full table you would bring back a lot of data and do a lot of processing on the client. So think first before you use this. Using the DataContext.LoadOptions.LoadWith() function would help if performance was a concern.  



In case anyone takes offence to my calling this a cast, I don't mind if you choose to implement the function with a more "correct" name.  
  