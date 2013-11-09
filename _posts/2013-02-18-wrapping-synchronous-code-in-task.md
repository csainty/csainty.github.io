---
title: Wrapping synchronous code in a Task returning method
layout: post
permalink: /2013/02/wrapping-synchronous-code-in-task.html
tags: C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-6213335283032802708
tidied: true
---

Imagine you have an interface.

```csharp
public interface IAsyncCommand
{
  Task ExecuteAsync();
}
```

<!-- more -->

Now imagine you want to implement this interface, but the code to go in there is not actually asynchronous. Neither is it cpu-intensive and requiring it’s own thread. It is just a regular piece of synchronous code.
There are three ways to do this that I know of.


```csharp
public class AsyncCommand1 : IAsyncCommand
{
  public Task ExecuteAsync()
  {
    int x = 2 + 2;
    return Task.FromResult(true);
  }
}

public class AsyncCommand2 : IAsyncCommand
{
  public async Task ExecuteAsync()
  {
    int x = 2 + 2;
  }
}

public class AsyncCommand3 : IAsyncCommand
{
  public Task ExecuteAsync()
  {
    return Task.Run(() => { int x = 2 + 2; })
  }
}
```

So what is the difference between these three?In terms of the IL being generated, the answer is quite a lot. In terms of relative performance though, the following falls strictly into the category of extreme micro-optimization.

#### The code

The first implementation is the most optimal approach. It turns out that Task has an internal constructor that takes a result. So the static FromResult() method is just a public wrapper around that constructor which returns a completed Task with your value. Task<T> is then cast to Task and off we go.

I find the second approach to be the easiest to read because you just need your async and no weird faux-return. This one actually generates quite a bit of IL. You get a full state machine created, it gets initialized and then executed.


```csharp
[AsyncStateMachine(typeof (Class1.<ExecuteAsync>d__0))]
[DebuggerStepThrough]
public Task ExecuteAsync()
{
  Class1.<ExecuteAsync>d__0 stateMachine;
  stateMachine.<>4__this = this;
  stateMachine.<>t__builder = AsyncTaskMethodBuilder.Create();
  stateMachine.<>1__state = -1;
  stateMachine.<>t__builder.Start<Class1.<ExecuteAsync>d__0>(ref stateMachine);
  return stateMachine.<>t__builder.Task;
}

[CompilerGenerated]
[StructLayout(LayoutKind.Auto)]
private struct <ExecuteAsync>d__0 : IAsyncStateMachine
{
  public int <>1__state;
  public AsyncTaskMethodBuilder <>t__builder;
  public Class1 <>4__this;

  void IAsyncStateMachine.MoveNext()
  {
    try
    {
      if (this.<>1__state != -3)
        ;
    }
    catch (Exception ex)
    {
      this.<>1__state = -2;
      this.<>t__builder.SetException(ex);
      return;
    }
    this.<>1__state = -2;
    this.<>t__builder.SetResult();
  }

  [DebuggerHidden]
  void IAsyncStateMachine.SetStateMachine(IAsyncStateMachine param0)
  {
    this.<>t__builder.SetStateMachine(param0);
  }
}

```

That is a lot of generated code just to save me explicitly returning a Task!

The third option generates the code for the lambda, then passes it off to Task. The task is then handed to the scheduler and what happens next will depend on your scheduler. While this option is lighter on code-gen, the hand-off process makes this the slowest option.

#### Performance

I ran a couple of quick and dirty performance checks over these three. In each case firing off the method 100,000 times and blocking on the result in a tight for-loop.The first implementation runs in about 2ms, the second in about 15ms and the third in about 170ms. Like I said, firmly in the realms of micro-optimization.Something interesting to note though is that if you repeat the test with the debugger attached, the third option blows out to more like 30000ms! I guess there is some more context switching going on with the debugger attached which affects the performance.

#### Conclusion

Ideally you want to avoid doing any of this. Your best option is to support both synchronous and asynchronous implementations where appropriate. In practice I am finding that I often need to handle this wrapping process and so it is handy to understand exactly what I am asking of the compiler when I do. It may be a micro-optimization but it costs me nothing to do it the best way!
