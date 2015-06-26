---
title: STREXTRACT()
layout: post
permalink: /2006/05/strextract.html
tags: vfp
guid: tag:blogger.com,1999:blog-25631453.post-114663484317049464
tidied: true
---

To stem the code overload of the last two posts I am going to mention one of my favourite VFP functions.

<!-- more -->

`STREXTRACT(cSearchExpression, cBeginDelim [, cEndDelim [, nOccurrence[, nFlag]]]])`
([docs](http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dv_foxhelp9/html/c1f77249-8327-4abe-81c6-d89d6ff7f121.asp))

Well named, this function simply allows you to "extract" one string from within another. It's one of those functions you may not immediately find a use for, but it is a massive time-saver when you do.

I have provided a simple example for parsing a basic XML fragment.
It's not the best way to parse XML, but it is simple when your input is robust.
  
#### Example

```XBase
local cStr
text to cStr noshow
  <article key="a1">
    <title>Article Title 1</title>
    <date>01/04/2006</date>
    <Author>Chris</author>
  </article>
  <article key="a2">
    <title>Article Title 2</title>
    <date>03/04/2006</date>
    <Author>Tim</author>
  </article>
endtext

local i, cArticle
for i = 1 to occurs("<article", lower(m.cStr))
  cArticle=strextract(m.cStr, "<article", "</article>", i, 1+2+4)
  ?strextract(m.cArticle, [key="], ["], 1, 1)
  ?strextract(m.cArticle, "<title>", "</title>", 1, 1)
  ?strextract(m.cArticle, "<date>", "</date>", 1, 1+4)
  ?strextract(m.cArticle, "<author>", "</author>", 1, 1)
endfor
```

#### Output

```bash
a1
Article Title 1
<date>01/04/2006</date>
Chris
a2
Article Title 2
<date>03/04/2006</date>
Tim
```
