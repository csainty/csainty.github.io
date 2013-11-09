---
title: Windows 8, WinRT and WinJS - Scope
layout: post
permalink: /2012/03/windows-8-winrt-and-winjs-scope.html
tags: javascript win8 winjs winrt code52
guid: tag:blogger.com,1999:blog-25631453.post-5171271232130859416
tidied: true
---


This week at [Code52](http://code52.org/) we are taking on our first [Windows 8](http://code52.org/finances-windows8.html) app. Just to make it interesting we are doing it using the HTML / JS stack instead of C# / XAML.  

<!-- more -->

Before getting too far into WinJS (which is the general term I am going to use for referring to WinRT apps written in JS until someone tells me otherwise) it is a good idea to get a basic understanding of JavaScript as a language. It is a lot more in-depth than jQuery and the DOM would lead you to believe.  
  
The first thing you are going to confronted with upon creating a new project and opening on of the .js files is this structure.  
  

```javascript
﻿(function () {
  // some code
})();
```  

This is a self or immediately executing function. It defines a function, then execute it. Nonsense! I hear you scream.  
  
The reason for this structure is scope. JavaScript’s scope boundary is at the function level. It is not at the file level, or at the block level (like in C#). For example this code works.  
  

```javascript
if (true) {
	var x = 1;
}

console.log(x);	// Prints 1
```  
  
  
But if we define our variable in a self executing function. Then it does not.  
  

```javascript
(function() {
	var x = 1;
})();

console.log(x);	// throws "x" is not defined
```  

Functions scopes are stacked, and the outer most layer of that stack is called the global scope. So consider a large application with hundreds of js files. If each of these files did not use the self executing function trick to get a local scope, then they would all share the global scope. Now consider how likely it is that two files would share a variable name and cause difficult to track down bugs.  
  
It is interesting to note that Node actually wraps your modules in a function scope for you, so you get this safety out of the box.  
  
I’ll try keep these posts short and to a single topic, so that will do it for this one. Next I am going to take a look at the WinJS.Namespace helper and show you how to use it to safely get objects back out of your function scope and into accessible globally.  
  
