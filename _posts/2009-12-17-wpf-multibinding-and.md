---
title: WPF&#58; MultiBinding and IMultiValueConverter
layout: post
permalink: /2009/12/wpf-multibinding-and.html
tags: wpf silverlight csharp dotnet
guid: tag:blogger.com,1999:blog-25631453.post-3819537496726524457
tidied: true
---

I came across the [MultiBinding](http://msdn.microsoft.com/en-us/library/system.windows.data.multibinding.aspx) markup extension and [IMultiValueConveter](http://msdn.microsoft.com/en-us/library/system.windows.data.imultivalueconverter.aspx) today when looking for a solution to a problem. Not sure how I missed it previously. If you didn’t I probably don’t have a lot to add, but if you have not heard of them then read on.  

<!-- more -->
  
The problem basically went like this, I have a `TabControl` that is hosting content with a `Title` property and an `IsChanged` property. I was binding the `Header` of the `TabControl` item to the `Title` of the content, but I wanted to add an ‘*’ to the end of the text if `IsChanged` was `True`.  
  
I initially moved the binding to the class itself (instead of the `Title` property) and added an `IValueConverter` that could convert convert an instance of the class into the string I wanted `Title + (IsChanged ? “ *” : “”)` and while this worked when the binding was evaluated the first time, it obviously (if you understand WPF) broke when `Title` or `IsChanged` were updated.  
  
Enter a `MultiBinding` and its partner in crime `IMultiValueConverter`. Now anyone who learnt WPF from a book or tutorial probably had a section all about this pair and how useful they are. Those of us who learn as we go however might have missed this one like I did.  
  
A `MultiBinding` works just a regular `Binding` except it must have a `Converter` specified and can have multiple pieces of data bound to it, so when any of these change it fires a re-evaluation of the lot. There are two cases where this is helpful, and I will explain both.  
  
The first is probably the intended use, which is where you want to combine two data elements into a single value and update that value when either changes.  
  
For our example we are using a basic dataclass with two properties, a WPF form with a textbox to enter both of these values and a textblock to display the combination, and an implementation of IMultiValueConverter that does the combining. I have cut a few lines of code out for readability, but the whole lot is in the download linked at the bottom of this post.  
  
```csharp
public class DataClass
{
   public string FirstName { get; set; }

   public string Surname { get; set; }
}

public class NameMultiValueConverter : IMultiValueConverter
{
   public object Convert(object[] values, Type targetType, object parameter, System.Globalization.CultureInfo culture) {
       return String.Format("{0} {1}", values[0], values[1]);
   }
}
```



The XAML looks basically like this, again I have cut out non-essential code so grab the download if you need it.  


```xml
<Window xmlns:local="clr-namespace:BlogIMultiValueConverter">
    <Window.Resources>
        <local:NameMultiValueConverter x:Key="NameMultiValueConverter" />
    </Window.Resources>
    <Grid>
        <TextBox Text="{Binding Path=FirstName, UpdateSourceTrigger=PropertyChanged}" />
        <TextBox Text="{Binding Path=Surname, UpdateSourceTrigger=PropertyChanged}" />
        <TextBlock>
            <TextBlock.Text>
                <MultiBinding Converter="{StaticResource MultiValueConverter}">
                    <Binding Path="FirstName" />
                    <Binding Path="Surname" />
                </MultiBinding>
            </TextBlock.Text>
        </TextBlock>
    </Grid>
</Window>
```

Fire it up and enter some data and you get this  

![captured_Image.png[4]](/images/1382874052721.png)   

Nice and simple, does just what you would expect. But what I found more useful was to include the object itself as the first `Binding`, and then use the extra bindings simply for their triggers.  

What this lets you do is call methods on the object to aid in the production of your new value. This could save some duplicating of code if you already have a method that does the transformation (for example builds a name or address string from its components) while still having the update triggered when any component changes.  


So our `IMultiValueConverter` becomes (I have it doing a pointless task simply to show the difference)  


```csharp
public class DataClassMultiValueConverter : IMultiValueConverter
{
    public object Convert(object[] values, Type targetType, object parameter, System.Globalization.CultureInfo culture)
    {
        if (values[0] is DataClass)
        {
            DataClass data = values[0] as DataClass;
            return String.Format("{0} {1} {2}", data.FirstName, data.Surname, data.ExtraData());
        } else { return ""; }
    }
}
```

And the XAML becomes  

```xml
<MultiBinding Converter="{StaticResource DataClassMultiValueConverter}">
    <Binding />
    <Binding Path="FirstName" />
    <Binding Path="Surname" />
</MultiBinding>
```

And the result of this useless conversion  

![captured_Image.png[6]](/images/1382874052726.png)   

So there you have it. If you missed the `MultiBinding` / `IMultiValueConverter` and need to convert/combine data for display purposes while maintaining the regular Binding trigger mechanism, make sure you take a look.  



  
  
