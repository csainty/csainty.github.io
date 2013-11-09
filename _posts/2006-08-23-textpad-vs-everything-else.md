---
title: Textpad vs Everything Else
layout: post
permalink: /2006/08/textpad-vs-everything-else.html
tags: personal
guid: tag:blogger.com,1999:blog-25631453.post-115629562980154973
tidied: true
---

I have stated in public before my love of [Textpad](http://www.textpad.com/) for developing HTML/CSS.
It is small, clean, fast and has served me well for a long time.

I have trialed some other tools, such as Dreamweaver and Visual Web Developer Express, but they have all lacked, in my limited explorations at least, one feature that would really make them useful to me.

<!-- more -->

I develop sites in patches, each page will have some common patches, such as a header and footer, some content specific to the page, and some patches that may be shared with other pages.
If you look at [www.ht.com.au](http://www.ht.com.au) and the 9 "Feature Products" on the home page, there is a call in the website, which you pass a part number, and it runs off a HTML template, dropping in the details of that part. This gets called 9 times, on the homepage to generate the featured products, but is also used on other pages throughout the site, differences in display are handled by the CSS.

If I open this patch in a visual development tool, and try to preview it, it doesn't even come close, because by itself, the patch lacks the context of the rest of the page it is showing on.
For starters it is missing the CSS links, but even if it had these it is missing any container elements that may affect how the patch renders.
With the preview side of visual tools removed, it offers nothing more than intellisense. Which for me does not offset the overhead of a large application against a small.

Hence the reason I still use Textpad, even when developing a site the size of Harris Technology.
So what I believe visual development tools need, or if they already have this feature I need someone to point out where it is hiding, is the ability to apply some rendering context to a file you are working on. Along the lines of 'Attach these stylesheets' and 'Add this code before and this code after the file' but only when rendering, don't write it into the file on disk.

Has anyone else come across this sort of problem and found a way around it? Or do we all secretly still use Textpad.
