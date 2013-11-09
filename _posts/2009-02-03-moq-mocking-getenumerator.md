---
title: Moq&#58; Mocking GetEnumerator()
layout: post
permalink: /2009/02/moq-mocking-getenumerator.html
tags: mocks unittest C# dotnet
guid: tag:blogger.com,1999:blog-25631453.post-224811709119718087
tidied: true
---

In my last post I made mention that it was easier not to use the Enumerators on HTTP context objects when you want to unit test with mocking. This is due to some annoyances with casting (as they predate generics) that can be avoided with simple `for()` loops instead of `foreach()`.

Today however, I am going to look at mocking `GetEnumerator()` in a more general sense should you ever need it.

<!-- more -->
  
We start with a simple "business object" that iterates over a set of products returning a list of their names. Nice useless test code as always.  

```csharp
public class BizProducts
{
   private IProductsRepository db;

   public BizProducts(IProductsRepository repository) {
       db = repository;
   }

   public string List() {
       StringBuilder sb = new StringBuilder();
       foreach (Product p in db) {
           sb.AppendLine(p.ProductName);
       }

       return sb.ToString();
   }
}
```

The business object expects to be passed its data store rather than creating the instance itself. This has two benefits, it becomes far easier to unit test as we can pass in a mocked set of data rather than the concrete class used in the real code, and we can also plug it into a dependency injection framework easily.

The product repository interface and the underlying product class look like this. Note that the `IProductsRepository` implements the `IEnumerable<Product>` interface, which exposes a strongly typed `GetEnumerator()` method rather than the older object one. This comes from `System.Collections.Generic`.

```csharp
public interface IProductsRepository : IEnumerable<Product>
{
}

public class Product
{
    public int ProductID { get; set; }

    public string ProductName { get; set; }
}
```
  
Now a concrete implementation of the `IProductsRepository` is likely to connect to SQL Server for its data, but this can be a pain with unit testing as it requires every developer who is sharing tests to have consistent data that can be coded into the unit tests. It also means a test for the business object needs to rely on a bug free data layer to succeed. It is better to test one thing at a time, leave testing the data layer to the data layer tests. This means we need to mock the data layer in business object tests, which means we need to sort out mocking the implicit `GetEnumerator()` called by the `foreach()` loop.  

Here is a unit test you can use that will mock the `IProductsRepository` interface using [Moq](http://code.google.com/p/moq/). 

```csharp
[TestClass]
public class BizProductsTests
{

    [TestMethod]
    public void TestList() {
        Mock<IProductsRepository> repository = new Mock<IProductsRepository>();
        repository.Expect(d => d.GetEnumerator()).Returns(ProductList());
        
        BizProducts biz = new BizProducts(repository.Object);

        string s = biz.List();
        Assert.AreEqual("First Product\r\nSecond Product\r\n", s);
    }

    public IEnumerator<Product> ProductList() {
        yield return new Product() { ProductID = 1, ProductName = "First Product" };
        yield return new Product() { ProductID = 2, ProductName = "Second Product" };
    }
}
```

Line 7 sets up the expectation that the `GetEnumerator()` method should return the `IEnumerator<Product>` returned by the `ProductList()` method. It turns out one of the easiest ways to get your hands on an enumerator is with the lovely [yield]({% post_url 2008-05-07-keyword %}) statement. Better yet since it comes out of a method, you could set this list of products up once and use it through all appropriate unit tests.

Another option not shown here is by using a generic collection such as `List<Product>` to store your products, and then return its `GetEnumerator()`, make sure you use a collection from `System.Collections.Generic` though, older collections will not implement the generic `IEnumerable<>` interface.

I prefer the `yield` method as it is simpler to set up and keeps the actual unit test code shorter, but if you need to inspect the underlying objects afterwards or prefer to keep the code all in one place than the `List<>` option would be the way to go.  
