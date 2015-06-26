---
title: Knockout custom binding handlers
layout: post
permalink: /2013/11/knockout-custom-binding-handlers.html
tags: javascript knockout
---

For the last few months I have been working on a large, complex [KnockoutJS](http://knockoutjs.com/) application.  
Along the way I have picked up a number of patterns and techniques that have helped keep things manageable.

One of the most important lessons was to learn to love custom bindings. Today I will show an example of how you can use a custom binding to add reusable logic to your views without having to make changes to your viewmodels.

<!-- more -->

First let us assume we have a list of items we are presenting.

```javascript
var items = [];
for (var i = 1; i <= 50; i++) {
  items.push(i); 
}

var viewModel = {
  items: ko.observableArray(items) 
};

ko.applyBindings(viewModel);
```

We have tests over this code, we perhaps have a computed elsewhere that uses this `observableArray` then a story card comes along that says _"As a customer viewing the items on the website. I would like to have them grouped by foo so that I can more easily browse the list"_.

Your first reaction might be to change the `items` array into an array of groups. Or perhaps you would create a `ko.computed` that does tee grouping for you.

I'd like to propose a third solution for your consideration. In our case the grouping of these items is only relevant to the UI, no where in our viewmodel logic do we care about the groups. So let's keep the grouping code where it belongs, in the view.

Luckily it is really easy to create custom bindings in knockout, better yet it is very easy to wrap existing bindings with a thin layer of custom logic. So we could add a new binding which behaves like a `foreach` but groups the items before display.

```javascript
ko.bindingHandlers.grouped = {
  init: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
    ko.bindingHandlers.foreach.init(element, function () { return []; }, allBindings, viewModel, bindingContext);
  },
  update: function (element, valueAccessor, allBindings, viewModel, bindingContext) {
    var options = valueAccessor();
    var groups = _(ko.utils.unwrapObservable(options.data)).chain().groupBy(options.by).map(function (value, key) { return { key: key, items: value }; }).value();
    
    ko.bindingHandlers.foreach.update(element, function () { return groups; }, allBindings, viewModel, bindingContext);
  }
};
``` 

Now where we previous had a `foreach: items` binding we replace it with this.

```xml
<ul data-bind="grouped: { data: items, by: function (i) { return i % 2 === 0 ? 'Even' : 'Odd'; } }">
  <li>
    <span data-bind="text:  key"></span>
    <ul data-bind="foreach: items">
      <li data-bind="text: $data"></li>
    </ul>
  </li>
</ul>
```

Now instead of iterating of the items directly we are iterating over objects with this structure `{ key: 'Even', items: [2, 4, 6] }`.

Not only does this keep some very UI specific code out of our viewmodels, we have created something that we can reuse, the next time we are asked to group some items we simply change from a `foreach` to a `grouped` binding and we are good to go.

You can this in action here - [http://jsbin.com/orUFAma/3/](http://jsbin.com/orUFAma/3/).
