---
title: Scripted Text Generation
layout: post
permalink: /2006/04/scripted-text-generation.html
tags: vfp
guid: tag:blogger.com,1999:blog-25631453.post-114445854422123744
tidied: true
---

The first piece of code I would like to post is one of my favourites, in that geeky kind of way.
A quick little routine to take a file that mixes static text with foxpro expressions and scripting then turns it into a foxpro procedure.

We use this code to process HTML and XML template files used by our websites into efficient compiled foxpro code.
I made mention of this code as part of my presentation at [OzFox Lite](http://www.ozfox.com.au/) in March 2006. So here it is!
  
<!-- more -->

```XBase
### Code

#define k_NL      chr(13) + chr(10)
#define k_VARIABLE    "__cS"
#define k_BLOCK_OPEN  "<%"    && open code blocks
#define k_BLOCK_CLOSE  "%>"    && close code blocks
#define k_EXP_OPEN    "<%="    && open expressions
#define k_EXP_CLOSE    "%>"    && close expressions
#define k_QUOTE_OPEN  '['      && open quote for strings
#define k_QUOTE_CLOSE  ']'      && close quote for strings
#define k_QUOTE2_OPEN   [']      && open quote mark safe to wrap other quote marks in
#define k_QUOTE2_CLOSE  [']      && close quote mark safe to wrap other quote marks in
#define k_SPECIAL    k_QUOTE_OPEN + k_QUOTE_CLOSE + [&]  && Break these synbols out of the string and wrap in quote2
#define k_MAX_LINES    20
#define k_MAX_STRING  254
#define k_SAVE_INDENT  .T.

function compilePage
*************************
lparameters cStr, cFName 
local cS, cLine, inScript, inLine, nLines, cLinePre
local array a_file[1]
nLines= 0
cS= 'function ' + m.cFName + k_NL ;
  + 'lparameters ' + k_VARIABLE + k_NL ;
  + k_VARIABLE + "= " + k_QUOTE_OPEN + k_QUOTE_CLOSE + k_NL
cLinePre= ''
for i = 1 to alines(a_file, m.cStr)
  cLine= alltrim(chrtran(a_file[m.i], chr(9) + chr(10) + chr(13), ''))
  #if k_SAVE_INDENT
    cLinePre= left(a_file[m.i], at(left(m.cLine, 1), a_file[m.i]) - 1)
  #endif
  if !empty(m.cLine)
    do case
      case m.cLine = k_BLOCK_OPEN and m.cLine # k_EXP_OPEN
        inScript= at(k_BLOCK_CLOSE, m.cLine) = 0
        if m.inLine
          inLine= .F.
          cS= left(m.cS, rat(';', m.cS) - 1) + k_NL
          nLines= 0
        endif
        cLine= alltrim(strextract(m.cLine, k_BLOCK_OPEN, k_BLOCK_CLOSE, 1, 2))
        if !empty(m.cLine)
          cS= m.cS + compileLine(m.cLine) + k_NL
        endif
      case ltrim(m.cLine) = k_BLOCK_CLOSE
        inScript= .F.
        nLines= 0
      case m.inScript
        if at(k_BLOCK_CLOSE, m.cLine) # 0
          cLine= substr(m.cLine, 1, at(k_BLOCK_CLOSE, m.cLine) - 1)
          nLines= 0
          inScript= .f.
        endif
        if m.cLine # "*" and m.cLine # "&" + "&"
          cS= m.cS + compileLine(m.cLine) + k_NL
        endif
      otherwise
        if !m.inLine or m.nLines = k_MAX_LINES
          if m.nLines= k_MAX_LINES
            cS= left(m.cS, rat(';', m.cS) - 1) + k_NL
          endif
          nLines= 0
          cS= m.cS + k_VARIABLE + "= m." + k_VARIABLE + " "
          inLine= .T.
        else
          nLines= m.nLines + 1
          cS= m.cS + chr(9)
        endif
        cS= m.cS + "+ " + alltrim(compileExpr(m.cLine, m.cLinePre)) + " + chr(13)+chr(10)" + iif(m.inLine, ' ;', '') + k_NL
    endcase
  endif
endfor
if m.inLine
  inLine= .F.
  cS= left(m.cS, rat(';', m.cS) - 1) + k_NL
endif
return m.cS + k_NL + k_NL

function compileLine
*********************
lparameters cS
cS= alltrim(m.cS)
do case
case m.cS = "?"
  cS= k_VARIABLE + "= m." + k_VARIABLE + " + " + alltrim(substr(m.cS, 2)) + " + chr(13)+chr(10)"
  
otherwise
  * do nothing
endcase
return m.cS

function compileExpr
*********************
lparameters cS, cLinePre
local i, inExp, cStr, inBrack, c, lOpen, nLen
cStr= ''
nLen= 0
for i = 1 to len(m.cS)
  c= substr(m.cS, i)
  if empty(chrtran(m.c, chr(9), ''))
    exit
  endif
  nLen= m.nLen + 1
  do case
  case m.c = k_EXP_OPEN
    i= i + 2
    inExp = .T.
    if m.lOpen
      cStr= m.cStr + k_QUOTE_CLOSE + " + "
      lOpen= .F.
    endif
  case m.c = k_EXP_CLOSE
    i= m.i + 1
    inExp= .F.
    if !empty(substr(m.cS, m.i + 1))
      cStr= m.cStr + " + " + k_QUOTE_OPEN
      lOpen= .T.
      nLen= 0
    endif
  case m.inExp
    cStr= m.cStr + substr(m.cS, i, 1)
  case left(m.c, 1) $ k_SPECIAL
    if m.lOpen
      cStr= m.cStr + k_QUOTE_CLOSE + " + "
    endif
    cStr= m.cStr + k_QUOTE2_OPEN + m.cLinePre + left(m.c, 1) + k_QUOTE2_CLOSE + " + "
    cLinePre= ''
    if m.lOpen
      cStr= m.cStr + k_QUOTE_OPEN
    endif
  otherwise
    if !m.lOpen
      cStr= m.cStr + k_QUOTE_OPEN + m.cLinePre
      lOpen= .T.
      nLen= m.nLen + len(m.cLinePre)
      cLinePre= ''
    endif
    if m.nLen > k_MAX_STRING
      cStr= m.cStr + k_QUOTE_CLOSE + " + " + k_QUOTE_OPEN
      nLen= 0
    endif
    cStr= m.cStr + substr(m.cS, i, 1)
  endcase
endfor
cStr= strtran(m.cStr, k_EXP_OPEN, k_QUOTE_CLOSE + " + ")
cStr= strtran(m.cStr, k_EXP_CLOSE, " + " + k_QUOTE_OPEN)
if m.lOpen
  cStr= m.cStr + k_QUOTE_CLOSE
endif
return m.cStr

```

The precise way to call this code will depend on how you intend to use it.
I have provided the basic calling structure, but a better way to do this is to compile a directory of script files into one single prg which you can add to your SET PROCEDURE line.
You can also on-the-fly compile these pages off disk as they are called.
  

```XBase
### Example Calling Code

local cIn, cOut, cS
cIn= filetostr("c:\test.htm")
cOut= compilePage(m.cIn, "__test")
strtofile(m.cOut, "c:\test.prg")
open database (home(2) + "northwind\northwind")
use northwind!Customers in 0
do __test in C:\test.prg with cS
?cS
close databases all
```

You can point the "compiler" at any text based file you like, a very basic example is provided below.
Along with the procedure this would generate.
  


```XBase
### Example Input

The time is <%= ttoc(datetime()) %>
<%
  select Customers
  scan
%>
    Customer: <%= Customers.CustomerID %><br />
<% endscan %>

```



```XBase
### Example Output

function __test
lparameters __cS
__cS= []
__cS= m.__cS + [The time is ] +  ttoc(datetime()) + chr(13)+chr(10) 
select Customers
scan
__cS= m.__cS + [    Customer: ] +  Customers.CustomerID  + [<br />] + chr(13)+chr(10) 
endscan
```


I find this a nice way to separate the 'design' of text content from your code.
I am sure we have all at one stage experienced the nightmare of trying to maintain complex string building code inside fox itself.
Not fun.

To try out this code:

* Copy and paste the code block into a procedure file
* SET PROCEDURE TO the above file
* Copy and paste the input example into a file called c:\test.htm
* Run the example calling code from the command window

  
