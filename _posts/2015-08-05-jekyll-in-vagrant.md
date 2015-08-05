---
title: Running jekyll with vagrant
layout: post
permalink: /2015/08/jekyll-with-vagrant.html
tags: jekyll vagrant blog
---

For a while now this blog has been built with [Jekyll](http://jekyllrb.com/) which has generally been a very positive experience.  
It has also felt very fragile though. Installed as a set of global gems just waiting to be clobbered by an update.

So it was that I broke the setup one day. Instead of trying to fix it, I decided to isolate the setup inside a vagrant VM. This allows me to port it between machines and reproduce it at will.

<!-- more -->

### Show me the good stuff!

The setup is fully open, you can check it out at [https://github.com/csainty/csainty.github.io](https://github.com/csainty/csainty.github.io).  
In particular see [Vagrantfile](https://github.com/csainty/csainty.github.io/blob/source/Vagrantfile), [v_bootstrap.sh](https://github.com/csainty/csainty.github.io/blob/source/v_bootstrap.sh) [start.sh](https://github.com/csainty/csainty.github.io/blob/source/start.sh) and [publisher.sh](https://github.com/csainty/csainty.github.io/blob/source/publish.sh)

### How it works

If you don't already have it, grab [vagrant](https://www.vagrantup.com/) and [virtualbox](https://www.virtualbox.org/) to host the VM.  
`brew cask install vagrant virtualbox`

When you run `start.sh` it will provision the VM for you and install and configure everything that is needed using the script in `v_bootstrap.sh`. It will then start jekyll's built in webserver and bind it to `http://localhost:4000`.

You'll need a second terminal window to run `vagrant rsync-auto` which is going to sync all the changes you make, so that jekyll can rebuild them with its watch task.

When you are done you can run `publish.sh` which will do a fresh build, then push the built assets to a GitHub branch ready for hosting.

Finallt `stop.sh` will simply shutdown the VM to free up resources.

### Customization
Obviously these scripts and this setup are designed for my blog. It installs the plugins I need and publishes to my repo. So you are going to need to tweak it for your own purposes, but I hope it can help you on the way.
