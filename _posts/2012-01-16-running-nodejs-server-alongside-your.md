---
title: Running a NodeJS server alongside your NodeJS desktop app
layout: post
permalink: /2012/01/running-nodejs-server-alongside-your.html
tags: javascript node node-webkit
---


The node-webkit project added a new feature yesterday, one which I requested. So I feel I should put up a quick post about it and why I think it could be useful.  
 
The change was simple enough, giving you the ability to pass a callback to node-webkit that is called when the application is closing.  
 
The primary reason I wanted this was to allow you to create, and then clean up, a local web server within the lifetime of your application.  
 
It was previously possible to create the server, but when you closed the app, the process would stay open with the webserver waiting for requests.  
 
The callback looks something like this.  
 

````
var nwebkit = require('node-webkit'),
	http = require('http');

var server = http.createServer(function(request, response) {
	response.writeHead(200, { 'Content-Type': 'text/plain'});
	response.end('Hello');
}).listen(3000, '127.0.0.1');

nwebkit.init({
	'url' : 'views/index.html',
	'width' : 800,
	'height' : 600,
	'onclose': function() {
		server.close();
	}
});

```  
  
 
So why exactly is this useful? Well I have a couple of uses in mind.  
  Some libraries and UI controls have only been coded to fetch their data with an HTTP request. This gives you a simple way of using such a library or control. You just point it at the local server and handle the request. If you did all data access across the HTTP layer, then you remove one more piece of uncommon code between a web and desktop application, now the difference between the two is just the URL it is pointing at. It allows you to pre-process previously static files. This means you could compile your LESS or CoffeeScript files as they are being served. It also means you could serve HTML from a ViewEngine such as [Jade](http://jade-lang.com/) instead of from static files on disk.  