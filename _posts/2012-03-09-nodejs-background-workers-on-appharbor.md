---
title: Node.js Background Workers on AppHarbor
layout: post
permalink: /2012/03/nodejs-background-workers-on-appharbor.html
tags: node appharbor csharp dotnet
guid: tag:blogger.com,1999:blog-25631453.post-2558486624826802936
tidied: true
---

Today AppHarbor [announced](http://blog.appharbor.com/2012/03/08/background-workers-in-beta) beta support for Background Workers, I have been eagerly awaiting this announcement as it is something I need all the time when hosting sites.  

<!-- more -->

Background Workers are simply `.exe` files that the server now knows to look for and run if you have a worker assigned to background tasks in your subscription. It should be noted that if you are using the free single worker plan, then you can not run both a web and background worker. You do have the option to run a web OR a background worker though. So you can still try these out on your free account.  
It should also be noted that trying to run two free accounts (one for web, one for background) that are servicing the same site is against the terms of service.  

As people who follow my blog probably know, I am right into Node at the moment. So straight away I set about getting a background worker up that can run node for me instead of C#.  

It was rather easy in the end, a simple wrapper that launches a node.exe process. You can grab the code from [https://github.com/csainty/NodeWorker](https://github.com/csainty/NodeWorker).  
You don’t even need Visual Studio installed or Windows, you push the source code to AppHarbor and they build it for you!  

The demo app I used for testing is also available, it simply logs entries off to [logentries](http://logentries.com/) (a free, one click install, addon from AppHarbor) so I can see if it is working. That code is at [https://github.com/csainty/NodeWorkerDemo](https://github.com/csainty/NodeWorkerDemo).  

So how does it work?  

First you need to clone down the project from GitHub.  

Then you need to add your node.js code into the app folder. The assumed entry point is `app/index.js`, but you can quickly point it elsewhere and add extra parameters to the node process if needed.   See [https://github.com/csainty/NodeWorkerDemo/blob/master/NodeWorkerRunner/Program.cs#L19](https://github.com/csainty/NodeWorkerDemo/blob/master/NodeWorkerRunner/Program.cs#L19)  

Finally make sure your `node_modules` folder is in the commit (AppHarbor does not run npm for you yet) and that all the files are being copied into the build folder and you are done.   If you are unsure, check the build output on AppHarbor for lines like the following  

```
_CopyOutOfDateSourceItemsToOutputDirectoryAlways:
  Creating directory "D:\temp\vxyr2fjf.bf2\output\app\node_modules\node-logentries".
  Copying file from "D:\temp\vxyr2fjf.bf2\input\NodeWorkerRunner\app\node_modules\node-logentries\package.json" to "D:\temp\vxyr2fjf.bf2\output\app\node_modules\node-logentries\package.json".
  Copying file from "D:\temp\vxyr2fjf.bf2\input\NodeWorkerRunner\app\node_modules\node-logentries\README.md" to "D:\temp\vxyr2fjf.bf2\output\app\node_modules\node-logentries\README.md".
  Copying file from "D:\temp\vxyr2fjf.bf2\input\NodeWorkerRunner\app\index.js" to "D:\temp\vxyr2fjf.bf2\output\app\index.js".
  Creating directory "D:\temp\vxyr2fjf.bf2\output\app\node_modules\node-logentries\lib".
  Copying file from "D:\temp\vxyr2fjf.bf2\input\NodeWorkerRunner\app\node_modules\node-logentries\lib\logentries.js" to "D:\temp\vxyr2fjf.bf2\output\app\node_modules\node-logentries\lib\logentries.js".
```  
  
Now push the whole project up to AppHarbor where it will be built and start running straight away.  

The lifetime of a background worker is controlled by the exit code from your application. The wrapper will pass the exit code from your node process back out to AppHarbor, putting node in control. There are currently two supported values

* Exit Code: 0 – Stop running the worker until the next deploy is performed
* Anything else – Start the worker again immediately   

If you take a look [here](https://github.com/csainty/NodeWorkerDemo/blob/master/NodeWorkerRunner/Program.cs#L40) you will see I chose to return 0 if there was a problem launching the node process. Meaning it will stop attempting to run your process. If this is not what you want, then you should change this value to be non-zero.  

Finally similar to iisnode, all your `<appSettings />` are added as environment variables when launching the node process which makes them available on process.env. Just like if you are hosting a node site on AppHarbor.  
