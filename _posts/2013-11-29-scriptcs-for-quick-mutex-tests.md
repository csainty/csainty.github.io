---
title: ScriptCS for quick Mutex tests
layout: post
permalink: /2013/11/scriptcs-for-quick-mutex-tests.html
tags: csharp dotnet scriptcs
---

I've been looking out for ways to use [ScriptCS](http://scriptcs.net/) in my day-to-day work lately. Each time I do, I am impressed by how much time it saves me.

So today I found myself needing to write some code with a named `Mutex` in C#. ScriptCS to the rescue!

<!-- more -->

#### Don't have ScriptCS?

Pop open a command window and run the following to install [chocolatey](http://chocolatey.org/) then use that to install scriptcs.

```bash
@powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin

cinst scriptcs
```

Done!  
*While you are there, why not install a few other chocolatey packages, I use it for [node](http://chocolatey.org/packages/nodejs.install), [git](http://chocolatey.org/packages/git.install), [mercurial](http://chocolatey.org/packages/hg), [sourcetree](http://chocolatey.org/packages/SourceTree), [sublime](http://chocolatey.org/packages/SublimeText2.app), [fiddler](http://chocolatey.org/packages/fiddler4), [console2](http://chocolatey.org/packages/Console2), [beyond compare](http://chocolatey.org/packages/beyondcompare), [ravendb](http://chocolatey.org/packages/RavenDB) and more. I even use it for the [SourceCodePro](http://chocolatey.org/packages/SourceCodePro) font. Seriously. It takes me just minutes to rebuild my dev machine from a base VM. Love it.*

#### So how does it help?
Let's start with a basic `Mutex` pattern that I was adding to some code today.

```csharp
using (var mutex = new Mutex(false, @"Global\MyTestApp-MyCriticalSection"))
{
    mutex.WaitOne();

    // Do some work

    mutex.ReleaseMutex();
}
```

After writing this code I wanted to run a few smoke tests over it. Make sure it was behaving in the ways I expected it to. The problem is that running two actual instances of this project isn't easy. Worse, synchronizing the two processes to hit the critical section together is even harder. Enter scriptcs.

```csharp
c:\>scriptcs

> using System.Threading;
> var mutex = new Mutex(false, @"Global\MyTestApp-MyCriticalSection");
```

I now have a reference to the same `Mutex` sitting in my command window that I can `WaitOne()` or `ReleaseMutex()` at any time that suits me. So I simply fire up the application with debugging and step through the critical section a couple of times while retaining complete control of the other "process" with whom we are racing.

It's simple and fast. I don't need to create a new project or learn a new scripting language. I can literally copy and paste the lines I needed straight from my source.
