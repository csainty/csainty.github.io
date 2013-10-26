---
title: Using ServiceStack.Text for JSON processing on Windows Phone 7
layout: post
permalink: /2011/10/using-servicestacktext-for-json.html
tags: gReadie wp7dev wp7 C# dotnet
---


I recently decided to switch gReadie away from JSON.Net to ServiceStack.Text for it’s heavy JSON processing of the Google Reader API.  
  
While there was no WP7 dll available in the NuGet package the source was all on GitHub, so using my recently learned Git skills, I forked the project and added my own project file targeted at WP7.  
  
It was then just a matter of visiting the various #if XBOX and #if SILVERLIGHT directives in the source and adding WINDOWS_PHONE as appropriate to enable and disable code for the platform.  
  
There are some differences between the SILVERLIGHT and WINDOWS_PHONE versions, as the project looks to target an older Silverlight implementation at the moment, which was turning off some of the performance gains that came from caching LINQ expression trees. So with those all enabled again the code compiles, is faster than JSON.Net for my use case and is now live in the latest version of gReadie.  
  
All my code changes have been pushed back up to my fork and are available at [https://github.com/csainty/ServiceStack.Text/tree/wp7](https://github.com/csainty/ServiceStack.Text/tree/wp7)  
  
I am yet to send a pull request back to the primary project, so for now you will need to grab my source and compile it yourself if you want to use it.  
  