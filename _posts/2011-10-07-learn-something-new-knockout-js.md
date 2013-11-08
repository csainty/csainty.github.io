---
title: Learn Something New&#58; Knockout JS
layout: post
permalink: /2011/10/learn-something-new-knockout-js.html
tags: javascript mvc asp.net learn-something-new knockout
id: tag:blogger.com,1999:blog-25631453.post-1473986324507487925
tidied: true
---

First in my _“Learn Something New”_ series is [Knockout](http://knockoutjs.com/), a javascript MVVM framework.

Knockout is beautifully simplistic. You define a ViewModel, bind it to your UI, and away it goes keeping the two in sync. It really is beautiful stuff for a javascript heavy UI.

To learn my way with Knockout, I decided to create a basic twitter search client in javascript. The twitter search API is a great resource for quickly adding data to a “hello world”-esque application. I am bound to revisit it later.

Now let’s get a few more details out of the way, you can see the site up and running at [http://twitches.apphb.com/](http://twitches.apphb.com/) and you can get the source code at [https://github.com/csainty/Twitches](https://github.com/csainty/Twitches)

The interesting code lives in the only [View](https://github.com/csainty/Twitches/blob/master/Twitches/Views/Home/Index.cshtml) and the [Javascript](https://github.com/csainty/Twitches/blob/master/Twitches/Scripts/Site.js).
The page basically consists of a textbox to enter a search term, a button to run the search and a UL that is bound to the results. There is some other fluff in there, but this is the core functionality.

Here is a trimmed down version of the javascript to highlight the main features.


```javascript
var viewModel = {
	searchTerm: ko.observable(""),
	tweets: ko.observableArray([]),
	search: searchTwitter
}
ko.applyBindings(viewModel);

function searchTwitter() {
	$.ajax({
		url: 'http://search.twitter.com/search.json',
		dataType: 'jsonp',
		data: {
			q: viewModel.searchTerm(),
			result_type: 'recent',
			rpp: 20,
			lang: 'en'
		},
		success: handleTwitterResponse
	});
}

function handleTwitterResponse(result) {
	for (var index = result.results.length - 1; index >= 0; index--) {
		viewModel.tweets.unshift(result.results[index]);
	}
}
```  

So we define our `viewModel`, give it an observable value for the search string, an observable array for the results and a function to perform the search.
We apply these bindings and that is it for the javascript. The actual binding to the UI happens in the UI, using HTML5 data attributes.


```markup
<ul data-bind="template: { name : 'tweetTemplate', foreach: tweets }"></ul>

<input type="text" placeholder="search..." data-bind="value: searchTerm" />

<button data-bind="click: search">Search</button>

<script type="text/x-jquery-tmpl" id="tweetTemplate">
    <li class="tweet">
	<img src="${profile_image_url}" alt="${from_user}" />
		<p class="content">
			${from_user}: ${text}<br />
		</p>
		<p class="datetime">${created_at}</p>
		<div class="ui-helper-clearfix"></div>
    </li>
</script>
```  

Here are the key elements from the HTML, as you can see we bind the UI with a jQuery.tmpl template, and wire up the value for the textbox and the click event for the button.
It really is as simple as that.

I highly recommend the [tutorials](http://learn.knockoutjs.com/) at the Knockout website, they have created a wonderful live tutorial that takes you through each step of the process.


#### Tools and Services Used

[Knockout JS](http://knockoutjs.com/)  
[ASP.NET MVC / C#](http://www.asp.net/mvc)  
[Combres](http://combres.codeplex.com/) (Javascript / CSS minifier and combiner)  
[AppHarbor](https://appharbor.com/)  
[jQuery](http://jquery.com/)  
[Twitter API](https://dev.twitter.com/docs)

