---
title: Creating an FLL
layout: post
permalink: /2007/04/creating-fll.html
tags: vfp
guid: tag:blogger.com,1999:blog-25631453.post-3099640183909124277
---

I have been playing around in the last week or so with creating an FLL.
I came across a set of C++ classes called [CLucene](http://clucene.sourceforge.net/index.php/Main_Page) that do indexing and searching of text.
This is something I have long had an interest in and often mess around with in VFP.
Rather than attempting to port the C++ classes into VFP, I decided to try wrap them in an FLL and call them that way.
Having never programmed in C/C++ before there was a fun learning curve involved in just getting the code to behave let alone using the API of CLucene and Fox to pull data from a table into the CLucene index and then search it.
I have however managed to do just that, and it is very cool. I will look to develop this further overtime, and if it is promising enough use it in some of our production apps.
How great are FLLs!
