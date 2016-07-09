---
title: Developing with Docker on OSX
layout: post
permalink: /2015/10/docker-on-osx.html
tags: docker
---

---
**Update:**

Much of this post is made irrelevant by the release of [Docker for Mac beta](https://blog.docker.com/2016/03/docker-for-mac-windows-beta/). You no longer need a separate virtualization environment (virtualbox) you no longer need to tunnel ports (docker-pf) and you can now map volumes directly from OSX to docker and have watches etc all work.  
So just `brew cask install docker` and ignore most of this post!

---

Docker is the talk of the town in recent times. Containerized deployments of micro services are quickly gaining momentum as best-practice architecture for certain classes of applications.

As ever in software development though, understanding how to make a start with these tools isn't easy. Especially if you are working on an existing monolith.

So in this post I will share some basic tips to start using Docker in your existing development workflow, gaining this understanding can be the stepping stone to using Docker in production or in your next project.

<!-- more -->

### Installation

As usual you want to reach for [Homebrew](http://brew.sh/) to install any software on your mac.

```
brew install docker docker-machine
brew cask install virtualbox
```

[See my post for more details]({% post_url 2015-08-03-homebrew-and-caskroom %})

### Virtualization layer

It is worth keeping in mind that docker is a linux technology. When you install and use docker on an OSX or Windows based machine, you need a linux virtual machine to serve as the docker host.  
Luckily for us [docker-machine](https://docs.docker.com/machine/) handles this detail.

```
docker-machine create -d virtualbox dev
```

This command will download and provision a suitable virtual machine for you. You can run multiple named docker hosts, in my examples I use the name `dev`.

Now we have a machine, we need to configure the `docker` command line tools to point at the correct machine.

```
docker-machine env dev
```

This will print out a list of necessary environment variable to make this happen.

```
$(docker-machine env dev)
```

Wrapping it, interprets these and sets them in your shell session. You should consider adding this line to your `.bash_profile` or putting it in a `start-dev.sh` script.

### Pull down some images

Now you have docker running, pick a piece of software already in use in your development environment and dockerize it. I'll choose [memcached](http://memcached.org/) which is available on [docker hub](https://hub.docker.com/_/memcached/).

```
docker create --name memcached -p 11211:11211 memcached:latest
docker start memcached
```

Here we create a new docker container, named `memcached`, we tunnel port `11211` in the container to port `11211` on the docker host, and we install the `memcached:latest` image in to the container.  
Then we simply start our new container.  
You can see the status of you container with

```
docker ps
```

### Ports

So far everything is simple. Here is the trick though, remember how I said you have a linux VM running as the docker host. Well when you tunnel ports out of docker containers to the host, that means they are in the VM. They are not available on localhost.  
It's a small thing, but it is annoying. Any code you have that expects to find memcached on `localhost` for the development environment now needs to be changed, or parameterized. Who has time for that?

So now we need to set up another tunnel, one that maps ports between `localhost` and the docker host.

You could use ssh:

```
ssh -i $DOCKER_CERT_PATH/id_rsa -N -T -L *:11211:localhost:11211 docker@$(docker-machine ip dev)
```

Or socat:

```
socat tcp4-listen:11211,fork tcp4:$(docker-machine ip dev):11211
```

Alternatively you can grab this neat little node script my co-worker made [https://github.com/noseglid/docker-pf](https://github.com/noseglid/docker-pf)

```
git pull git@github.com:noseglid/docker-pf.git
cd docker-pf
npm install
npm start
```
The nice thing about `docker-pf` is that it will inspect your docker host and tunnel all exposed ports automatically!


### Wrap Up

So there you have it, a few simple steps and you can seamlessly move a piece of your development architecture in to a container. Go ahead and containerize all the services you are dependent on. With minimal time and effort you now have some pieces in place to experiment. Learn the docker tooling, understand the concepts and get yourself prepared for when you start containerizing your production environment.  
As a bonus, you end up with a cleaner developer machine too! Need to have multiple versions of multiple services at hand to support all your apps? No problem just containerize them all and start/stop at will.
