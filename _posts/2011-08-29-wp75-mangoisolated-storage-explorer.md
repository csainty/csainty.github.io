---
title: WP7.5 Mango–Isolated Storage Explorer
layout: post
permalink: /2011/08/wp75-mangoisolated-storage-explorer.html
tags: wp7dev wp7 dotnet
---


One of the most useful new tools with the latest Windows Phone SDK is the Isolated Storage Explorer.  
  
It is a command line tool used for downloading and uploading the contents of an application’s Isolated Storage folders to either the Emulator or a Device.  
  
There are two times when this is invaluable.  
  
The first is when you are deploying a new version and you do not want to lose the data. Since day one I have been annoyed with the frequency that that deployment mechanism decides to delete the application and reinstall it. By using this tool I never need to worry about that again as I can just save a snapshot, deploy, load the snapshot back in.  
  
The second is when I find a bug with while using a retail copy of my app which I can not hook the debugger into. I can take a snapshot, load it into the emulator and debug.  
  
To speed the process along I have created four windows .bat files that to perform each of the tasks I need.  
  
 
````
"C:\Program Files (x86)\Microsoft SDKs\Windows Phone\v7.1\Tools\IsolatedStorageExplorerTool\ISETool.exe" ts de b8c6eab0-543c-4b55-be96-0b3da982df37 "C:\Users\chris_sainty\Desktop\IsoStore"



```  
  
  
To use these yourself you will need to adjust the path if you are not on a 64bit system, and you will need to replace the GUID with the value from your WMAppManifest file.  
  