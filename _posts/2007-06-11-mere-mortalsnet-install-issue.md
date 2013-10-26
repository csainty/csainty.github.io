---
title: Mere Mortals.NET Install Issue
layout: post
permalink: /2007/06/mere-mortalsnet-install-issue.html
tags: vista mmnet dotnet
---

ok well I have fixed my problem with not being able to create Mere Mortals.NET projects, so I will post about it here incase it catches anyone else out.
Here is my setup
Windows Vista Business
Visual Studio 2005 SP1 + Vista Update
Mere Mortals.NET v2.4

When you choose to create a MM project, an error is returned "project creation failed" with no further hints as to what went wrong.
When I first installed MM, I set the option for it to be available only to my user account in the install wizard. Since I am the only user of the laptop anyway.
After uninstalling MM and setting this option to Everyone on the re-install, all my problems went away.