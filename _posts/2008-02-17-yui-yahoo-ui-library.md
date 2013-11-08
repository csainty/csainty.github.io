---
title: YUI - Yahoo! UI Library
layout: post
permalink: /2008/02/yui-yahoo-ui-library.html
tags: YUI design
guid: tag:blogger.com,1999:blog-25631453.post-2978204529359187613
---


I am spending the weekend getting to know a bit more about the Yahoo! User Interface Library.   You can find more details yourself here [http://developer.yahoo.com/yui/](http://developer.yahoo.com/yui/)  
  
They do a good summary on their site, so let me start by simply quoting Yahoo!  
     
The Yahoo! User Interface (YUI) Library is a set of utilities and controls, written in JavaScript, for building richly interactive web applications using techniques such as DOM scripting, DHTML and AJAX. The YUI Library also includes several core CSS resources. All components in the YUI Library have been released as open source under a [BSD license](http://developer.yahoo.com/license.html) and are free for all uses.  
   
There are a couple of really neat things about this library that I will quickly run through to see if I can grab your attention.  
  
First and foremost for any HTML/CSS developers out there, YUI provides 3 core CSS files: Reset, Core and Fonts. These are fundamentally important to anyone working on websites in my opinion.    Reset removes all in-built styling, from every browser. Right down to removing the bullets from <li> and the bold from <em>. It provides an utterly blank canvas for you to start styling from.    Core then applies the usual formatting you would expect each tag to have, only it does so in a way that is consistent between all browsers. As any web developer should know, not all tags look the same between different browsers.    Fonts will apply a standard set of font-families across al browsers and platforms to give you the best chance of getting the font you are after.  
  
If you look at nothing else in the YUI library, you should still check out the Reset and Base CSS files. They are applicable to every single website you will create and will remove a lot of headaches with cross browser interfaces.  
  
Other CSS goodies include a set of tools for creating consistent Grid layouts (2-column, 3-column, 4-column etc) and a default skin for their UI components. I haven't gone looking yet, but I am sure there are more skins floating around the net, or you can create your own.  
  
Next we have a large collection of javascript files that work together to provides layers of useful support from basic helper functions, AJAX calls, simple UI controls all the way up to DataTables, ImageLoaders and all sorts of things.   This library is so rich you are better off looking through their examples than having me try explain them to you. The key here is that everything is built and tested to work across a wide range of browsers and platforms without you needing to know all the CSS hacks to make it work. Anyone looking to build a modern UI on a website would be served well to see what these guys are up to.  
  
The third feature of YUI that I find quite interesting is that Yahoo! offers free hosting of all the JS and CSS files used. Including past versions. In fact they give you the links (and more importantly permission) to link into the exact same data farm that serves these file to their own production websites. Needless to say this reduces bandwidth on your own site, and comes with some good caching and compression at their end. If you can trust an external source to host a couple of your files, this is worth taking a look at.  
  
That's it for now, I am still learning my way through the library myself. If I come across any cool tips of features I will be sure to pop up a post later. In the end I may use nothing but the Reset and Base CSS files from the library, time will tell.  
  
