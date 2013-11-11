---
title: Extension Methods
layout: post
permalink: /2008/01/extension-methods.html
tags: C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-1568166695711012628
tidied: true
---

In this article I am going to look at Extension Methods. Although this is not a specific to LINQ post, Extension Methods are the compiler concept that LINQ was built on.  
  
The basic premise is to allow the developer to add functionality to any class they like without the need to subclass it or wrap it in a wrapper class. This is a great new technique because it allows you to continue using a class like String or DateTime and not need to remember to use MyString and MyDateTime or fall back on static helper classes.  

<!-- more -->
  
So how do we go about doing this?    I have recently been working on a tool that constantly needs to convert DateTime values from my local time zone here in Australia (GMT +10) to Central US time (GMT -6). Traditionally you would probably create a static helper class with a method that takes the time in one form and passes it back in the other, just to save you writing the conversion code in every place that uses it. Ignore the simplicity of the time conversion here, this is simply to keep the code short.  

```csharp
using System;

namespace Test_Application
{
    static class ExtensionMethods
    {
        public static DateTime LocalTimeToCentral(DateTime dt)
        {
            return dt.ToUniversalTime().AddHours(-6);
        }
    }
}
```

To call this in our code would look like this  


```csharp
DateTime dt = ExtensionMethods.LocalTimeToCentral(DateTime.Now);
Console.WriteLine("Central - " + dt.ToString());
```

It works, but it could be nicer. With a very simple tweak we can now attach this method to the DateTime class itself. Check this out.  



```csharp
using System;

namespace Test_Application
{
    static class ExtensionMethods
    {
        public static DateTime ToCentral(this DateTime dt)
        {
            return dt.ToUniversalTime().AddHours(-6);
        }
    }
}
```

By simply adding a new keyword "this" in front of the first parameter (I renamed the method simply to have a name consistent with it's new usage) we have created an Extension method. Now any DateTime class used where the Test_Application namespace is in use will have a ToCentral() method.

Note that the parameter with "this" does not convert into a parameter on the new method, it maps to the instance you are working on. Subsequent parameters will flow onto the method though. You will see this later.  

We can now use this method like this  

```csharp
DateTime dt = DateTime.Now.ToCentral();
Console.WriteLine("Central - " + dt.ToString());
```

Of course this comes with full intellisense and compile time type checking.

Extension Methods add a whole new level to what component developers can offer us, but you should not pass up opportunities to use them in your day to day coding.  

For one last code sample I am going to implement a very basic subset of the functionality of the Visual FoxPro StrExtract() method. I have talked about it before and how much I like it for basic string parsing. Without much work you could use Extension Methods to add an Extract() method to the string class in the .NET. Here is a start.  



```csharp
using System;

namespace Test_Application
{
    static class ExtensionMethods
    {
        public static string Extract(this string s, string start, string end)
        {
            string ret = "";
            int startPos = s.IndexOf(start) + start.Length;
            int endPos = s.IndexOf(end, startPos);
            if (startPos >= 0 && endPos >= 0)
            {
                ret = s.Substring(startPos, endPos - startPos);
            }
            return ret;
        }
    }
}
```

And to call it.  


```csharp
string s = "<text><first>First Test</first><second>Second Test</second></text>";
Console.WriteLine(s.Extract("<first>", "</first>")); // First Test
Console.WriteLine(s.Extract("<second>", "</second>")); // Second Test
```

Fantastic!  
