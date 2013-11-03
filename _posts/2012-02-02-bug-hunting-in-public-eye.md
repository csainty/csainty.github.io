---
title: Bug hunting in the public eye
layout: post
permalink: /2012/02/bug-hunting-in-public-eye.html
tags: ravendb
id: tag:blogger.com,1999:blog-25631453.post-2591487606735349656
---


A few days ago, ayende put up a post showing a bug that had been found in RavenDb that was causing the profiling tools to enter an infinite loop.  

[http://ayende.com/blog/152738/bug-hunt-what-made-this-blog-slow](http://ayende.com/blog/152738/bug-hunt-what-made-this-blog-slow)  

This was followed by a post about how this bug had come into being and survived so long.  

[http://ayende.com/blog/153825/ask-ayende-what-about-the-qa-env](http://ayende.com/blog/153825/ask-ayende-what-about-the-qa-env)  

So confession time, that’s my bug. I contributed the early code for the profiler.  

So since then I have been trying to work out how I missed it. Was I really so oblivious to what was going on while writing that code?  

Second to that, how had it sat in production on ayende’s blog for 6 months or so without being noticed?  

I am glad to say I have an explanation for both, which I will share now.  

First some background on how the profiling actually works.  

When you attach your DocumentStore to the profile, the following code is run  

```csharp
public void AddStore(IDocumentStore store)
{
	var documentStore = store as DocumentStore;
	if (documentStore == null)
		return;

	if (documentStore.WasDisposed)
		return;

	object _;
	documentStore.AfterDispose += (sender, args) => stores.TryRemove(documentStore, out _);
	documentStore.SessionCreatedInternal += OnSessionCreated;

	stores.TryAdd(documentStore, null);
}

private void OnSessionCreated(InMemoryDocumentSessionOperations operations)
{
	RavenProfiler.ContextualSessionList.Add(operations.Id);
	if (HttpContext.Current == null)
		return;
	
	try
	{
		HttpContext.Current.Response.AddHeader("X-RavenDb-Profiling-Id", operations.Id.ToString());
	}
	catch (HttpException)
	{
		// headers were already written, nothing much that we can do here, ignoring
	}
}
```  
  
Basically we attach to the OnSessionCreated event and stuff a header into the response with the session id.  

This is very important, and the key to why this bug was missed. So I will say it again, the X-RavenDb-Profiling-Id header is only added to your response if you actually open a session.  

So lets look at that JavaScript again.  

```csharp
$('body').ajaxComplete(function (event, xhrRequest, ajaxOptions) {
	var id = xhrRequest.getResponseHeader('X-RavenDb-Profiling-Id');
	if (id)
		fetchResults(id.split(', '));
});

var fetchResults = function (id) {
	$.get(options.url, { id: id }, function (obj) {
		if (obj)
			addResult(obj);
	}, 'json');
};
```  
  
It only calls back to the server when it gets an AJAX response that has the header set. So if you make an AJAX request to your server for data that does not come from RavenDb, the profiler will not pay any attention to that request.  

The request to get the profiling results does not need a session, and in all my development it did not create a session. So it never set the header. So it never entered a loop.  

So that explained to me how I had missed the bug, the way I deal with session management (creating and disposing of them only as needed) simply does not trigger the bug.  

So with my conscience cleared, I moved on to the second problem. Just because I handle my session this way, clearly RacoonBlog does not, surely that bug hasn’t been there since ayende turned on the profiler for his blog.  

Well let me present a commit to the RacoonBlog source from the very end of December.  

[https://github.com/ayende/RaccoonBlog/commit/b284efae61108af991221d948eb891e1310bc64b](https://github.com/ayende/RaccoonBlog/commit/b284efae61108af991221d948eb891e1310bc64b)  

In this commit, Racoon switched from creating sessions only as they are needed (my way of handling them) to creating the session in the BeginRequest event of *every* request. So even requests that don’t use the session still create one. Which obviously adds the profiling header and tells the JavaScript “this request hit RavenDb, so you should fetch it’s profiling results”.  

So until that commit was pushed live RacoonBlog, like my own sites, simply did not trigger this bug, it was sitting there dormant just waiting for someone to take a different approach to session management.  

So there we have it. I really don’t feel so bad about it now.  

To a certain degree the JavaScript was actually correct. It noticed an AJAX request that said it had profiling information attached and it fetched that information. The fallacy in this argument though is that the JavaScript also has enough information available (the request URL) to know that it is being lied to. It should have used that information to avoid the trap that was laid for it. So it’s still a bug for all that I wish it were not.  
