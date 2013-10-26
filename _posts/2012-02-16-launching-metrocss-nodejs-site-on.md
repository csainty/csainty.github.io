---
title: Launching a Metro.css + Node.js site on AppHarbor
layout: post
permalink: /2012/02/launching-metrocss-nodejs-site-on.html
tags: open-source node appharbor code52
---


Last week I contributed a tiny piece of code to the [Code52](http://code52.org/) [Metro.css](https://github.com/Code52/metro.css) project. My contribution was a node script that creates a boilerplate Node.js website for you using the Metro.css styles, Express and wires up the LESS compilation.  
  
Today I am going to run you through using this code to generate a site and push it to AppHarbor, who now support hosting Node.js sites.  
  
I assume that you have Node.js and npm installed on your dev machine and referenced in the path. All of which should happen if you use the excellent [Windows Installer package](http://nodejs.org/#download).  
  
I also assume you have git installed and that you have created your AppHarbor account and added a new site. I have blogged about doing this [before](http://csainty.blogspot.com/2011/11/tutorial-nancy-mongodb-appharbor.html), their site has been updated since but the process is fairly similar.  
  
While at AppHarbor you will need to do two things. The first is to take a copy of your repository URL, which is now accessed by pressing the button shown in this screenshot.  
  
![AppHbUrl](http://lh5.ggpht.com/-Lw8w6EyPoqM/Tz2FgQpu8rI/AAAAAAAAAKM/uu52ykefOT0/s1600-h/AppHbUrl%25255B2%25255D.png)  
  
The second is to turn on file system write access. You do this from the settings page by enabling the checkbox shown below and hitting update application.  
  
![AppHarborFiles](http://lh6.ggpht.com/-o08v02AsQj0/Tz2FilDeOQI/AAAAAAAAAKY/kDF26B_iEZ4/s1600-h/AppHarborFiles%25255B2%25255D.png)  
  
What this does is allow the LESS compiler to generate and cache CSS files on demand, rather than having to compile them in a build step.  
  
Now let’s jump to the command line.  
  
First we need to clone the metro.css repo from GitHub and jump into the node folder, which contains the scripts we need.  
     
git clone https://github.com/Code52/metro.css.git      cd metro.css/node  
   
Now we need to use npm to install the dependencies required by the script.  
     
npm install  
   
Next we generate our site, change to the generated folder and install the dependencies for our site.  
     
node metro –i c:\projects\metrosite      cd \projects\metrosite       npm install  
   
Simple as that, our site has been generated and is ready to be deployed. This whole process will look something like this.  
  
![SiteCreation](http://lh4.ggpht.com/-288qWcNqOGM/Tz2FlX2F5cI/AAAAAAAAAKs/y7vyOk_czdc/s1600-h/SiteCreation%25255B2%25255D.png)  
  
If you want to see it running locally, just fire it up (node app.js) and point your browser to localhost using the port specified.  
  
![Running Locally](http://lh6.ggpht.com/-Ibgz8Wla7LM/Tz2FoJS4zsI/AAAAAAAAAK8/E-cOaUyEAMs/s1600-h/Running%252520Locally%25255B2%25255D.png)  
  
So to deploy to AppHarbor, we need to first create a git repository for our site, commit the changes and then push this commit up to AppHarbor. From the folder that contains our generated site (c:\projects\metrosite in my example) we do the following.  
     
git init     git add .      git commit –m “Initial commit”      git remote add origin <YOUR APPHARBOUR REPOSITORY URL>      git push origin master  
   
Which will look something like this, though I supressed the commit output for the purposes of the screenshot.  
  
![GitCLI](http://lh5.ggpht.com/-E9BlL3c237E/Tz2FqXrqIXI/AAAAAAAAALI/7H6lvMIybLc/s1600-h/GitCLI%25255B2%25255D.png)  
  
This sends your site up to AppHarbor, where it is loaded up and made live.  
  
Back at AppHarbor, your application page will show the current build status. Usually the build will be fairly instant, but if the Status column has a little spinning indicator, then you will need to wait for the build to complete. Give it the occasional refresh.  
  
![BuildStatus](http://lh3.ggpht.com/-gdzGRUmHbe0/Tz2Fsi6LTOI/AAAAAAAAALY/Dz2ESX5tLuc/s1600-h/BuildStatus%25255B2%25255D.png)  
          
When that is done, click the “Go to your application link” and marvel at your creation.  
  
![MetroSite](http://lh5.ggpht.com/-M7qNvCM_uro/Tz2Fum5du3I/AAAAAAAAALs/UXmvnZ8kFMI/s1600-h/MetroSite%25255B2%25255D.png)  
  
See my copy live at [http://nodemetro.apphb.com/](http://nodemetro.apphb.com/)  
  