---
title: Moq: Mocking GetEnumerator()
layout: post
permalink: /2009/02/moq-mocking-getenumerator.html
tags: mocks unittest C# dotnet
---


In my last post I made mention that it was easier not to use the Enumerators on HTTP context objects when you want to unit test with mocking. This is due to some annoyances with casting (as they predate generics) that can be avoided with simple for() loops instead of foreach().  
  
Today however, I am going to look at mocking GetEnumerator() in a more general sense should you ever need it. Also for the first time I am going to pop the code onto SkyDrive and include line numbers in my code snippets.  
  
We start with a simple "business object" that iterates over a set of products returning a list of their names. Nice useless test code as always.  
          `   1: public class BizProducts`


    `   2: {`


    `   3:     private IProductsRepository db;`


    `   4:  `


    `   5:     public BizProducts(IProductsRepository repository) {`


    `   6:         db = repository;`


    `   7:     }`


    `   8:  `


    `   9:     public string List() {`


    `  10:         StringBuilder sb = new StringBuilder();`


    `  11:         foreach (Product p in db) {`


    `  12:             sb.AppendLine(p.ProductName);`


    `  13:         }`


    `  14:         return sb.ToString();`


    `  15:     }`


    `  16: }`

  



The business object expects to be passed its data store rather than creating the instance itself. This has two benefits, it becomes far easier to unit test as we can pass in a mocked set of data rather than the concrete class used in the real code, and we can also plug it into a dependency injection framework easily.  



The product repository interface and the underlying product class look like this. Note that the IProductsRepository implements the IEnumerable<Product> interface, which exposes a strongly typed GetEnumerator() method rather than the older object one. This comes from System.Collections.Generic  



  
    `   1: public interface IProductsRepository : IEnumerable<Product>`


    `   2: {`


    `   3: }`


    `   4:  `


    `   5: public class Product`


    `   6: {`


    `   7:     public int ProductID { get; set; }`


    `   8:     public string ProductName { get; set; }`


    `   9: }`

  



Now a concrete implementation of the IProductsRepository is likely to connect to SQL Server for its data, but this can be a pain with unit testing as it requires every developer who is sharing tests to have consistent data that can be coded into the unit tests. It also means a test for the business object needs to rely on a bug free data layer to succeed. It is better to test one thing at a time, leave testing the data layer to the data layer tests. This means we need to mock the data layer in business object tests, which means we need to sort out mocking the implicit GetEnumerator() called by the foreach() loop.  



Here is a unit test you can use that will mock the IProductsRepository interface using [Moq](http://code.google.com/p/moq/)   



  
    `   1: [TestClass]`


    `   2: public class BizProductsTests`


    `   3: {`


    `   4:     [TestMethod]`


    `   5:     public void TestList() {`


    `   6:         Mock<IProductsRepository> repository = new Mock<IProductsRepository>();`


    `   7:         repository.Expect(d => d.GetEnumerator()).Returns(ProductList());`


    `   8:         BizProducts biz = new BizProducts(repository.Object);`


    `   9:  `


    `  10:         string s = biz.List();`


    `  11:         Assert.AreEqual("First Product\r\nSecond Product\r\n", s);`


    `  12:     }`


    `  13:  `


    `  14:     public IEnumerator<Product> ProductList() {`


    `  15:         yield return new Product() { ProductID = 1, ProductName = "First Product" };`


    `  16:         yield return new Product() { ProductID = 2, ProductName = "Second Product" };`


    `  17:     }`


    `  18: }`

  



Line 7 sets up the expectation that the GetEnumerator() method should return the IEnumerator<Product> returned by the ProductList() method. It turns out one of the easiest ways to get your hands on an enumerator is with the lovely [yield](http://csainty.blogspot.com/2008/05/keyword.html) statement. Better yet since it comes out of a method, you could set this list of products up once and use it through all appropriate unit tests.

  Another option not shown here is by using a generic collection such as List<Product> to store your products, and then return its GetEnumerator(), make sure you use a collection from System.Collections.Generic though, older collections will not implement the generic IEnumerable<> interface.

  I prefer the yield method as it is simpler to set up and keeps the actual unit test code shorter, but if you need to inspect the underlying objects afterwards or prefer to keep the code all in one place than the List<> option would be the way to go.  



Here is the link to the hopefully working solution file on SkyDrive.  



  
  