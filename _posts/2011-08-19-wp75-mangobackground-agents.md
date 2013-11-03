---
title: Wp7.5 Mango–Background Agents
layout: post
permalink: /2011/08/wp75-mangobackground-agents.html
tags: linqtosql gReadie wp7dev wp7 C# dotnet
id: tag:blogger.com,1999:blog-25631453.post-4232616768076069563
---


Late last year when I implemented the unread count Live Tile in [gReadie](http://www.quidsmobile.com/greadie/) I found myself stunned at just how complicated it was. It seemed to me that it would make a lot more sense if I could just whack a [LiveTileUpdater] attribute on a static method in a class and the phone would run that method occasionally.  
  
I was therefore delighted when details about Mango were released as this is basically what Microsoft implemented.  
  
Background Agents in Mango take the form of a separate assembly, which gets linked in your WMAppManifest.xml  
  

```csharp
<Tasks>
	<DefaultTask Name="_default" NavigationPage="Home.xaml" />
	<ExtendedTask Name="BackgroundTask">
		<BackgroundServiceAgent Specifier="ScheduledTaskAgent" Name="gReadie.BackgroundAgent" Source="gReadie.BackgroundAgent" Type="gReadie.BackgroundAgent.ScheduledAgent" />
	</ExtendedTask>
</Tasks>

```  
  
  
You should also place a reference to this library in your main app just to make sure the compiler includes it in your .xap file.  
  
You Background Agent library should contain a class based on ScheduledTaskAgent which performs the actual tasks.  
  

```csharp
public class ScheduledAgent : ScheduledTaskAgent
{
	protected override void OnInvoke(ScheduledTask task) {
		if (task is PeriodicTask) {
			// Do quick processing
		} else {
			// Do long processing
		}
		NotifyComplete();  // or Abort();
	}
}
```  
  
  
There are two types of Background Agents, [PeriodicTask](http://msdn.microsoft.com/en-us/library/microsoft.phone.scheduler.periodictask.aspx) and [ResourceIntensiveTask](http://msdn.microsoft.com/en-us/library/microsoft.phone.scheduler.resourceintensivetask.aspx). Your app is allowed one of each.  
  
Full details are available [here](http://msdn.microsoft.com/en-us/library/hh202942.aspx), but the important parts are that PeriodicTasks run around every 30minutes and can only run for 15 seconds before being killed. ResourceIntensiveTasks run when the phone is plugged in, on wi-fi and charged to over 90% battery, they can run for 10 minutes.  
  
Finally your task should call either NotifyComplete() or Abort() when it is finished. Abort() will unschedule the task until your app runs again, so you only call it if something is wrong that needs user attention, such as login credentials changing.  
  
Now that is the good part of the story, there is one more restriction on Background Agents. They are only allowed 5MB of memory, regardless of whether they are Periodic or ResourceIntensive. If you go over this limit the task will be killed.  
  
Making a useful Background Agent that stays under these limits is incredibly difficult. Especially when so many of the basic framework components (HttPWebRequest, LINQ-to-SQL, IsolatedStorageSettings) appear to have memory leaks.  
  
From my testing you will lose about half your memory by the time you reach line 1. Your first HttpWebRequest will eat up another roughly 20%, which it never gives back, though multiple requests will stay inside that initial chunk. IsolatedStorageSettings will do a similar thing.  
  
LINQ-to-SQL is a little more complex, recycling your DataContext and [Compiled Queries](http://csainty.blogspot.com/2011/08/wp75-mangocompiled-queries.html) will give some back, but recycling them too often will leak as well. So you need to find a nice balance.  
  
I suggest writing some code to monitor the memory usage between each job (assuming you have multiple to perform, say downloading multiple RSS feeds like gReadie does) and if you stray too high, then perform a garbage collection and recycle your LINQ-to-SQL and see how much you can get back. If it is not enough, then NotifyComplete() and try exit gracefully. It is not bullet-proof but in my testing it allows me to get more work done before running out of memory.  
  

```csharp
if (((double)DeviceStatus.ApplicationCurrentMemoryUsage / (double)DeviceStatus.ApplicationMemoryUsageLimit) * 100d > 97d) {
	// We are using too much memory, try clean a few things up
	if (_Ctx != null)
		_Ctx.Dispose();
	_Ctx = new gReadieModelContext(gReadieModelContext.ConnectionString);
	GC.Collect();
	if (((double)DeviceStatus.ApplicationCurrentMemoryUsage / (double)DeviceStatus.ApplicationMemoryUsageLimit) * 100d > 97d) {
		// We couldn't recover enough memory, so we are really running out, lets be nice and bail
		NotifyComplete();
		return;
	}
}

```  
  
  
