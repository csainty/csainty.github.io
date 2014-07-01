---
title: Veil - Getting Started Standalone
layout: post
permalink: /2014/07/veil-getting-started-standalone.html
tags: open-source veil dotnet
---

In addition to [integrating with Nancy]({% post_url 2014-06-29-veil-getting-started-nancy %}), Veil can be used by itself in any project for advanced text templating.

To get started you simply need to install one of the Veil parsers for the syntax you prefer.

* SuperSimple: `Install-Package Veil.SuperSimple`
* Handlebars: `Install-Package Veil.Handlebars`

<!-- more -->

### The simple case

Using Veil is very simple, it has a single entry point through `VeilEngine` and I've deliberately made the public surface of the API as small as I can manage.

There are two things to note :-

1. Veil uses a `TextReader` to read the template contents and a `TextWriter` to output the results. This is done for performance reasons. You can easily create a helper function that works for strings by using `StringReader` and `StringWriter`.
2. You need to tell `VeilEngine` which parser to use for your template. I don't love these keys, and I am open to alternate suggestions. Each parser registers a default key.
    * SuperSimple - `supersimple`
    * Handlebars - `handlebars`


````csharp
// First define your model
public class Person
{
    public string Name { get; set; }
}

// Then compile your template - preferably just once
var engine = new VeilEngine();
var template = engine.Compile<Person>("supersimple", new StringReader("Hello @Model.Name"));

// Now execute it
string result;
var model = new Person { Name = "Chris" };
using (var writer = new StringWriter()) {
    template(writer, model);
    result = writer.ToString();
}
````

### Using partials and master pages

If the template you are executing has a master page or a partial, then you need one more piece to make it all work.  
You will need to create an implementation of `IVeilContext` so Veil knows how to load these external templates.

````csharp
public class CustomVeilContext : IVeilContext
{
    public TextReader GetTemplateByName(string name, string parserKey)
    {
        return File.OpenText(name + ".sshtml");
    }
}

var engine = new VeilEngine(new CustomVeilContext());
````

### Summary
Veil is not just for HTML generation. It can generate any text content and its simple API makes it no problem to integrate in to any part of your application.


