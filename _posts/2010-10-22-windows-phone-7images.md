---
title: Windows Phone 7–Images
layout: post
permalink: /2010/10/windows-phone-7images.html
tags: wp7dev wp7 C#
guid: tag:blogger.com,1999:blog-25631453.post-5945364718702986493
tidied: true
---

Now about that Image Control. I mentioned in my last post that it seems to download on the UI thread, or at least block the UI thread while downloading.  
  
Personally I think this is going to be a major issue with v1 apps in the marketplace when used on 3G connections.  
  
It is actually a difficult thing to test, so here is the methodology I have been using and the code I am using to get around the issue.  
  
First you are going to want a local IIS server, put an image on the server, and then we are ready to go with the phone tools. We are later going to throttle the bandwidth on the server, if you do not have a local server you will need to find a way to throttle your network connection on the PC you are using. I am sure it is possible but have not looked at it.  
  
For this post I am just creating a basic Windows Phone Application, add the following XAML to the Grid in the MainPage.xaml and pop in your image URL.  
  
```markup
<!--ContentPanel - place additional content here-->

<Grid x:Name="ContentPanel" Grid.Row="1" Margin="12,0,12,0">
    <ScrollViewer>
        <StackPanel>
            <TextBlock Text="Above" />
            <Image Source="[Your Image URL]" />
            <TextBlock Text="Below" />
        </StackPanel>
    </ScrollViewer>
</Grid>
```

Now if you run this app, up will pop your image and you will be able to pan up and down since we are in a ScrollViewer.  

Now let’s see what happens on a slow connection, for this you will want to set a bandwidth throttle on your web server. In IIS 6 you do this from the Performance tab of the site properties. In IIS 7 go into Advanced Settings | Connection Limits | Maximum Bandwidth. I have been setting it to between 1 and 5 kBps. This should make the image take a few seconds to download.  

If we now run our application again (you will need to close the emulator and let it restart as it caches), before the image loads, try scroll the page. You should find that you can not, but then once the image loads you will be able to again. Now consider how that would appear to a user on a slow 3G connection if they had a page of images to load.  

So on to our fix.  

Add the following two classes to the project (changing the namespace as appropriate)  


```csharp
using System;
using System.ComponentModel;
using System.IO;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Imaging;

namespace BlogImageApp
{
    public static class ImageExtension
    {
        public static string GetSource(DependencyObject obj) {
            return (string)obj.GetValue(SourceProperty);
        }

        public static void SetSource(DependencyObject obj, string value) {
            obj.SetValue(SourceProperty, value);
        }

        // Using a DependencyProperty as the backing store for Source.  This enables animation, styling, binding, etc...
        public static readonly DependencyProperty SourceProperty =
            DependencyProperty.RegisterAttached("Source", typeof(string), typeof(ImageExtension), new PropertyMetadata(SourceChange));

        private static void SourceChange(DependencyObject sender, DependencyPropertyChangedEventArgs e) {
            Image imageControl = sender as Image;
            if (imageControl == null)
                return;
            string url = (string)e.NewValue as string;

            if (DesignerProperties.IsInDesignTool) {
                imageControl.Source = new BitmapImage(new Uri(url, UriKind.Absolute));
            } else {
                HttpWebRequest request = HttpWebRequest.CreateHttp(url);
                request.AllowReadStreamBuffering = true;
                request.BeginGetResponse(RequestComplete, new CallbackData { Request = request, ImageControl = imageControl });
            }
        }

        private static void RequestComplete(IAsyncResult result) {
            CallbackData data = (CallbackData)result.AsyncState;

            HttpWebResponse response = (HttpWebResponse)data.Request.EndGetResponse(result);

            data.ResponseStream = response.GetResponseStream();

            ((App)App.Current).RootFrame.Dispatcher.BeginInvoke(new Action<CallbackData>(x => {
                BitmapImage imagesource = new BitmapImage();
                imagesource.SetSource(x.ResponseStream);
                x.ImageControl.Source = imagesource;
            }), data);
        }
    }

    public class CallbackData
    {
        public HttpWebRequest Request { get; set; }
        public Image ImageControl { get; set; }
        public Stream ResponseStream { get; set; }
    }
}
```

What this code does is create a new attached property we can use on the Image control. When set it will download the image in the background and then set the source once it has downloaded. It would be fairly easy to hook this up to use a loading image in the meantime, but I have not done that here.  


A few interesting lines  

* Line 31 – We check if we are in the designer and bypass all this if we are.
* Line 35 – This is needed for when we set the image source. You will get an exception without it.
* Line 36– I have, uncharacteristically for me, not used a lambda here. I decided in this case it was very difficult to read since I am passing a few bits of information around.
* Line 44 – You need to create the BitmapImage on the UI thread, otherwise you get an exception.


With this in place and the project recompiled we need to add a reference to the namespace in our `MainPage.xaml`. Add the following line to the <phone:PhoneApplicationPage> tag (again replacing the namespace as appropriate)  

`xmlns:local="clr-namespace:BlogImageApp"`


Then we can change our Image control and set the new attached property instead of the default Source property.  


`<Image local:ImageExtension.Source="[Your Image Url]" />` 


Now run up the app, again after closing the emulator to clear the cache, and this time you should be able to scroll around to your heart’s content while waiting for the image to load.  


I have only used this code to download a couple of images at a time, if you had a page with dozens of images I would suggest working with only a couple of downloaders and queue work items for them, otherwise you might tie up too many resources and block the whole phone, not just the UI.  
  
