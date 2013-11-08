---
title: LINQ to SQL&#58; Insert/Update/Delete
layout: post
permalink: /2008/01/linq-to-sql-insertupdatedelete.html
tags: linqtosql dotnet
guid: tag:blogger.com,1999:blog-25631453.post-1879691198447788410
tidied: true
---

I have been looking at my web stats for the recent run of LINQ-to-SQL posts, and it seems a lot of people are making their way here from searches about some of the more standard features of LINQ-to-SQL. In the interest of addressing these visitors I am going to put together a post that covers the basics of data access.
Make sure you see my earlier post about setting up the AdventureWorks database [here]({% post_url 2007-12-27-linq-to-sql-prep-work %}).  
First we will look at a complicated `INSERT`, adding a new customer to the AdventureWorks database.  
**Note:** This is not a very good example from the standpoint of keeping the AdventureWorks database clean and correct, we are only interested in meeting each of the SQL Constraints, not the business logic.

```csharp
AdventureWorksDataContext db = new AdventureWorksDataContext();
db.Log = Console.Out;

// LINQ query to get StateProvince
StateProvince state = (from states in db.StateProvinces
                       where states.CountryRegionCode == "AU" && states.StateProvinceCode == "NSW"
                       select states).FirstOrDefault();
// LINQ function to get AddressType
AddressType addrType = db.AddressTypes.FirstOrDefault(s => s.Name == "Home");

Customer newCustomer = new Customer()
{
    ModifiedDate= DateTime.Now,
    AccountNumber= "AW12354", 
    CustomerType='I',
    rowguid= Guid.NewGuid(),
    TerritoryID= state.TerritoryID    // Relate record by Keys
};
Contact newContact = new Contact()
{
    Title = "Mr",
    FirstName = "New",
    LastName = "Contact",
    EmailAddress = "newContact@company.com",
    Phone = "(12) 3456789", 
    PasswordHash= "xxx",
    PasswordSalt= "xxx",
    rowguid = Guid.NewGuid(),
    ModifiedDate = DateTime.Now
};
Individual newInd = new Individual()
{
    Contact= newContact,    // Relate records by objects (we dont actually know the Keys for the new records yet)
    Customer= newCustomer,
    ModifiedDate= DateTime.Now
};
Address newAddress = new Address()
{
    AddressLine1= "12 First St",
    City= "Sydney",
    PostalCode= "2000", 
    ModifiedDate=DateTime.Now,
    StateProvince= state,
    rowguid = Guid.NewGuid()
};

// Link our customer with their address via a new CustomerAddress record
newCustomer.CustomerAddresses.Add(new CustomerAddress() { Address = newAddress, Customer = newCustomer, AddressType = addrType, ModifiedDate = DateTime.Now, rowguid = Guid.NewGuid() });

// Save changes to the database
db.SubmitChanges();

Console.WriteLine("Customer ID - " + newCustomer.CustomerID.ToString());
```


This code generates and executes the following SQL.

```sql
SELECT TOP (1) [t0].[StateProvinceID], [t0].[StateProvinceCode], [t0].[CountryRegionCode], [t0].[IsOnlyStateProvinceFlag], [t0].[Name], [t0].[TerritoryID], [t0].[rowguid], [t0].[ModifiedDate]
FROM [Person].[StateProvince] AS [t0]
WHERE ([t0].[CountryRegionCode] = @p0) AND ([t0].[StateProvinceCode] = @p1)
-- @p0: Input NVarChar (Size = 2; Prec = 0; Scale = 0) [AU]
-- @p1: Input NVarChar (Size = 3; Prec = 0; Scale = 0) [NSW]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

SELECT TOP (1) [t0].[AddressTypeID], [t0].[Name], [t0].[rowguid], [t0].[ModifiedDate]
FROM [Person].[AddressType] AS [t0]
WHERE [t0].[Name] = @p0
-- @p0: Input NVarChar (Size = 4; Prec = 0; Scale = 0) [Home]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

INSERT INTO [Person].[Address]([AddressLine1], [AddressLine2], [City], [StateProvinceID], [PostalCode], [rowguid], [ModifiedDate])
VALUES (@p0, @p1, @p2, @p3, @p4, @p5, @p6)

SELECT CONVERT(Int,SCOPE_IDENTITY()) AS [value]
-- @p0: Input NVarChar (Size = 11; Prec = 0; Scale = 0) [12 First St]
-- @p1: Input NVarChar (Size = 0; Prec = 0; Scale = 0) [Null]
-- @p2: Input NVarChar (Size = 6; Prec = 0; Scale = 0) [Sydney]
-- @p3: Input Int (Size = 0; Prec = 0; Scale = 0) [50]
-- @p4: Input NVarChar (Size = 4; Prec = 0; Scale = 0) [2000]
-- @p5: Input UniqueIdentifier (Size = 0; Prec = 0; Scale = 0) [75061158-10f5-4fbc-8ab8-afaac45432ec]
-- @p6: Input DateTime (Size = 0; Prec = 0; Scale = 0) [2/01/2008 11:34:04 AM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

INSERT INTO [Sales].[Customer]([TerritoryID], [CustomerType], [rowguid], [ModifiedDate])
VALUES (@p0, @p1, @p2, @p3)

SELECT [t0].[CustomerID], [t0].[AccountNumber]
FROM [Sales].[Customer] AS [t0]
WHERE [t0].[CustomerID] = (SCOPE_IDENTITY())
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [9]
-- @p1: Input NChar (Size = 1; Prec = 0; Scale = 0) [I]
-- @p2: Input UniqueIdentifier (Size = 0; Prec = 0; Scale = 0) [6aa7321f-97ed-4374-bb4f-1dbade6c54b3]
-- @p3: Input DateTime (Size = 0; Prec = 0; Scale = 0) [2/01/2008 11:34:04 AM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

INSERT INTO [Sales].[CustomerAddress]([CustomerID], [AddressID], [AddressTypeID], [rowguid], [ModifiedDate])
VALUES (@p0, @p1, @p2, @p3, @p4)
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [29487]
-- @p1: Input Int (Size = 0; Prec = 0; Scale = 0) [32529]
-- @p2: Input Int (Size = 0; Prec = 0; Scale = 0) [2]
-- @p3: Input UniqueIdentifier (Size = 0; Prec = 0; Scale = 0) [7b475a95-eb2b-42bb-9291-2f75d3afb9c6]
-- @p4: Input DateTime (Size = 0; Prec = 0; Scale = 0) [2/01/2008 11:34:04 AM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

INSERT INTO [Person].[Contact]([NameStyle], [Title], [FirstName], [MiddleName], [LastName], [Suffix], [EmailAddress], [EmailPromotion], [Phone], [PasswordHash], [PasswordSalt], [AdditionalContactInfo], [rowguid], [ModifiedDate])
VALUES (@p0, @p1, @p2, @p3, @p4, @p5, @p6, @p7, @p8, @p9, @p10, @p11, @p12, @p13)

SELECT CONVERT(Int,SCOPE_IDENTITY()) AS [value]
-- @p0: Input Bit (Size = 0; Prec = 0; Scale = 0) [False]
-- @p1: Input NVarChar (Size = 2; Prec = 0; Scale = 0) [Mr]
-- @p2: Input NVarChar (Size = 3; Prec = 0; Scale = 0) [New]
-- @p3: Input NVarChar (Size = 0; Prec = 0; Scale = 0) [Null]
-- @p4: Input NVarChar (Size = 7; Prec = 0; Scale = 0) [Contact]
-- @p5: Input NVarChar (Size = 0; Prec = 0; Scale = 0) [Null]
-- @p6: Input NVarChar (Size = 22; Prec = 0; Scale = 0) [newContact@company.com]
-- @p7: Input Int (Size = 0; Prec = 0; Scale = 0) [0]
-- @p8: Input NVarChar (Size = 12; Prec = 0; Scale = 0) [(12) 3456789]
-- @p9: Input VarChar (Size = 3; Prec = 0; Scale = 0) [xxx]
-- @p10: Input VarChar (Size = 3; Prec = 0; Scale = 0) [xxx]
-- @p11: Input Xml (Size = 0; Prec = 0; Scale = 0) [System.Data.SqlTypes.SqlXml]
-- @p12: Input UniqueIdentifier (Size = 0; Prec = 0; Scale = 0) [85ae7a1f-fdc9-4b20-b8aa-0ca6a8007022]
-- @p13: Input DateTime (Size = 0; Prec = 0; Scale = 0) [2/01/2008 11:34:04 AM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

INSERT INTO [Sales].[Individual]([CustomerID], [ContactID], [Demographics], [ModifiedDate])
VALUES (@p0, @p1, @p2, @p3)
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [29487]
-- @p1: Input Int (Size = 0; Prec = 0; Scale = 0) [19980]
-- @p2: Input Xml (Size = 0; Prec = 0; Scale = 0) [System.Data.SqlTypes.SqlXml]
-- @p3: Input DateTime (Size = 0; Prec = 0; Scale = 0) [2/01/2008 11:34:04 AM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

Customer ID - 29487
```


One of the first things to know is that `SubmitChanges()` will wrap up all of the changes you have made to the database and submit them as a single transaction, this is good news because if any of them changes fail, they all fail. (Exceptions are thrown to catch failures).  
You may note the lack of any explicit `InsertOnSubmit()` calls, these are largely optional, though there are benefits from using them that you will see further down in the `DELETE` example.

Running through the code snippet, you will see that the first thing we do is find a `StateProvince` record and an `AddressType` record, these are required to give the appropriate foreign keys to our `Address` record.  
Creating a new record keeps with the mind set of working with objects, so you simply create a new object of the appropriate record type and set its properties.  
When linking two records together, you have two choices, both of which I have given an example of. If you know the keys involved in the relationship you can explicitly set the Foreign Key field eg `TerritoryID = state.TerritoryID`. 

However, you do not always know the key, especially if the record has just been created, so you can actually link two objects together and LINQ-to-SQL will work out the keys for you. You can see this best when I create the `Individual` record and attach it to `newContact` and `newCustomer`, neither of which is in the database yet, and hence neither has a Primary Key.

The `CustomerAddress` table is a Many-to-Many relationship table between `Customer` and `Address`. We can add a new record to it directly or via the `CustomerAddresses` collection that is on both `Customer` and `Address` records. I have used in-line syntax to create this record simply to show off another way of structuring your code.  
Right at the end we write out the Primary Key for the `Customer` record, to show that LINQ-to-SQL will automatically query this value after it has inserted the record and pop it onto the object. Very useful.  
The other cool feature here is that the order of the SQL statements is decided for you to ensure that all of the keys can be correctly set without tripping up the constraints along the way.  
Update statements are even simpler, again keeping with the mindset of working with objects we simply get an object representing a row, changes it properties and save it back.

```csharp
AdventureWorksDataContext db = new AdventureWorksDataContext();
db.Log = Console.Out;

// Get hte first customer record
Customer c = (from cust in db.Customers select cust).FirstOrDefault();
Console.WriteLine(c.CustomerType);
c.CustomerType = 'I';
db.SubmitChanges(); // Save the changes away
```

```sql
SELECT TOP (1) [t0].[CustomerID], [t0].[TerritoryID], [t0].[AccountNumber], [t0].[CustomerType], [t0].[rowguid], [t0].[ModifiedDate]
FROM [Sales].[Customer] AS [t0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

S
UPDATE [Sales].[Customer]
SET [CustomerType] = @p5
WHERE ([CustomerID] = @p0) AND ([TerritoryID] = @p1) AND ([CustomerType] = @p2) AND ([rowguid] = @p3) AND ([ModifiedDate] = @p4)

SELECT [t1].[AccountNumber]
FROM [Sales].[Customer] AS [t1]
WHERE ((@@ROWCOUNT) > 0) AND ([t1].[CustomerID] = @p6)
-- @p0: Input Int (Size = 0; Prec = 0; Scale = 0) [1]
-- @p1: Input Int (Size = 0; Prec = 0; Scale = 0) [1]
-- @p2: Input NChar (Size = 1; Prec = 0; Scale = 0) [S]
-- @p3: Input UniqueIdentifier (Size = 0; Prec = 0; Scale = 0) [3f5ae95e-b87d-4aed-95b4-c3797afcb74f]
-- @p4: Input DateTime (Size = 0; Prec = 0; Scale = 0) [13/10/2004 11:15:07 AM]
-- @p5: Input NChar (Size = 1; Prec = 0; Scale = 0) [I]
-- @p6: Input Int (Size = 0; Prec = 0; Scale = 0) [1]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8
```

Now for a `DELETE`, first we will create a record that we can later delete. This will show you why using `InsertOnSubmit()` explicity can be a good idea.

```csharp
AdventureWorksDataContext db = new AdventureWorksDataContext();
db.Log = Console.Out;
Console.WriteLine("Count Start - " + db.Currencies.Count().ToString());
Currency c = new Currency()
{
    CurrencyCode = "XXX",
    Name = "My Currency",
    ModifiedDate = DateTime.Now
};
db.Currencies.InsertOnSubmit(c);
db.SubmitChanges();
Console.WriteLine("Count Middle - " + db.Currencies.Count().ToString());

db.Currencies.DeleteOnSubmit(c);
db.SubmitChanges();
Console.WriteLine("Count End - " + db.Currencies.Count().ToString());
```

```sql
SELECT COUNT(*) AS [value]
FROM [Sales].[Currency] AS [t0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

Count Start - 105
INSERT INTO [Sales].[Currency]([CurrencyCode], [Name], [ModifiedDate])
VALUES (@p0, @p1, @p2)
-- @p0: Input NChar (Size = 3; Prec = 0; Scale = 0) [XXX]
-- @p1: Input NVarChar (Size = 11; Prec = 0; Scale = 0) [My Currency]
-- @p2: Input DateTime (Size = 0; Prec = 0; Scale = 0) [2/01/2008 12:09:17 PM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

SELECT COUNT(*) AS [value]
FROM [Sales].[Currency] AS [t0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

Count Middle - 106
DELETE FROM [Sales].[Currency] WHERE ([CurrencyCode] = @p0) AND ([Name] = @p1) AND ([ModifiedDate] = @p2)
-- @p0: Input NChar (Size = 3; Prec = 0; Scale = 0) [XXX]
-- @p1: Input NVarChar (Size = 11; Prec = 0; Scale = 0) [My Currency]
-- @p2: Input DateTime (Size = 0; Prec = 0; Scale = 0) [2/01/2008 12:09:17 PM]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

SELECT COUNT(*) AS [value]
FROM [Sales].[Currency] AS [t0]
-- Context: SqlProvider(Sql2005) Model: AttributedMetaModel Build: 3.5.21022.8

Count End - 105
```

You may notice here that I have used `InsertOnSumbit()` when creating my currency record to be deleted, this is because by doing this you "attach" the object to the database, which is required to do some operations with that object later on, such as `DeleteOnSubmit()`. It was not required in my `Insert()` example however. If you attempt to use `DeleteOnSubmit()` with an object that is not attached to your data context, it will throw an exception.  
There is also a `DeleteAllOnSubmit()` method which takes a collection of records to be deleted.

So there you have it, a quick look at three basic functions. The one of real interest should be the `INSERT` statements and how you link up a complex set of related objects to insert into the database.

I will have another post similar to this next that looks at functions like `Count()`, `Sum()`, `Average()` etc. Again I have had some hits from people looking for examples of these so I feel I should cover them off before moving on to future topics.
