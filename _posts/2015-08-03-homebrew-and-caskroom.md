---
title: OSX Automation with Homebrew and Caskroom
layout: post
permalink: /2015/08/homebrew-and-caskroom.html
tags: osx homebrew caskroom
---

In my last post about [dotfiles]({% post_url 2015-07-15-dotfiles %}) I spoke of automating the setup and installation of a new mac.

There are two indepensible tools that deserve mentioning, [Homebrew](http://brew.sh) and [Caskroom](http://caskroom.io).

<!-- more -->

### Homebrew

Many people will already be aware of Homebrew. It is a package manager for OSX that can be used to quickly and simply install tooling  
`brew install git`  
`brew install python`  
`brew install imagemagick`

You can then keep this tooling up to date with a `brew update` to refresh the local cache and `brew upgrade` to find and install the new versions.

### Caskroom

Caskroom extends Homebrew and applies the same ideas to full applications.  
`brew cask install google-chrome`  
`brew cask install atom`  
`brew cask install skype spotify iterm2 vagrant flux`

### Automate all the things

These two simple command line tools make it incredibly easy to write yourself a script that installs all the tooling and applications you need to get your mac up and running. Saving loads of time!
