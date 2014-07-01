---
title: Veil - Getting Started With Nancy
layout: post
permalink: /2014/06/veil-getting-started-nancy.html
tags: open-source veil dotnet nancy
---

[Nancy](http://nancyfx.org/) is a great framework for building websites and it has been an important goal for [Veil](https://github.com/csainty/Veil) to integrate seamlessly in to your Nancy projects.

To get started you will first need to install Veil's view engine wrapper for Nancy.

`Install-Package Nancy.ViewEngines.Veil`

<!-- more -->

You also need to install one or more Veil parsers.

* SuperSimple: `Install-Package Veil.SuperSimple`
* Handlebars: `Install-Package Veil.Handlebars`

Nancy and Veil then work together to wire everything up with no other changes. Unlike razor there are no mysterious `web.config` changes to make.

Be default Veil will handle templates with following extensions.

* Veil.SuperSimple: `.vsshtml`, `.supersimple`
* Veil.Handlebars: `.haml`, `.handlebars`

For more details on the supported syntax of each parser check out their projects on GitHub.
[Veil.SuperSimple](https://github.com/csainty/Veil/tree/master/Src/Veil.SuperSimple)
[Veil.Handlebars](https://github.com/csainty/Veil/tree/master/Src/Veil.Handlebars)

### How to get Veil to handle .sshtml templates?
If you would like to use Veil to handle `.sshtml` templates that were previously being handled by Nancy's own SuperSimpleViewEngine then you need to unregister it in your bootstrapper.

````csharp
public class CustomBootstrapper : DefaultNancyBootstrapper
{
    protected override IEnumerable<Type> ViewEngines
    {
        get
        {
            return new[] { typeof(Nancy.ViewEngines.Veil.VeilViewEngine) };
        }
    }
}
````

### How to get Veil to handle arbitrary template extensions?
If you like to register an arbitrary file extension to a Veil parser, say `.html` to the Handlebars parser. You simply need to drop in an `ITemplateParserRegistration` which Veil will detect on startup.

````csharp
public class CustomParserRegistration : ITemplateParserRegistration
{
    public IEnumerable<string> Keys { get { return new[] { "html" }; } }

    public Func<ITemplateParser> ParserFactory
    {
        get { return () => new HandlebarsParser(); }
    }
}
````
