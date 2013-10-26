---
title: Windows Vista
layout: post
permalink: /2007/02/windows-vista.html
tags: vista
---

I am now running Windows Vista Business on a shiny new PC (Office 2007 too!).
First impressions are all positive, visuals are clean and modern, IIS7 looks great, gadgets are surprisingly useful.
A couple of issues with VFP, which have mostly been blogged about elsewhere.
[Here](http://www.west-wind.com/wconnect/weblog/ShowEntry.blog?id=597) Rick Strahl is talking about the rendering issue with non-sizable forms. Which was easily fixed in our base class by doing an "if os(3) = '6'" check to see if we are running Vista, then fix as per the other posts (set the form sizeable then lock its width and height).
One issue I have not seen talked about though, was the Task Pane not working, it would report an error that it could not load the MSXMLDOM object.
To fix this we needed to extract the taskpane application from xsource.zip and update one of its constants, then recompile.
Find the contstant MSXML_PARSER and set it to "MSXML2.DOMDocument.6.0".
All round, a great operating system