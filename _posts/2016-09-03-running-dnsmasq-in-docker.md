---
title: Running dnsmasq in Docker
layout: post
permalink: /2016/09/running-dnsmasq-in-docker.html
tags: docker dnsmasq
---

Today we take a quick look at running [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) as a docker container.

dnsmasq is a simple lightweight DNS (amongst other features) that can be used to easily set up various DNS records within your infrastructure. Our particular usecase is to set the TXT records [Eureka](https://github.com/Netflix/eureka) requires for DNS based bootstrapping.

<!-- more -->

### Getting started

I've built and release an alpine based dnsmasq image which configures itself from a directory of `.conf` files. I chose this approach so that different services can include themselves in dnsmasq during provisioning.

You can see the Dockerfile here - [https://github.com/storytel/dnsmasq](https://github.com/storytel/dnsmasq)

### Starting the container

```
docker run --name dnsmasq --cap-add=NET_ADMIN --net=host -v /etc/dnsmasq:/etc/dnsmasq storytel/dnsmasq
```

There are three options here to note :-

1. `--cap-add=NET_ADMIN` is required for dnsmasq to interact with the network stack
2. `--net=host` runs the container with the host network stack, so that port `53` on the host becomes the DNS and is accessible from the rest of the network.
3. `-v /etc/dnsmasq:/etc/dnsmasq` maps our folder of `.conf` files inside the container.

### Configuration

dnsmasq will read all the `.conf` files added to `/etc/dnsmasq` (a container restart is required to load changes). So we can add each service as it's own file, or put them all in one. Whichever suits your configuration needs.

```
# 0.base.conf
domain-needed
bogus-priv
no-hosts
keep-in-foreground
no-resolv
expand-hosts
server=8.8.8.8
server=8.8.4.4
```

```
# 1.eureka.conf
address=/001.eureka.storytel/10.10.10.21
address=/002.eureka.storytel/10.10.10.22
address=/003.eureka.storytel/10.10.10.23
txt-record=txt.global.eureka.storytel,sweden.eureka.storytel
txt-record=txt.sweden.eureka.storytel,10.10.10.21,10.10.10.22,10.10.10.23
```

```
# 2.etcd.conf
address=/001.etcd.storytel/10.10.10.21
address=/002.etcd.storytel/10.10.10.22
address=/003.etcd.storytel/10.10.10.23
```

### Access from another server

Once we have our container up and running we can then use the DNS from other servers on the network.

```
$ dig @10.10.10.1 TXT txt.global.eureka.storytel

; <<>> DiG 9.10.2-P4 <<>> @10.10.10.1 TXT txt.global.eureka.storytel
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 13897
;; flags: qr aa rd ra ad; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;txt.global.eureka.storytel.      	IN     	TXT

;; ANSWER SECTION:
txt.global.eureka.storytel. 0     	IN     	TXT    	"sweden.eureka.storytel"

;; Query time: 1 msec
;; SERVER: 10.10.10.1#53(10.10.10.1)
;; WHEN: Sat Sep 03 09:04:25 UTC 2016
;; MSG SIZE  rcvd: 85
```
