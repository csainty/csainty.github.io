---
title: Further thoughts on NodeJS desktop applications
layout: post
permalink: /2012/01/further-thoughts-on-nodejs-desktop.html
tags: javascript node node-webkit
id: tag:blogger.com,1999:blog-25631453.post-5814689327629067619
tidied: true
---

I have been working on a more complete demo of creating a desktop app with NodeJS.  
 
This one will use a full UI ([KendoUI](http://www.kendoui.com/)) and a Sqlite database to create a basic CRUD style app based on the Northwind dataset. Someone really needs to put together another (and actually well designed) standard database that people can use for apps like this.  
 
While putting this together I have been considering reasons why you might actually write an application like this.  
 
Something that dawned on me is that I am only really using Node in a very thin data layer. My Views and View Models are all standard HTML/JS. Which means the only thing I would need to do to switch this application I am writing to being on the web would be to replace the data layer which is currently using Node to access Sqlite with one that goes across the network to a REST service.  
 
This means I am effectively writing an identical web and desktop app at the same time. Which opens up some interesting offline capabilities.

Add a build time dependency injector to switch between the Node and REST data layers, and a synchronisation mechanism (assuming you want the user to be able to use either) and you have the web and desktop versions of your app running the exact same codebase.  
 
Now that is pretty darn interesting.  
  
