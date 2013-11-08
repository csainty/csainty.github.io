---
title: WPF + Strong Typing
layout: post
permalink: /2009/11/wpf-strong-typing.html
tags: wpf C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-425953652379976352
tidied: true
---


I have been working with WPF recently, and one of the things that annoys me most is the usage of strings to reference object properties. This mainly affects Bindings, but also pops up in other places such as the [IDataErrorInfo](http://msdn.microsoft.com/en-us/library/system.componentmodel.idataerrorinfo.aspx) interface.  
  
Here is an example that anyone who has touched WPF should understand.  

```markup
 <TextBox Name="textBox1" Text="{Binding DataItem}" />
```

This particularly bothers me when writing a project from scratch where the data model is still evolving and there is refactoring going on. While some tools like ReSharper are pretty good at picking these up and changing them when you rename a property, you are still relying on the correct usage of a tool rather than the compiler to keep everything in sync.  

Now perhaps I am just bad at bing-ing (not quite as catchy as Google’s verbs is it) but this issue seems to be really difficult to find any good coverage on. There are a number of posts around with people complaining, and there are a number of cranky comments on those blogs from people who just say deal with it, but there is very little in the way of a solution. And from what I have seen there is no attempt to improve the situation in the next release of VS/WPF/C#.  

Now I don’t have a perfect solution to offer either, but I do have a little class that makes my life easier. It is similar code to what you will find inside some LINQ providers if you dig into them and involves breaking a [Lambda Expression]({% post_url 2007-12-31-linq-to-sql-lambda-expressions %}) down into a useful form (in this case a string).  

First things first, this involves moving your bindings from the XAML and into the code-behind file (or some other place that has access to the controls). Personally I prefer this, I like to put as little into XAML as possible. I see the XAML as a visual layer, therefore beyond visual styling and control names I try to keep my XAML files empty. I personally do both data binding and event binding in the code behind, always have. 

If this is unacceptable to you for whatever reason, then I can do nothing to help your assumed string based data binding woes.  

On to the code.   


```csharp
using System;
using System.Linq.Expressions;
 
namespace MagicStringBlog
{
    public static class MagicString
    {
        public static string Get<T>(Expression<Func<T, object>> ex) {
            string name;
            switch (ex.Body.NodeType) {
                case ExpressionType.MemberAccess:
                    name = ex.Body.ToString();
                    break;
                case ExpressionType.Convert:
                    name = ((UnaryExpression)ex.Body).Operand.ToString();
                    break;
                default:
                    throw new Exception(String.Format("Expression type {0} unknown", ex.Body.NodeType));
             }

             name = name.Substring(name.IndexOf('.') + 1);    // remove the lambda name from expression (d=>d.Test to Test)
            return name;
        }
    }
}
```

I stole the name `MagicString` from a blog post I read a while ago about configuring NHibernate and how all the strings were “magic” because you just had to assume you have typed them correctly and that they will work. (On a side note for NHibernate users, if you are using the [Fluent](http://fluentnhibernate.org/) interface you are likely to find some code very similar to the above in it somewhere)  

The first thing to note is that the `Func<T, object>` which describes a delegate that takes a parameter of type T and returns something (of type `object`, so anything) is wrapped in a [System.Linq.Expressions.Expression](http://msdn.microsoft.com/en-us/library/system.linq.expressions.expression.aspx). I’ve never looked at how this precisely works, but the end result is that instead of getting a reference to a delegate that can be `.Invoke()`’d you get an expression tree that can be analysed, modified, compiled and then executed. Note that here I only perform step one of that sequence, there is no attempt at execution made. 

These expressions are at the core of how a LINQ provider such as LINQ-to-SQL can take your `.Where(d=>d.PK==1)` and turn it into a SQL statement rather than returning all the objects from the database and running that piece of code over them as CLR objects.  

The contents of the method are not as important as the signature, but basically it analyses the expression, pulls out the name of the property being referenced and returns it. The only complication comes from types that are wrapped to be returned as an object, for example bool, then you need to dig inside the casting operator.  

And here is how we call it in the case of a data binding.  


```csharp
textBox2.SetBinding(TextBox.TextProperty, MagicString.Get<DataClass>(x => x.DataItem));
```



For the record here is the data class that is being used. Complicated!  


```csharp
namespace MagicStringBlog
{
    public class DataClass
    {
        public int DataItem { get; set; }
    }
}
```

It’s worth noting that I find the binding expression above too long as well, and have created an [Extension Method]({% post_url 2008-01-13-extension-methods %}) on controls that has the following signature.  


```csharp
public static void Bind<T>(this FrameworkElement el, DependencyProperty dp, Expression<Func<T, object>> ex)
```



Which cuts down the call time binding code to  

```csharp
textBox2.Bind<DataClass>(TextBox.TextProperty, d=>d.DataItem);
```

With this in place, even the Visual Studio rename tools will find the property and tidy up its name if your objects change, and it will be checked at compile time.  

Now I said earlier that this solution is not perfect, and I meant that. One problem is that all we are doing is turning a string literal into a runtime generated string. There is nothing that is going to check that the DataContext of the `TextBox` is actually of the type you are binding to, and you are going to suffer some performance hit (I haven’t run the numbers to see how much of one), but the safety this does bring I find useful. I didn’t move to C# only to need to search my code for string literals every time I want to rename a property.  
