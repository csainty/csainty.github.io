---
title: Bootstrapping Spring Cloud Netflix Eureka using DNS
layout: post
permalink: /2016/09/bootstrap-eureka-with-dns.html
tags: eureka spring java
---

[Spring Cloud Netflix](https://cloud.spring.io/spring-cloud-netflix/) is a spring wrapper around many of the core components of the [Netflix OSS](https://netflix.github.io/) stack.

It makes running some of these components very simple, but the devil is usually in the configuration. Let's take a look at how to configure your [Eureka](https://github.com/Netflix/eureka) server instances to discover each other via DNS when running in your own datacenter.

<!-- more -->

### Spring Cloud Netflix != Netflix OSS

First a word of warning. Part of the Spring Cloud Netflix wrapper around the Netflix components is a separate configuration system. The configuration options I use in this post do not match exactly to what you will find if you are using the Netflix libraries directly.

### Creating a Eureka Server with Spring Cloud Netflix

You only need a tiny piece of java code to bring up a Eureka server using the Spring libraries.

```java
package com.storytel.eureka;

import org.springframework.boot.Banner;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.cloud.netflix.eureka.EnableEurekaClient;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

@SpringBootApplication
@EnableEurekaServer
@EnableEurekaClient
public class Application {

    public static void main(String[] args) {
        new SpringApplicationBuilder(Application.class)
                .bannerMode(Banner.Mode.CONSOLE)
                .registerShutdownHook(true)
                .web(true)
                .run(args);
    }

}
```

### Configuring a Spring Cloud Netflix Eureka server for DNS

There are two ways to link eureka servers to each other. You can either provide static configuration or you can utilize well defined DNS records. Here I show how to do the latter via `application.yml`.

```yml
spring:
  application:
    name: eureka

server:
  port: 8761

eureka:
  instance:
    healthCheckUrlPath: /health
  client:
    region: global
    eurekaServerPort: 8761
    useDnsForFetchingServiceUrls: true
    eurekaServerDNSName: eureka.storytel
    eurekaServerURLContext: eureka
    registerWithEureka: true
    fetchRegistry: true

endpoints:
  enabled: false
  health:
    enabled: true
```

Here are the important parts :-

1. `useDnsForFetchingServiceUrls` This must be true for DNS based configuration
2. `eurekaServerDNSName` This is the suffix added to the DNS requests, so must match the records you create
3. `eurekaServerURLContext` This is the url added to the servers returned from DNS. e.g. `eureka01.storytel.local` will become `http://eureka01.storytel.local/eureka`
4. `eurekaServerPort` This is the port added to the servers returned from DNS. Important if you run a non-standard port.

In addition to these values you bake in to your config, there are some additional properties you should set. We do that via environment variables which can be used to add/override any value in `application.yml`

1. `EUREKA_INSTANCE_HOSTNAME` The hostname for this instance
2. `EUREKA_INSTANCE_IP_ADDRESS` The ip address for this instance
3. `EUREKA_CLIENT_REGION` The region this instance is running in

### What's the deal with regions

A Eureka topology is modeled as `Region > Datacenter > Instance` on amazon this might be `us-east > us-east-1 > eurkeka01` on digital ocean this may be `ams > ams2 > eureka01`

This is important to understand as it is used when the Eureka client queries DNS.

### DNS TXT records

Eureka will start by querying the TXT records for your region `txt.<region>.<eurekaServerDNSName>` eg `txt.us-east.eureka.storytel` where it will expect to find one value for each datacenter in the region `us-east-1.eureka.storytel`.  
It will then make another TXT lookup this time for `txt.<datacenter>` e.g. `txt.us-east-1.eureka.storytel` where it will expect to find one value for each instance in the datacenter `eureka01.us-east-1.eureka.storytel`, `eureka02.us-east-1.eureka.storytel`.

### How to add the TXT records

This will depend heavily on your environment. We use [dnsmasq](http://www.thekelleys.org.uk/dnsmasq/doc.html) which you can also read about on my blog [here]({% post_url 2016-09-03-running-dnsmasq-in-docker %}).
