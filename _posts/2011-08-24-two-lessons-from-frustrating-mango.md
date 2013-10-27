---
title: Two lessons from a frustrating Mango submission
layout: post
permalink: /2011/08/two-lessons-from-frustrating-mango.html
tags: gReadie wp7dev wp7 C# dotnet
id: tag:blogger.com,1999:blog-25631453.post-6040999243873799172
---


I thought I would share two quick lessons today. Learnt while submitting the latest gReadie update to the marketplace.  
  
### Lesson 1
  
When updating an application in the marketplace, you can not remove supported languages.   
  
gReadie v1 has been translated into French and German (and unofficially Chinese) by enthusiastic users. gReadie v2 however has not yet had the same treatment.  
  
Even though gReadie v2 is a whole new application (File | New Project) it is being submitted as an update to gReadie v1 so that all current licenses are maintained.  
  
Therefore it must adhere to the rules for updates. One of which, I learnt today, is that you can not remove a language.  
  
With apologies to my French and German users, I had to rush together a mix of human translated (where I had the same text in v1) and Google translated values to get the app into the marketplace. I will do my best to reach out to the original translators and see if they are willing to provide an update for me.  
  
So keep this in mind if you are considering localising you application, you will need to do the same for all future versions.  
  
### Lesson 2
  
Be very careful what code is referenced by your Background Agent.  
  
There are a whole range of APIs that Background Agents can not access, and the code detection for this is fairly blunt. If you reference a class in a class library which has another class that calls the prohibited APIs, your application will fail during submission.  
  
To provide a more concrete example. gReadie is comprised of many separate class libraries. The two that caused me trouble were Quids.Infrastructure and gReadie.Library.  
  
Quids.Infrastructure is a bunch of helpers classes (for example code to string HTML tags from text) and some basic ViewModel and ViewPage classes that form the basis of the MVVM implementation used in gReadie.  
  
Even though my Background Agent just called into the string Extension Method that strips the HTML tags, the code that creates a PhoneApplicationPage was visible both in the ViewPage class and in the Silverlight Toolkit.  
  
gReadie.Library servers a similar role but more specific to gReadie, it has all the Google API interactions, User Settings and a bunch of other similar code. Included is the code that creates Live Tiles and the code that handles the ProgressIndicator and SystemTray. All of which is prohibited in Background Agents. So even though my agent was just getting at the API and Settings classes, all classes were interrogated and submission failed.  
  
So if you are building a Background Agent, and you want to share code between it and your main application be very careful about what else is in the shared libraries and be prepared to make UI and Non-UI shared libraries to deal with it.  
  