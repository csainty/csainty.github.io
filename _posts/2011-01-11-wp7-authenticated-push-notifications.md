---
title: WP7 - Authenticated Push Notifications
layout: post
permalink: /2011/01/wp7-authenticated-push-notifications.html
tags: gReadie wp7dev wp7 C# dotnet
id: tag:blogger.com,1999:blog-25631453.post-3005825471432915718
---


This post is going to offer a few tips about changing your Windows Phone 7 push notification service from unauthenticated to authenticated.  
  
Specifically it will focus on the challenges I ran into hosting a WCF service, in IIS7 on a cheap shared hosting account.  
  
It will not be a full step by step tutorial, there are a lot of those out there, though I found many missed a few steps. If you are starting out, see the [MSDN](http://msdn.microsoft.com/en-us/library/ff941099.aspx) documentation.  
  
The reason you will want an authenticated service is that it allows you to send an unlimited amount of updates to the phone. If the service is not authenticated it will be limited to 500 per device per day. Which might be plenty for some services, but was not going to be enough for me. Users do not like their Live Tiles pausing for half a day simply because they are a heavy user.  
  
To authenticate your service, you need to add an SSL certificate to your web server and then upload a copy to your Windows Phone developer account. When it comes time to submit your application to the marketplace, you choose this certificate in the submission process and it becomes live in the Microsoft systems.  
  
Your hosting provider should have a standard process to do this, you just need to make sure they send you a copy of the certificate.  
  
The certificate I used came from [RapidSSL](http://www.rapidssl.com/) and was just the default option for my hosting provider. Microsoft does have a list of [valid providers](http://msdn.microsoft.com/en-us/library/gg521150.aspx), so be sure to check.  
  
#### Problem #1 - Adding an SSL endpoint to an IIS7 WCF Service
  
The first problem you will come up against is that when WCF generates a WSDL for your secure service, it will pick up the machine name of the box it is on, and not your domain name.  
  
This is a very widely talked about problem, and the usually offered solution is to run some vbs script that adds an SSL host header to your website because the IIS interface itself can not add host headers to SSL bindings.  
  
What is not very well talked about is how to manage this on shared hosting. As helpful as my support guy was, he was not keen on running some random piece of vbs script for me.  
  
So the real solution is actually to use a new (4.0) setting in the web.config file called "useRequestHeadersForMetadataAddress", if you are not on a host that supports 4.0, find one that does.  
  ```
   <behaviors>

      <serviceBehaviors>

          <behavior>

              <useRequestHeadersForMetadataAddress>

                  <defaultPorts>

                      <add port="443" scheme="https" />

                  </defaultPorts>

              </useRequestHeadersForMetadataAddress>

              <serviceMetadata httpGetEnabled="false" httpsGetEnabled="false" />

              <serviceDebug includeExceptionDetailInFaults="false" />

          </behavior>

      </serviceBehaviors>

  </behaviors>
```




You also need to turn on Transport security for your binding. Though this is standard WCF, nothing special here.  


```

  <bindings>

      <basicHttpBinding>

          <binding>

              <security mode="Transport" />

          </binding>

      </basicHttpBinding>

  </bindings>
```




On the phone, if you grab the metadata from your secure service, then it should point everything correctly, but if you need to do it by hand, the service configuration file will be along these lines.  


```

  <system.serviceModel>

      <bindings>

          <basicHttpBinding>

              <binding 

                      name="BasicHttpBinding_Service"

                      maxBufferSize="2147483647"

                      maxReceivedMessageSize="2147483647">

                  <security mode="Transport" />

              </binding>

          </basicHttpBinding>

      </bindings>

      <client>

          <endpoint address="https://[yourservicedomain]/[yourservicename].svc"

                              binding="basicHttpBinding" 

                              bindingConfiguration="BasicHttpBinding_Service"

                              contract="[ContractName]" 

                              name="BasicHttpBinding_Service" />

      </client>

  </system.serviceModel>
```






Note the Transport security on line 8 and the https address on line 13.  



#### Problem #2 - (403) Forbidden



The next problem you will encounter, is that when you actually POST your notification to the Microsoft servers you will get a (403) Forbidden response back.  



I could not find a single piece of Microsoft documentation on this, and a single obscure reference on a forum finally pointed me in the right direction.  



When you make your POST, you actually need to attach the certificate to it. Microsoft will then match this against the one you uploaded to them to ensure you are who you say you are.  



You do this using the ClientCertificates collection on your HTTP Request.  


```

  // Standard header code

   

  request.ClientCertificates.Add(new X509Certificate2("[Path To Certificate]", "[Password]"));

   

  using (Stream requestStream = request.GetRequestStream()) {

      requestStream.Write(payload, 0, payload.Length);

  }

   

  WebResponse response = request.GetResponse();
```






Once this is added in you should be finally able to send authenticated push notifications.  



Hopefully this saves a few people some time as I pulled my hair out over the course of a weekend solving both of these.  
  