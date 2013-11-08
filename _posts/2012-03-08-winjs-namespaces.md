---
title: WinJS - Namespaces
layout: post
permalink: /2012/03/winjs-namespaces.html
tags: javascript win8 winjs winrt code52
guid: tag:blogger.com,1999:blog-25631453.post-2332020649945843485
tidied: true
---


In my [last post]({% post_url 2012-03-07-windows-8-winrt-and-winjs-scope %}) I explained a little about scope in JavaScript and why you should (and the default templates do) wrap each of your files in a self executing function.  
  
One note about my code snippets. For simplicity I will be concatenating what would in a real application be multiple .js files into a single code snippet. I’ll use comments to show you where the files break.  
  
So let’s imagine you are creating a helper function to do something really useful, like add two numbers together.   
  

```javascript
// helpers.js
function add(x,y) {
	return x + y;
}

// page.js
console.log(add(1,1)); // prints 2

```  
  
  
We have defined this function in the global scope, let’s do the right thing and wrap a function scope around each file.  
  

```javascript
// helpers.js
(function() {
	function add(x,y) {
		return x + y;
	}
})();

// page.js
(function() {
	console.log(add(1,1)); // throws add is not defined
})();

```  
  
  
Now the two scopes can’t see each other or interact with each other. So how can we make our add function available to the rest of our application without just throwing it in the global scope.  
  
I present to you [Namespaces](http://msdn.microsoft.com/en-us/library/windows/apps/br212652.aspx).  
  
Namespaces are not a part of JavaScript, they are a helper library that Microsoft has provided in WinJS to better handle the problem of scope in JavaScript. In fact if you dig into the references on your project, you can actually find all the code for Namespaces in the base.js.  
  
Basically a namespace is an object that sits in the global scope. They can be nested and since you should be naming them much more uniquely than you would a regular variable the chances of conflicting with another library are slim.  
  
So let’s expose our add function through a namespace.  
  

```javascript
// helpers.js
(function() {
	WinJS.Namespace.define("MyApp.Functions", {
		add: function (x,y) {
			return x + y;
		}
	});
})();

// page.js
(function() {
	console.log(MyApp.Functions.add(1,1)); // prints 2
})();
```  
  
  
The WinJS.Namespace object is itself a namespace, defined in the base.js I mentioned above, which is why we are able to just call off to it. Once we define our own namespace we can then call it in any later code in the same way.  
  
Another interesting feature of Namespaces is that they are composed, so if you define the same Namespace twice instead of overwriting it you add to it.  
  
Suppose we now want to add a subtract method, but we want it to be in a separate file from our add method. A better example, which we are using at [Code52](http://code52.org/), suppose you have two implementations for your data access layer. You want them in the same namespace but in separate physical files.  
  

```javascript
// add.js
(function() {
	WinJS.Namespace.define("MyApp.Functions", {
		add: function (x,y) {
			return x + y;
		}
	});
})();

// subtract.js
(function() {
	WinJS.Namespace.define("MyApp.Functions", {
		subtract: function (x,y) {
			return x - y;
		}
	});
})();

// page.js
(function() {
	console.log(MyApp.Functions.add(1,1)); // prints 2
	console.log(MyApp.Functions.subtract(1,1)); // prints 0
})();
```  
  
  
This is super useful and kudos to Microsoft for making it work that way.  
  
One last note on namespaces. Remember that the context in which you are defining your Namespace is local to itself. JavaScript captures that scope when you define a function though. So you can define functions and variables that are only visible to the functions you are exposing on your namespace.  
  
To demonstrate this I will keep a running total of all the sum operations, and add a new function to return that total.  
  

```javascript
// helpers.js
(function() {
	var runningTotal = 0;
	
	function adjustTotal(x, y) {
		runningTotal += (x + y);
	}

	WinJS.Namespace.define("MyApp.Functions", {
		add: function (x,y) {
			adjustTotal(x, y);
			return x + y;
		},
		total: function () {
			return runningTotal;
		}
	});
})();

// page.js
(function() {
	console.log(MyApp.Functions.add(1,1)); // prints 2
	console.log(MyApp.Functions.add(1,1)); // prints 2
	console.log(MyApp.Functions.total()); // prints 4
})();
```  
  
  
The runningTotal variable and the adjustTotal method are both local to the helpers.js file and inaccessible outside of it. However, the add and total functions that we are exposing through the namespace have captured and retained the scope in which they were define and therefore still have access.  
  
So that is a quick introduction to namespaces. I have only shown exposing functions, but variables can be exposed as well. What I have shown here is most similar to a static class in C#.   
  

```csharp
namespace MyApp
{
    public static class Functions
    {
        private static int runningTotal = 0;

        private static void adjustTotal(int x, int y)
        {
            runningTotal += (x + y);
        }

        public static int add(int x, int y)
        {
            adjustTotal(x, y);
            return x + y;
        }

        public static int total()
        {
            return runningTotal;
        }
    }
}
```  
  
  
Next time I will look at WinJS.Class and how you can use it to create class definitions.  
  
