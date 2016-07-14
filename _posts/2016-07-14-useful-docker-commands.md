---
title: Useful Docker Commands
layout: post
permalink: /2016/07/useful-docker-commands.html
tags: docker tips
---

Today I'll share some quick, helpful, docker commands I use in my workflow. These help keep my development and production machines clean of old and unused images.

I'm no bash expert, so tweet me or make a [PR](https://github.com/csainty/csainty.github.io) if you have any suggestions.

<!-- more -->

### Remove dangling images

```
docker rmi $(docker images --filter="dangling=true" -q)
```

In development you will generally be experimenting building images and you tend to re-use tags while tweaking and perfecting your build.  
Each time you re-use a tag though, it does not delete the old image, it just untags it. These are called dangling images and can be seen like this

```
$ docker images
REPOSITORY                      TAG                 IMAGE ID    
<none>                          <none>              bc53f0c6cce0
mysql                           5.6                 01bbb21c400c
centos                          7                   05188b417f30
```

Luckily these are easy to filter on with `docker images --filter="dangling=true"`, and once you can list something, you can easily use an expansion to do something useful with it, like `rmi` to remove the images.

```
$ docker rmi $(docker images --filter="dangling=true" -q)
Deleted: sha256:bc53f0c6cce0
Deleted: sha256:2ac48b1345ab
```

### Remove unused images

```
docker rmi $(grep -xvf <(docker ps -a --format '{{ "{{.Image"}}}}' | sed 's/:latest//g') <(docker images | tail -n +2 | grep -v '<none>' | awk '{ print $1":"$2 }' | sed 's/:latest//g'))
```

In production, however, the problem is different. Assuming you use versioned tags, then you are going to end up with a lot of old images around when new versions have been deployed.  

Let's break the command down going from right to left

First, find all the images on the system

```
$ docker images | tail -n +2 | grep -v '<none>' | awk '{ print $1":"$2 }' | sed 's/:latest//g'
memcached
centos:7
haproxy:1.6
mysql:5.6
```

Next, find all the images which have containers based off them

```
$ docker ps -a --format '{{ "{{.Image"}}}}' | sed 's/:latest//g'
mysql:5.6
memcached
```

Then, feed these two lists in to grep to find the mismatch

```
$ grep -xvf <(docker ps -a --format '{{ "{{.Image"}}}}' | sed 's/:latest//g') <(docker images | tail -n +2 | grep -v '<none>' | awk '{ print $1":"$2 }' | sed 's/:latest//g')
centos:7
haproxy:1.6
```

Finally this list is fed in to the `rmi` call.
