---
title: A RavenDb profiling plugin for Glimpse
layout: post
permalink: /2011/07/ravendb-profiling-plugin-for-glimpse.html
tags: ravendb glimpse mvc asp.net C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-5559930358189176459
tidied: true
---


Today my post is to announce the release of a small plugin I have been working on over the last few days. It is a plugin for the [Glimpse](http://getglimpse.com/) client side debug tool that integrates profiling information from [RavenDb](http://www.ravendb.net/). 

<!-- more -->
  
The plugin is available on NuGet - [http://nuget.org/List/Packages/Glimpse.RavenDb](http://nuget.org/List/Packages/Glimpse.RavenDb)  
  
The source is hosted on GitHub - [https://github.com/csainty/Glimpse.RavenDb](https://github.com/csainty/Glimpse.RavenDb)  
  
Finally there are installation instructions - [https://github.com/csainty/Glimpse.RavenDb/wiki/How-to-use](https://github.com/csainty/Glimpse.RavenDb/wiki/How-to-use)  
  
Links out of the way, how about a screenshot or two?  
  
![Glimpse.RavenDb.1](/images/1382874051986.png)  
  
![Glimpse.RavenDb.2](/images/1382874051987.png)  
    
As you can see, the plugin adds a new tab to the Glimpse UI called RavenDb. On this tab you get information about the servers and sessions involved in the current request. You also get a list of the queries made against your RavenDb instances including the actual documents sent across the wire that you can drill into. It is really quite cool, and the Glimpse team have done a fantastic job creating a framework that is very simple to extend.  
  
The profiling tools in RavenDb are still young, and as ayende adds functionality (the current unstable builds include timing information currently missing in the stable release) I will update the plugin to bring all that goodness to the UI.  
  
