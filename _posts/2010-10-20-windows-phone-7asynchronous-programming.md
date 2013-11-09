---
title: Windows Phone 7–Asynchronous Programming
layout: post
permalink: /2010/10/windows-phone-7asynchronous-programming.html
tags: wp7dev wp7 C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-6088405555173488592
tidied: true
---

  
I am going to start putting together some posts on my experience writing our first Windows Phone 7 application, [gReadie](http://www.quidsmobile.com/gReadie/).

<!-- more -->
  
One thing that will strike you quickly if you go to make an app that communicates over the internet is that everything has to be done asynchronously. While this is bound to annoy at first, it is actually a good design decision by the development team because it forces the developer to keep the UI responsive. Sadly there is at least one instance where they broke their own rules but we will get to that another time, I will just say watch out for the Image control.  
  
My preferred way of handling asynchronous programing is with a callback structure that uses delegates/lambdas. You could also use events but I find most of the memory leaks I create in applications are to do with events and not releasing subscriptions. Luckily for us we now have lambdas that make callbacks a piece of cake to write, you just need to watch out for a few gotchas. If you prefer delegates to lambdas, then the second point here will not apply to you, but the first will still catch the very novice.  
  
I am going to put together an application that simply lists the top 10 trending topics on twitter. It is a simple easy to access api that will serve our purposes well.  
  
You can call up the api right now in your browser [http://api.twitter.com/1/trends.json](http://api.twitter.com/1/trends.json)  
  
So we start with a new Windows Phone Pivot application, It comes prepopulated with a list control and a nice ViewModel structure that is a good base to work from.  
  
The first thing you will want to do is add a reference to `System.Servicemodel.Web` and another to `System.Runtime.Serialization`. These dlls contain the classes we need for parsing the JSON we get back from twitter. Next you will want to go into the `LoadData` method on the `ViewModels\MainViewModel.cs` class and comment out (or remove) all the sample data.  
  
Now we have an app that will load up and display nothing. Perfect.  
  
To parse the JSON we are going to need some classes to parse it into, and here they are.  
  
```csharp
[System.Runtime.Serialization.DataContract]
public class TrendsResult
{
    [System.Runtime.Serialization.DataMember(Name = "as_of")]
    public string AsOf { get; set; }

    [System.Runtime.Serialization.DataMember(Name = "trends")]
    public Trend[] Trends { get; set; }
}
```


```csharp
[System.Runtime.Serialization.DataContract]
public class Trend
{
    [System.Runtime.Serialization.DataMember(Name = "url")]
    public string Url { get; set; }

    [System.Runtime.Serialization.DataMember(Name = "name")]
    public string Name { get; set; }
}
```

Put these where you like in the project (I use a JSON subfolder) and add using statements etc to your preferences. I am not going into details about JSON in this post so that is all you get for now sorry.  


With these in place we can now fill out our LoadData method and actually perform the request and parse the results. Filling out the Items collection already provided in the project template.  


```csharp
public void LoadData() {
    HttpWebRequest request = HttpWebRequest.CreateHttp("http://api.twitter.com/1/trends.json");
    request.BeginGetResponse(result => {
        HttpWebResponse response = (HttpWebResponse)((HttpWebRequest)result.AsyncState).EndGetResponse(result);
        DataContractJsonSerializer s = new DataContractJsonSerializer(typeof(TrendsResult));
        TrendsResult trends = (TrendsResult)s.ReadObject(response.GetResponseStream());

        foreach (Trend trend in trends.Trends) {
            this.Items.Add(new ItemViewModel { LineOne = trend.Name, LineTwo = trend.Url });
        }
    }, request);

    this.IsDataLoaded = true;
}
```

Now this code seems quite reasonable, assuming of course that you have learnt lambdas and can read it. We make a request, when it is done we pass the result text into the deserializer to create the objects we built above and then process these into the ViewModel.  

If you run it though, it will crash with the error “Invalid cross thread access” and this is the first lesson about callbacks. They do not fire on the UI thread and therefore they can not change the UI. But you may notice the callback doesn’t actually change the UI. It just adds an item to a collection. But because this collection it bound to the UI, when it changes it triggers events that change the UI.  

So the first thing we need to do is move the call that adds the item to the collection onto the UI thread. Luckily this is easy enough and involves another lambda!

We simply change the content of the foreach loop to be  

```csharp
((App)App.Current).RootFrame.Dispatcher.BeginInvoke(() => {
    this.Items.Add(new ItemViewModel { LineOne = trend.Name, LineTwo = trend.Url });
});
```

The key here is getting a handle on the `Dispatcher`. This is the class that controls the UI thread, there are a few ways you can get it, every page has a Dispatcher property, or if have `Microsoft.Phone.Reactive.dll` referenced then you can use the `Scheduler` class (my preferred way), or you can get at the App.RootFrame that is the parent UI object in the application which is what I have done above.  

From the Dispatcher you can pass in an Action (callback/delegate/lambda.. choose your own terminology) for the UI thread to execute.  

Now if you run this version up, you will notice that it works. Except hang on, all the trends are the same. Don’t worry you didn’t mess up the Json parsing, though this would be the first thought of many and they could waste a lot of time looking in the wrong direction.  

This brings us to the second lesson about callbacks and it goes to the way lambdas are actually compiled. Notice in line 2 above I reference trend.Name and trend.Url, but the trend object is not actually created inside the lambda, so think for a second about how it is in scope. If you took the content of the Lambda and turned it into a method/delegate (which is what the compiler does) that was called then it becomes clear that we have some trickery going on behind the scenes.  


```csharp
((App)App.Current).RootFrame.Dispatcher.BeginInvoke(DoItemAdd);
private void DoItemAdd() {
    this.Items.Add(new ItemViewModel { LineOne = trend.Name, LineTwo = trend.Url });
}
```

What the compiler does is add a field to the class, which it sets before the call and uses inside the method. So it would look something like this, you can see it in reflector if you like  


```csharp
private Trend _Compiler_Trend;

public void LoadData() {
    ...
    _Compiler_Trend = trend;
    ((App)App.Current).RootFrame.Dispatcher.BeginInvoke(DoItemAdd);
    ...
}

private void DoItemAdd() {
    this.Items.Add(new ItemViewModel { LineOne = _Compiler_Trend.Name, LineTwo = _Compiler_Trend.Url });
}
```

Now it should be clearer what is happening here. `BeginInvoke` is asynchronous so our `foreach` loop keeps updating the `_Compiler_Trend` without waiting for the last call to `DoItemAdd` to be finished with it. Therefore when it does get around to running the `DoItemAdd` calls the field is in an unknown state.  

Luckily we also have a solution to this problem. The `BeginInvoke` call can also take an `Action<T>` and a parameter of generic type `T` to pass in when calling the code.  

So we can rewrite the method like this  


```csharp
public void LoadData() {
    HttpWebRequest request = HttpWebRequest.CreateHttp("http://api.twitter.com/1/trends.json");
    request.BeginGetResponse(result => {
        HttpWebResponse response = (HttpWebResponse)((HttpWebRequest)result.AsyncState).EndGetResponse(result);
        DataContractJsonSerializer s = new DataContractJsonSerializer(typeof(TrendsResult));
        TrendsResult trends = (TrendsResult)s.ReadObject(response.GetResponseStream());

        foreach (Trend trend in trends.Trends) {
            ((App)App.Current).RootFrame.Dispatcher.BeginInvoke(new Action<ItemViewModel>(item => {
                this.Items.Add(item);
            }), new ItemViewModel { LineOne = trend.Name, LineTwo = trend.Url });
        }
    }, request);

    this.IsDataLoaded = true;
}
```

Only lines 8,9 and 10 are different. Now we are creating a lambda that takes a parameter of type `ItemViewModel`, adds that passed item into the collection and we give the dispatcher the item to pass in. If we run this code it works!  

If we pulled apart this code to see it like the compiler does it would look more like this, and I should note you can write your code this way if lambdas bend your mind that bit too much, but I personally find them much easier to read and manage.  


```csharp
public void LoadData() {
    HttpWebRequest request = HttpWebRequest.CreateHttp("http://api.twitter.com/1/trends.json");
    request.BeginGetResponse(result => {
        HttpWebResponse response = (HttpWebResponse)((HttpWebRequest)result.AsyncState).EndGetResponse(result);
        DataContractJsonSerializer s = new DataContractJsonSerializer(typeof(TrendsResult));
        TrendsResult trends = (TrendsResult)s.ReadObject(response.GetResponseStream());
        foreach (Trend trend in trends.Trends) {
            ((App)App.Current).RootFrame.Dispatcher.BeginInvoke(DoItemAdd, new ItemViewModel { LineOne = trend.Name, LineTwo = trend.Url });
        }
    }, request);

    this.IsDataLoaded = true;
}

private void DoItemAdd(ItemViewModel item) {
 this.Items.Add(item);
}
```

It should be clear now that there are no scope issues with this code.  

So there you have it, a twitter trend downloader that has hopefully pointed out a few things you should look out for when starting down the asynchronous path required by Windows Phone 7.  
  
