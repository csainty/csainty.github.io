---
title: WP7.5 Mango–Compiled Queries
layout: post
permalink: /2011/08/wp75-mangocompiled-queries.html
tags: linqtosql gReadie wp7dev wp7 csharp dotnet
guid: tag:blogger.com,1999:blog-25631453.post-3157555770616581054
tidied: true
---


Over the last few weeks I have been doing a complete rewrite of [gReadie](http://www.quidsmobile.com/greadie-v2-beta/), my Google Reader client for Windows Phone 7.  
  
The original codebase for gReadie was really quite cluttered, and I wasn’t going to be able to take advantage of the new features Mango enables without pulling it all out and starting again.  
  
With most of the rewrite behind me now, It is time to start putting together a few blog posts discussing the new features I am using and lessons learnt along the way.  
 
<!-- more -->
 
One of the features I was most looking forward to in the 7.5 release of the phone is developer access to the underling SQL CE database. Access is provided through LINQ-to-SQL, which I have covered in [detail](http://blog.csainty.com/tag/linqtosql.html) previously. What I want to focus on today is improving the performance of your queries by compiling them and caching that result.  
  
This post assumes you already have your `DataContext` created and working queries, if you do not, then please start by reading some of the Microsoft tutorials.  
  
When you make a query with LINQ-to-SQL, the LINQ provider has to examine your LINQ expression and turn it into SQL, this process is done on every query. However, if you have a query you know you are going to call multiple times then you can run this process once, saving a parameterized result and avoid having to do this step on subsequent calls.  
  
You define and call a Compiled Query like so  
  

```csharp
public class Repository {
	private gReadieModelContext _Ctx = gReadieModelContext.Create(gReadieModelContext.ConnectionString);

	public Func<gReadieModelContext, IEnumerable<Folder>> Query_FoldersWithUnreadPosts = 
		CompiledQuery.Compile((gReadieModelContext db) => db.Folders.Where(d => d.UnreadCount != 0).AsEnumerable());
	
	public IEnumerable<Folder> GetFoldersWithUnreadPosts() {
		return 	Query_FoldersWithUnread(_Ctx);
	}
}

```  
  
  
The first step is to define a delegate that at the very least takes an instance of your `DataContext` as a parameter (though you can define more) and also defines the result type.  
  
You then use the `CompiledQuery.Compile()` method to provide the body for this delegate. The compilation does not happen until your first call, so don’t worry about setting up a lot of these.  
  
One thing to note is that you can only re-run a compiled query against the same `DataContext` instance it was compiled against. So you need to ensure they have the same lifespan, and that you are not needlessly recreating your `DataContext` if you want to run multiple queries.  
  
From my experience with Background Agents this method also uses less memory than rerunning the compilation each call.  
  
One final code snippet to show an example with a parameter  
  

```csharp
public class Repository {
	private gReadieModelContext _Ctx = gReadieModelContext.Create(gReadieModelContext.ConnectionString);

	public Func<gReadieModelContext, string, IEnumerable<Folder>> Query_FoldersContainingPost = 
		CompiledQuery.Compile((gReadieModelContext db, string postId) => db.Folders.Where(d => d.Posts.Any(e => e.PostId == postId)).AsEnumerable());
	
	public IEnumerable<Folder> GetFoldersContainingPost(string postId) {
		return 	Query_FoldersContainingPost(_Ctx, postId);
	}
}
```  
  
  
