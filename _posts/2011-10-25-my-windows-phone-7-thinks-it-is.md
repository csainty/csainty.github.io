---
title: My Windows Phone 7 thinks it is developer locked?
layout: post
permalink: /2011/10/my-windows-phone-7-thinks-it-is.html
tags: gReadie wp7dev wp7
---


I ran into an interesting problem today that warrants a blog post to hopefully help someone searching when they hit it themselves.  
  
Last night, I turned on my phone only to be greeted with a helpful message informing me that my application gReadie had been revoked by Microsoft and that I should uninstall it.  
  
After a moment of panic, I realised that I didn’t actually have a retail copy of gReadie installed on my phone, just the developer build I had been working on. So I didn’t think a lot more about it intending just to copy a new version on when I arrived at the office this morning.  
  
That plan failed though when Visual Studio informed me my device was developer locked, and I could not deploy my application.  
  
Strange.  
  
So I ran the developer unlock tool, it connected to App Hub, then to my device and said my phone was unlocked again. Great, back into Visual Studio, and up pops the same error.  
  
After a quick tweet to vent my frustration, I gave everything a reboot, unlocked again, and still no luck.  
  
At this point I logged into App Hub, to check my registration was still valid and see what was up with my device.   
  
To do this, click you name in the top right corner, then choose the devices tab.  
  
Bingo!  
  
Chris’ Phone, Registered 24th Oct 2010, Expiration Date  24th Oct 2011.  
  
My unlock registration had expired, and the phone unlock tool shipped with the phone tools does not renew it.  
  
So I simply hit the remove button inside App Hub, went through the unlock tool once more, and everything was working again.  
  
   
  
So keep this in mind as you approach your one year anniversary of owning an unlocked WP7 device. You will need to pop into App Hub and renew the unlock registration yourself.  
  