---
title: ASP.NET MVC&#58; Unit Test File Upload with Moq
layout: post
permalink: /2009/01/aspnet-mvc-unit-test-file-upload-with.html
tags: mocks unittest mvc asp.net csharp dotnet
guid: tag:blogger.com,1999:blog-25631453.post-5896097205359651985
tidied: true
---

Microsoft released the ASP.NET MVC Release Candidate yesterday ([Link](http://go.microsoft.com/fwlink/?LinkID=140768&clcid=0x409)). One thing that pricked my ears in the release notes was a change to the `ControllerContext` that would apparently make it easier to use a mocking tool to unit test actions that needed to interact with the standard HTTP objects.  

<!-- more -->

I gave up on mocking back at Preview 3 of the MVC framework, and instead I was slowly building up a library of classes using the `Http...Base` (eg `HttpRequestBase`) classes that implemented each feature as needed. It was a little bit of work, but at least it did work.  
  
With ScottGu's [example](http://weblogs.asp.net/scottgu/archive/2009/01/27/asp-net-mvc-1-0-release-candidate-now-available.aspx) in hand and a copy of [Moq](http://code.google.com/p/moq/) installed and referenced in my test project I set about replacing my own classes with the appropriate mocks in each test of a project I am working on at the moment. The results were surprisingly good, I am now able to mock every part of the web context I am currently using with ease.  
  
One scenario I was pretty impressed with that I will share with you is mocking the `Request.Files` collection to test uploading files to a site. I will start with a simple Upload method and build a few iterations of the unit test to show what is going on. This isn't a lesson on mocking or unit tests, I have assumed you have some knowledge of both. I am simply showing off a particular mock I was impressed with.  
  
First we need a new ASP.MVC project, we will add an Upload action to the Home controller like so.  

```csharp
public ActionResult Upload() {
    string s = "Uploaded " + Request.Files.Count.ToString() + " files.<br/>\n";
    for (int i = 0; i < Request.Files.Count; i++) {
        using (StreamReader reader = new StreamReader(Request.Files[i].InputStream)) {
            s += String.Format("File {0}: {1}<br/>\n", Request.Files[i].FileName, reader.ReadToEnd());
        }
    }
    return Content(s);
}
```

Obviously not a method you would use, but suits our purposes for demonstration. It simply loops through the files collection and writes out the name and contents of each file in the response. Note: It is easier to test this code with the `for()` loop instead of a `foreach()` as you do not need to mock `GetEnumerator()` which can be clumsy and in this case was struggling with casting.  

If we put together a simple unit test for this, you will soon see the problem.  


```csharp
[TestMethod]
public void TestUpload() {
    HomeController c = new HomeController();
    ActionResult r = c.Upload();
    Assert.IsInstanceOfType(r, typeof(ContentResult));
    Assert.AreNotEqual("", ((ContentResult)r).Content);                        
}
```

This test throws a null exception on the first line of the Upload method because it can not access Request. On top of this problem it is not immediately obvious in your unit test how you even "upload" a file to the action. Because your unit test is not a web request, all the architecture of a usual web call (I am calling it the context through this post) is not created. The whole point of using mocking here is to recreate the part of the context the test needs to be able to succeed. Lets fix one step at a time though.  


Since we are currently failing on `Request.Files.Count`, this will be the first mock we add. It looks like this.  

```csharp
[TestMethod]
public void TestUpload() {
    HomeController c = new HomeController();
    Mock<ControllerContext> cc = new Mock<ControllerContext>();
    cc.Expect(d => d.HttpContext.Request.Files.Count).Returns(2);
    c.ControllerContext = cc.Object;
    
    ActionResult r = c.Upload();
    Assert.IsInstanceOfType(r, typeof(ContentResult));
    Assert.AreNotEqual("", ((ContentResult)r).Content);                        
}
```

The object we want to mock is the `ControllerContext`, it can be attached to the `Controller` and contains all the HTTP classes we need to manipulate to fake a web request.

The syntax of Moq is very concise and provided you know how to read a lambda you will note that I am telling the mock that I expect `HttpContext.Request.Files.Count to return 2`.

The other key part of the Moq syntax is that to get the actual instance of the mocked object you access the `.Object` property. So we assign this to the controller as the context it should use.

If we run this test it still fails, but now it is failing on the first usage of the file inside the for loop. The code now thinks there are two files uploaded, it just couldn't find them when it went looking. If you have never played with mocking before, this simple concept of _"I expect xxx to return yyy"_ will get you a long way improving your unit tests against an MVC website. It is fairly straight forward to mock any part of web context (Request, Response, Server, etc) just like this. But back to file uploads.  

So what we need to do now, is to add two new expectations to the mocked ControllerContext to state that HttpContext.Request.Files[0] should return our first file and that .Files[1] should return our second file. This however begs the question, what exactly do they return. Our code is expecting objects of type HttpPostedFile to be returned from the Files collection, helpfully ASP.NET MVC has included an HttpPostedFileBase class that can be mocked to represent the objects of the Request.Files collection. So we simply need to create two of these, mocking the FileName and InputStream properties we have used in our code to return the relevant details from our test files. Then tell the mocked ControllerContext to return them. Putting this all together looks like this. Note that I am returning .Object again, it is important to understand the difference between the mocking configuration object and the actual instance you should use in your code.  


```csharp
[TestMethod]
public void TestUpload() {
    HomeController c = new HomeController();
    Mock<ControllerContext> cc = new Mock<ControllerContext>();
    UTF8Encoding enc = new UTF8Encoding();

    Mock<HttpPostedFileBase> file1 = new Mock<HttpPostedFileBase>();
    file1.Expect(d => d.FileName).Returns("test1.txt");
    file1.Expect(d => d.InputStream).Returns(new MemoryStream(enc.GetBytes(Resources.UploadTestFiles.test1)));

    Mock<HttpPostedFileBase> file2 = new Mock<HttpPostedFileBase>();
    file2.Expect(d => d.FileName).Returns("test2.txt");
    file2.Expect(d => d.InputStream).Returns(new MemoryStream(enc.GetBytes(Resources.UploadTestFiles.test2)));
                
    cc.Expect(d => d.HttpContext.Request.Files.Count).Returns(2);
    cc.Expect(d => d.HttpContext.Request.Files[0]).Returns(file1.Object);
    cc.Expect(d => d.HttpContext.Request.Files[1]).Returns(file2.Object);
    c.ControllerContext = cc.Object;

    ActionResult r = c.Upload();
    Assert.IsInstanceOfType(r, typeof(ContentResult));
    Assert.AreNotEqual("Uploaded 2 files.<br/>\nFile test1.txt: Contents of test file 1<br/>\nFile test2.txt: Contents of test file 2<br/>", ((ContentResult)r).Content);
```


This test now passes and we can be confident that our action for handling the upload of files is working correctly.


**Note:** To host the actual test files I am uploading I have created a Resource file called UploadTestFiles and added two .txt files to it that are stored under the Resources sub-directory of the unit test project. I have found this to be a useful way to keep control of my test files. Using binary files is even easier than text files as you get direct access as a `Stream`, this saves you the encoding code you see above to turn the string into the Stream needed by the `HttpPostedFile` class.  


So there you have it! Mocking of ASP.NET MVC has come a long way since I last looked at it. Exactly which release each piece of the puzzle dropped in, I can't say, but where we are at now with the Release Candidate is working quite well for me so far.  


If you have had troubles with mocking the web context in ASP.NET MVC previously or simply avoided unit tests for actions that needed it. Now is a good time to take another look.  
  
