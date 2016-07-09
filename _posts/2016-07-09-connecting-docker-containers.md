---
title: Connecting docker containers
layout: post
permalink: /2016/07/connecting-docker-containers.html
tags: docker
---

Twice recently I have seen people ask on twitter about how to link docker containers. In both instances they were given overly-complex answers that are out of date with the current state of docker.

So today I will show you how to do it correctly for docker v1.10.0+

<!-- more -->

### Why connect containers

You should be running a single process per docker container, this means your application code (say nodejs) and your database (say postgres) need to be running in their own containers. Potentially on different servers if you have a swarm or cluster of hosts.  
Therefore connecting two containers together in docker is essential. So how do you do it?

### Using docker network

Connecting containers is simple. You just add them to the same docker network. If you only have a single host then it will come with a pre-configured `bridge` network called `bridge` that you can use without any extra work.

```
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
10735ef1e95f        bridge              bridge              local
85274e9bac4e        host                host                local
b9d9f025e8bb        none                null                local
```

But you can also create your own easily enough. You can create as many as you like to isolate groups of containers.

```
$ docker network create --driver=bridge my-network
4114eb9b91a55df8380da5ce5b288e7a7b1841b59366368b8f35e4437b2fcd25

$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
10735ef1e95f        bridge              bridge              local
85274e9bac4e        host                host                local
4114eb9b91a5        my-network          bridge              local
b9d9f025e8bb        none                null                local
```

In a multi-host environment use the `overlay` driver to create a network that spans across the hosts. That is a topic for another post.

Once you have a network, there are two ways to connect a container to it.

If you are starting a fresh container, simply add `--net=my-network` to the `docker run` command.

If you have an existing container, then run `docker network connect my-network my-container`.

Let's test it out by creating two connected containers, drop in to their shells and do some pinging.

```
# In terminal 1
$ docker run --rm -it --net=my-network --name container1 centos bash

# In terminal 2
$ docker run --rm -it --net=my-network --name container2 centos bash

[root@acefce27fa79 /]# ping container1
PING container1 (172.18.0.2) 56(84) bytes of data.
64 bytes from container1.my-network (172.18.0.2): icmp_seq=1 ttl=64 time=0.102 ms

# Back in terminal 1
[root@456e69adfde0 /]# ping container2
PING container2 (172.18.0.3) 56(84) bytes of data.
64 bytes from container2.my-network (172.18.0.3): icmp_seq=1 ttl=64 time=0.103 ms
```

### Why networks and not links or compose

The other things I have seen people say on twitter is to use links (largely deprecated now) or compose (the utter wrong tool for the job).

Networks are the right answer, they handle container restarts and ip changes, and the abstraction holds across swarms and multi-host networks. In addition they are as simple as can be. So ignore the other stuff and just use them!

### What about ports?

Another benefit here is that ports between the containers are opened. So if you were previously exposing ports to the host just so another container could access it you, can stop doing that.

Let's open a third terminal window and add a `memcached` instance to our network.  

```
# In terminal 3
$ docker run --rm --net my-network --name memcached memcached

# In terminal 1 or 2
[root@acefce27fa79 /]# yum install telnet
[root@acefce27fa79 /]# telnet memcached 11211
Trying 172.18.0.4...
Connected to memcached.
Escape character is '^]'.
flush_all
OK
```

Here we can see we were able to add a new container to the network and immediately access it, and its ports, without any reconfiguration of the containers already on the network.
