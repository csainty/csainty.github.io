---
title: Running jekyll with docker
layout: post
permalink: /2016/07/jekyll-in-docker.html
tags: jekyll docker blog
---

Previously I moved my [jekyll installation]({% post_url 2015-08-05-jekyll-in-vagrant %}) inside a Vagrant image. At the time this was a big improvement over installing and maintaining ruby/jekyll locally on my machines.

For a while now I have wanted to move this installation inside Docker instead. I actually use Docker daily in my work and am very comfortable in that environment.  
It wasn't until the recent release of [Docker for Mac](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/) beta that this became practical though with the improvements to volume mapping.

So this morning I finally made the switch.

<!-- more -->

### Install Docker for Mac

As usual you want to reach for [Homebrew](http://brew.sh/) to install any software on your mac.

```
brew cask install docker
```

[See my post for more details]({% post_url 2015-08-03-homebrew-and-caskroom %})

Gone are all the complexities I discussed [previously]({% post_url 2015-10-01-docker-on-osx %}) around creating machines, virtualization etc.

### The Dockerfile
Creating the [Dockerfile](https://github.com/csainty/csainty.github.io/blob/source/Dockerfile) was just a matter of trial and error and tidying up some of my blog code to meet API changes in Jekyll.

As ever when I am sitting down to write a Dockerfile I start by running up the shell in my chosen base image `docker run --rm -it alpine sh` this gives me a test environment I can quickly use to check what packages I need to install and what additional config is needed. I can simply `exit` and re-run to clean it and start over. As I verify each command I add it to my `Dockerfile` I am editing in my text editor a screen across.

With the `Dockerfile` written it is a simple matter to build it `docker build -t csainty/blog .` then run it with my source mapped in and the Jekyll port mapped out `docker run --rm -it -p 4000:4000 -v $(pwd):/src csainty/blog`

### Workflow

With that done it now behaves exactly like if I was running Jekyll locally. Watched files work, I can browse to http://localhost:4000 to see the site, the generated `_site` folder is updated ready for publishing with `git`.


### Wrap up

Docker for Mac opens a whole host of new options for small portable development environments that were previously tedious due to the remote host needed when running docker on OSX. I can see myself running many development tools from inside docker containers in the future.
