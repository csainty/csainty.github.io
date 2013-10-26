---
title: Announcing AppHarbify–Simplifying open source deployment
layout: post
permalink: /2012/05/announcing-appharbifysimplifying-open.html
tags: appharbify open-source nancy appharbor C#
---


Since finishing up my day job last week, I have had some time to dedicate to a project idea I had a few months ago. It is now time to formally announce it.  
 
Say hello to [AppHarbify](http://appharbify.com/)!  
 
AppHarbify aims to make deploying common software to [AppHarbor](https://appharbor.com/) even easier. So easy that it can be done by non-technical people or from mobile devices.  
 
The plan is to make as much .NET (or Node.js) open source software as possible compatible with the AppHarbor platform. Then bring it all into the one place and offer single step deployment. You can try it out right now with some of the projects I have used for testing [http://appharbify.com/Apps](http://appharbify.com/Apps), including JabbR and FunnelWeb.  
 
AppHarbify takes care of creating the application, installing the required add-ons, configuring application variables and deploying the code base. All you need to do is authenticate, via OAuth, with AppHarbor and choose which project to deploy.  
 
In addition to all this deployment goodness, there is a second side to AppHarbify. From the [Deployed Sites](http://appharbify.com/Sites) link you can see a list of all your deployed AppHarbor sites, regardless of whether AppHarbify deployed them, and add useful tools or features. At the moment support is limited to email based build notifications, but there will be plenty more.  
 
This is all made possible thanks to the [AppHarbor API](http://support.appharbor.com/kb/api).AppHarbify is open source and on GitHub [https://github.com/csainty/Apphbify](https://github.com/csainty/Apphbify). See the README for details on how to add new deployable software.It is written with [Nancy](http://nancyfx.org/) and of course hosted at AppHarbor.  
 
If you have any questions, comments or suggestions I am on twitter [@csainty](http://twitter.com/csainty) and usually somewhere in the [JabbR](http://jabbr.net/) rooms.  
  