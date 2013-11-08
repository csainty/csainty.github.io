---
title: UTF-8 Encoding
layout: post
permalink: /2006/08/utf-8-encoding.html
tags: vfp
guid: tag:blogger.com,1999:blog-25631453.post-115553717502685117
---

I was recently working on creating RSS feeds dynamically from a product database, and kept finding they would not validate due to invalid characters being used for UTF-8 encoding.
I found a quick one liner that seems to tidy this up, albeit in a way i'm somewhat less than comfortable with (I never did exhaustive tests to be sure it didnt mess with the valid data in some way). Anyway here is my code

```

cStr= strconv(strconv(m.cStr,11),9)
```


Has anyone done a similar thing before and have a better solution? Or better yet put my mind at ease that I have no reason to dislike this one.
