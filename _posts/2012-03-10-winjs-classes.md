---
title: WinJS - Classes
layout: post
permalink: /2012/03/winjs-classes.html
tags: javascript win8 winjs winrt
id: tag:blogger.com,1999:blog-25631453.post-695965002839601279
---


In my last two posts on JavaScript for Windows 8 I looked at [scope](http://csainty.blogspot.com/2012/03/windows-8-winrt-and-winjs-scope.html) and [namespaces](http://csainty.blogspot.com/2012/03/winjs-namespaces.html). I pointed out that namespaces could be used to create “static” classes. I hasten to add they can be used for more, don’t make a hard link in your brain between namespaces and static classes.  

So what about regular classes. There are a couple of ways to define a class in JavaScript, a simple way is to return a hash from a factory method.  


````
function createPerson(name) {
    return {
        name: name,
        sayHello: function () {
            console.log("Hello " + this.name);
        }
    }
}
var sue = createPerson('sue');
var bill = createPerson('bill');
sue.sayHello();
bill.sayHello();
```  
  

We can shift name into a private scope by declaring a new variable inside our constructor which is captured by the resulting object.  


````
function createPerson(name) {
    var _name = name;
    return {
        sayHello: function () {
            console.log("Hello " + _name);
        }
    }
}
var sue = createPerson('sue');
var bill = createPerson('bill');
sue.sayHello();
bill.sayHello();
```  
  

However, for complex classes you intend to create a lot of, this method is generally not the suggested. Each instance is redefining the functions rather than simply pointing to an existing implementation in memory. This is where prototype inheritance comes in.  


````
var Person = function (name) {
    this.name = name;
};

Person.prototype.sayHello = function () {
    console.log("Hello " + this.name);
}
var sue = new Person('sue');
sue.sayHello();     // prints Hello sue
var bill = new Person('bill');
bill.sayHello();    // prints Hello bill

```  
  

With this setup you start with your constructor, you then extend it’s prototype. Finally instead of calling the constructor directly, you call it with the new keyword, which creates you a new instance.  

Note the capital P in Person, this is a convention to say this function is a class definition, so call it with new.  

But, we have lost the private scoping on the name property. To get it back, we need to define the property inside the constructor like we did above, but then expose it with a getter method so that the methods on the prototypes can get at it.  


````
var Person = (function() {
    var ctor = function(name) {
        var _name = name;
        this.get_name = function() { return _name; } // Wrap the private variable with a getter
    };

    ctor.prototype.sayHello = function () {
        console.log("Hello " + this.get_name());
    }

    return ctor;
})();

var sue = new Person('sue');
var bill = new Person('bill');
sue.sayHello();     // prints Hello sue
bill.sayHello();    // prints Hello bill

```  
  

It’s starting to get ugly isn’t it. Getting our reference to Person back out is quite awkward. The getter isn't much fun either.  

So what does WinJS bring to the table?  

There is a WinJS.Class namespace that contains a define method. It can be used to wrap up a big ugly class definition like that above into a simple method call that returns a class definition you can new up. It supports passing in your constructor, your instance methods/properties and your static methods/properties.  


````
// Person.js
(function () {
    var Person = WinJS.Class.define(function (name) {
        this.name = name;
    }, {
        sayHello: function () {
            console.log("Hello " + this.name);
        }
    }, {
        createPerson: function (name) {
            return new Person(name);
        }
    });

    WinJS.Namespace.define("MyApp", {
        Person: Person
    });
})();


// Page.js
var bill = new MyApp.Person("bill");    // Created with constructor
bill.sayHello(); // Print Hello bill

var jim = MyApp.Person.createPerson("jim"); // Created with static contructor
jim.sayHello(); // Prints Hello jim
```  
  

Much cleaner. Our class definition is sitting in the MyApp namespace ready to be created via new MyApp.Person('') and for good measure there is a static factory method MyApp.Person.createPerson('').  

But what about private variables? You can use the same technique as my example above with the getter. If you had a lot of them you might wrap them all onto a single private hash that only needed a single getter. What you might see a lot of people do is simply prefix them with an underscore and hope others follow the convention that properties starting with an underscore are not to be touched.  

Private scope aside, by combining WinJS.Namespace and WinJS.Class you have a really nice set of helpers to wrap up the task of correctly managing global scope and efficient class definitions. Neither is performing any magic, their source code is there for you to explore, they just get rid of some of the confusing boilerplate.  
