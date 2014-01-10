---
title: Quick Tip - Windows Azure Mobile Services and Xamarin
layout: post
permalink: /2013/12/quick-tip-azure-mobile-services-xamarin.html
tags: dotnet azure xamarin quicktip
---

Having trouble adding Azure Mobile Services to your Xamarin project?  
Seeing the following compiler error?

> Warning: The referenced library 'Microsoft.WindowsAzure.Mobile.Ext.dll' is not used from any code, skipping extraction of content resources. (FriendsFromWorkMobile)

How about this exception?

> A Windows Azure Mobile Services assembly for the current platform was not found. Ensure that the current project references both Microsoft.WindowsAzure.Mobile and the following platform-specific assembly: Microsoft.WindowsAzure.Mobile.Ext.

Don't despair, you missed one simple line when skimming the Getting Started tutorials.

````csharp
CurrentPlatform.Init();
````

Rejoice!
