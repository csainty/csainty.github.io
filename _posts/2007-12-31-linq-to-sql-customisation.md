---
title: LINQ to SQL&#58; Customisation
layout: post
permalink: /2007/12/linq-to-sql-customisation.html
tags: linqtosql dotnet
guid: tag:blogger.com,1999:blog-25631453.post-5079852828439295144
---

Before we proceed, this is a good time to see another feature of LINQ-to-SQL which allows you to change the property names of the generated classes to no longer match the underlying field names, this could be useful if you have a strange naming convention for your field names, or in our case with AdventureWorks we have instances like on the SalesOrderHeader class where it has two links to the Address table (BillTo and ShipTo) but these relationships get modelled Address and Address1.    This is obviously undesirable as there is no clear indication which one links to Address based on ShipToAddressID and which on BillToAddressID.     Luckily we have a solution close at hand.
Open up the LINQ-to-SQL diagram and find the two relationships between the SalesOrderHeader table and the Address table (Not a simple task, you may need to drag one of the two tables into the open to find its links, or use the Drop-Down above the property box to select it that way). The property box should look like this
![Address1](/images/1382874053706.png) 
Change it to something more useful.
![ShipToAddress](/images/1382874053707.png) 
We now have a SalesOrderHeader.ShipToAddress property available. Do the same for the Address/BillToAddress property. My later code samples will assume this change has been made.    There are other places in the database this would be useful, but we will address them as they come up.
Note: One of my few gripes about LINQ-to-SQL is that if you rebuild the classes from scratch (the easiest way to update changes from the database) you will lose these edits. It would be nice to be able to save them away somehow or have a "Scan for changes" feature. It would also be nice if the wizard could detect the situation above (which is quite common) and handle it cleanly.
