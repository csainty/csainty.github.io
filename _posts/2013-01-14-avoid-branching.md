---
title: Avoid branching
layout: post
permalink: /2013/01/avoid-branching.html
tags: meta
guid: tag:blogger.com,1999:blog-25631453.post-2842848493472340326
tidied: true
---

One thing I have noticed recently is that I like to avoid branching. Now what I am talking about here is not branching at a code level. I am talking about mental branching as I am writing code, following other trains of thought or investigating problems whose answers are not immediately necessary.

It seems obvious, but after following along some conversations on twitter recently I think I need to post more, even for things I find obvious. So…

About a meter from my desk I have a whiteboard.

![Branching Board](/images/1382874050650.png)

The sections and structure of it don’t really matter, they are what makes sense for my project and the team I am working with.

Almost every note on that board is a branch I could have gone down that would have caused me to stop what I was in the middle of doing and focus on the branch. I find this sort of context switching very disruptive.

To be clear about the whiteboard this isn’t some sort of quasi-agile project workflow (we use trello for that), these are not story cards and if someone calls me up and says _“we have some important thing you need to do”_ then I branch. This is not about sitting in a programming utopia where I am uninterruptable, it is about not interrupting myself. These notes are questions and tasks that need to be answered or completed but ones that can wait. Here are some examples

* _“Should we avoid making searches we know to be bad?”_
* _”Should we write a $0 tax record or leave the tax record off?”_

The domain I am working in at the moment involves talking to a lot third party APIs and integrating them into the internal domain model. So inevitably there is a lot of mapping that goes between the response from the API and the internal model, both are quite complex and different from each other.

So while I am sitting down with a list of 50 properties I need to go though and I come across one where I do not know the business answer to the problem, I write it on a note, stick the note on the board and move on. Then once I am done, I go to the board and read through through the notes.

Sometimes with the extra knowledge I have gained since writing the note I can now answer it myself. Sometimes I can ask someone else on the team and they answer it. Sometimes I can research within the codebase for the answer. Sometimes I need to talk to the product owner.

That is a lot of “sometimes” and it is precisely why I defer that chain of “sometimes” until the last possible moment.
