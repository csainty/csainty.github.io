---
title: Learn Something New&#58; Node
layout: post
permalink: /2011/10/learn-something-new-node.html
tags: javascript node learn something new heroku
id: tag:blogger.com,1999:blog-25631453.post-1389607301571265426
---


[Node](http://nodejs.org/) seems to be everywhere at the moment. Long on my list of things to take a look at, I finally took the time to sit down with it yesterday and get it up and running and get a feel for what it does.  
  
In the process I also took my first look at [Heroku](http://www.heroku.com/), which is the cloud hosting platform for Ruby, Node, Java etc.  that [AppHarbor](https://appharbor.com/) borrows heavily from in the .NET world.  
  
As always, my code is on [GitHub](https://github.com/csainty/Node.Test), and the site is live on [Heroku](http://blooming-mist-4131.herokuapp.com/). This sample is literally a Hello World, with so many moving parts, I really wanted to just focus on the raw details of getting Node running first in a Linux VM, then on Windows, then on Heroku.  
  
Both Node and Heroku provide great instructions to get everything up and running, so they should be your first port of call.  
  
[https://github.com/joyent/node/wiki/Installation](https://github.com/joyent/node/wiki/Installation)  
  
[http://devcenter.heroku.com/articles/node-js](http://devcenter.heroku.com/articles/node-js)  
  
   
  
With how easy Node is to get running on Windows now, there really is no excuse not to give it a go.  
  
Simply download the stand-alone node.exe from [here](http://nodejs.org/dist/v0.5.9/node.exe).  
  
Put it in a folder, and create a HelloWorld.js file with the following content.  
  

```clike
var http = require('http');

http.createServer(function(request, response) {
	response.statusCode = 200;
	response.setHeader('Content-Type', 'text/plain');
	response.end('Hello World');
}).listen(8080);
```  
  
  
Then run node HelloWorld.js and hit [http://localhost:8080/](http://localhost:8080/) in your browser.  
  
At it’s heart, Node is about IO and sockets. It is not specifically about the web, people have just seen how useful it can be for web development.  
  
Before you get too far into it, you are likely to want to start plugging in some other packages, such as a routing framework to manage your requests and a view engine to render your HTML>   
  
This is where the Node Package Manager ([npm](http://npmjs.org/)) comes in. The node install instructions linked above explain how to install this on windows, which has been seamless for me so far.  
  
You probably want to look at [express](http://expressjs.com/) for the general framework roles and [jade](http://jade-lang.com/) for a view engine.  
  
Another recent blog post I will call out to take a look at is [Jon Galloway’s](http://weblogs.asp.net/jgalloway/archive/2011/10/26/using-node-js-in-an-asp-net-mvc-application-with-iisnode.aspx) effort today which includes a lot of detail and goes into hosting the node.exe process inside IIS on windows servers.  
  
I had a real sense of joy when I fired up Node and started fiddling around. I am fairly comfortable in javascript, and going back into a straight text editor to write my code was a bit like stepping back in time to my teenage years hacking away in qbasic. While my initial investigations were only skin deep, I definitely see myself taking a much deeper look very soon.  
  