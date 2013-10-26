---
title: RenderComponent() or RenderUserControl()
layout: post
permalink: /2008/03/rendercomponent-or-renderusercontrol.html
tags: mvc asp.net C# dotnet
---


One thing I have always needed to do in my web sites is break sections of pages out into a re-usable component.   If you look at [http://www.ht.com.au](http://www.ht.com.au/) the "Featured Product Of The Month" panel displays three product "patches". This exact same patch is used on the [Cart](http://www.ht.com.au/cart.hts) page and the [Hub](http://www.ht.com.au/N/Computers/area.hts) pages. It is a nice little class/template that you pass a product number to and it spits back the HTML for that patch, which you write out like any other expression in your template.  
  
When I first went looking for this functionality in ASP.NET MVC all I could find was the RenderUserControl() method on the Html Helper class. Called like this   <%= Html.RenderUserControl("path_to_ascx_file") %>  
  
What instantly bothered me about this call was that it heads straight off to a "View" if I wanted to supply any logic, say to turn my product number into an actual product object, then go look up some other information about it, all this code would need to go into the View, or at least into the Code Behind page of the View, which is just as bad. It wasn't very MVC to me.  
  
In the March Preview 2 release of the MVC Framework however they added a new ComponentController base class and a RenderComponent() method to the Html Helper class. Now you can call   <%= Html.RenderComponent<PatchController>(c=>c.ProductPatch(1)) %>    This will call the ProductPatch() method on the PatchController class and pass in the parameter of 1. Now you have a MVC pattern, from within the controller you configure up your model, pick a view to render and fire it all off. The result is the output of the view gets stuck on a RenderedHtml property of the controller that the Html Helper picks up and inserts back into the parent page. My dreams had come true!  
  
Sadly when I went to implement this, a bug popped its head up. If you attempt to pass a variable into the lambda rather than a constant (so ViewData.ProductID instead of 1) there is a Cast Exception thrown where the expression can not be cast from a variable expression to a constant expression.   This bug was reported today on the MVC forums, and as such had prompted me to respond there and put together this post, something I had been intending to do for a few days now since I spotted it.  
  
I have a work around that is probably a bit hacky but has allowed me to continue on working until the team works out a way around the bug. If you create a subclass of ViewPage from which you subclass all your actual ViewPages, then you can pop this method in that subclass, alternatively set up an Extension Method for the ViewPage class to save you the trouble.  
  
This code assumes all your components live in a single Controller (a side effect of which is a cleaner calling syntax), if this is not the case, then you can easily refactor the type of the controller out of the method and pass it in like the HtmlHelper method does.  
     `public string RenderComponent(Expression<Action<PatchController>> action)
{
    var controller = new PatchController();
    controller.Context = this.ViewContext;
    var ex = action.Compile();
    ex.Invoke(controller);
    return controller.RenderedHtml;
}`




This allows calling a component like this
  <%= RenderComponent(c => c.ProductPath(ViewData.ProductID)) %>

  and will work with both variables and constants. Shorter and better!  



When I have gone looking for prior references to this method on the web, I always seem to run into religious wars about whether Components/UserControls/Partials or various other names for a similar concept have any place in MVC or web sites in general, with most people seeming to think they do not. I personally don't see how people can live without them. Hopefully this side of the framework does not get overlooked in the future, or worse, dropped.  
