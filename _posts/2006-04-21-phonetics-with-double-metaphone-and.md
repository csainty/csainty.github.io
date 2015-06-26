---
title: Phonetics with Double Metaphone and VFP
layout: post
permalink: /2006/04/phonetics-with-double-metaphone-and.html
tags: vfp
guid: tag:blogger.com,1999:blog-25631453.post-114558676161860596
tidied: true
---

Something that has been floating around in my "to-do" list for quite some time is to write a class for phonetic keyword matching in a fox database.
The idea is for it to be a step down from PhDbase ([link](http://fox.wikis.com/wc.dll?Wiki~PhdBase~VFP)) without losing the functionality I personally find most useful, phonetic matching.

<!-- more -->

At the core of this class is a VFP version of the Double Metaphone algorithm ([link](http://en.wikipedia.org/wiki/Double_Metaphone)) originally written by Lawrence Philips in C/C++.
This isn't the tidiest piece of code floating around the internet, but it is still pretty clever, and I hope to someday soon find the time to wrap it in a class with some support for boolean logic and a good word boundary algorithm for indexing.

```XBase
### Code

function double_metaphone(cStr as String)
  local cP, cS, nCur, nLen, cOrig, isSlavo, cRest
  cP= ''
  cS= ''
  nCur= 1
  nLen= len(m.cStr)
  cOrig= upper(m.cStr) + space(5)
  isSlavo= Slavo_Germanic(m.cOrig)
  cRest= m.cOrig

  * skip this at beginning of word
  if inlist(m.cOrig, 'GN','KN','PN','WR','PS')
    nCur = m.nCur + 1
  endif

  * Initial 'X' is pronounced 'Z' e.g. 'Xavier'
  if (m.cOrig = 'X')
    cP= m.cP + "S"
    cS= m.cS + "S"
    nCur = nCur + 1 
  endif

  * Main Loop
  do while (len(m.cP) < 4 or len(m.cS) < 4) and m.nCur <= m.nLen
    local cLet
    cLet= substr(m.cOrig, m.nCur, 1)
    cRest= substr(m.cOrig, m.nCur)
    do case
    case m.cLet $ 'AEIOU'
      * do nothing
      nCur= m.nCur + 1

    case m.cLet = 'Y'
      if m.nCur = 1
        cP= m.cP + 'A'
        cS= m.cS + 'A'
      endif
      nCur = nCur + 1

    case m.cLet = 'B'
      * '-mb', e.g. "dumb", already skipped over ...
      cP= m.cP + 'P'
      cS= m.cS + 'P'

      if m.cRest = 'BB'
        nCur = nCur + 2
      else
        nCur = nCur + 1
      endif     

    case m.cLet = chr(199) && 
      cP= m.cP + 'S'
      cS= m.cS + 'S'
      nCur = nCur + 1 

    case m.cLet = 'C'
      * Various germanic
      if m.nCur > 2 and !is_vowel(m.cOrig, m.nCur - 2) ;
          and substr(m.cOrig, m.nCur - 1, 3) = "ACH" ;
          and (substr(m.cOrig, m.nCur + 2, 1) # 'I' ;
          and (substr(m.cOrig, m.nCur + 2, 1) # 'E' ;
          or inlist(substr(m.cOrig, m.nCur - 2, 6), "BACHER", "MACHER")))
        cP= m.cP + 'K'
        cS= m.cS + 'K'
        nCur = m.nCur + 2
        loop
      endif

      * special case 'caesar'
      if m.nCur = 1 and m.cOrig = "CAESAR"
        cP = cP + 'S'
        cS = cS + 'S'
        nCur= m.nCur + 2
        loop
       endif

      * italian 'chianti'
      if m.cRest = "CHIA"
        cP = cP + 'K'
        cS = cS + 'K'
        nCur= m.nCur + 2
        loop
      endif

      if m.cRest = "CH"
        * Find michael
        if m.nCur > 1 and m.cRest = "CHAE"
          cP= m.cP + "K"
          cS= m.cS + "X"
          nCur = nCur + 2
          loop
        endif

        * greek roots e.g. 'chemistry', 'chorus'
        if (m.nCur = 1 and ;
            inlist(m.cRest, "CHARAC", "CHARIS", "CHOR", "CHYM", "CHIA", "CHEM") ;
            and m.cOrig != "CHORE")
          cP= m.cP + 'K'
          cS= m.cS + 'K'
          nCur = nCur + 2
          loop
        endif

        if inlist(m.cOrig, "VAN ", "VON ", "SCH") ;
            or inlist(substr(m.cOrig, m.nCur - 2, 6), "ORCHES", "ARCHIT", "ORCHID") ;
            or substr(m.cOrig, m.nCur + 2, 1) $ "TS" ;
            or (substr(m.cOrig, m.nCur - 1, 1) $ "AOUE" or m.nCur = 1)
          cP= m.cP + 'K'
          cS= m.cS + 'K'
        else
          if m.nCur > 1
            if m.cOrig = "MC"
              cP= m.cP + 'K'
              cS= m.cS + 'K'
            else
              cP= m.cP + 'X'
              cS= m.cS + 'K'
            endif
          else
            m.cP = m.cP + 'X'
            m.cS = m.cS + 'X'
          endif
        endif
        nCur = nCur + 2
        loop
      endif

      * e.g. 'czerny'
      if m.cRest = "CZ" ;
          and substr(m.cOrig, m.nCur - 2, 4) # "WICZ"
        cP= m.cP + "S"
        cS= m.cS + "X"
        nCur= m.nCur + 2
        loop
      endif

      * eg focaccia
      if m.cRest = "CCIA"
        cP= m.cP + 'X'
        cS= m.cS + 'X'        
        nCur= m.nCur + 3
        loop
      endif

      * double 'C', but not McClellan'
      if m.cRest = "CC" and !(m.nCur = 2 and m.cOrig = "M")
        * 'bellocchio' but not 'bacchus'
        if substr(m.cOrig, m.nCur + 2, 1) $ 'IEH' ;
            and substr(m.cOrig, m.nCur + 2, 2) # 'HU'
          *'accident', 'accede', 'succeed'
          if (m.nCur != 2 and substr(m.cOrig, m.nCur -1, 1) = "A") ;
              or inlist(m.cOrig, "UCCEE", "UCCES")
            cP= m.cP + "KS"
            cS= m.cS + "KS"
          else
            cP= m.cP + "X"
            cS= m.cS + "X"
          endif
          nCur= m.nCur + 3
          loop
        else
          * Pierce's rule
          cP= m.cP + 'K'
          cS= m.cS + 'K'
          nCur= m.nCur + 2
          loop
        endif
      endif

      if inlist(m.cRest, "CK", "CG", "CQ")
        cP= m.cP + 'K'
        cS= m.cS + 'K'
        nCur= m.nCur + 2
        loop
      endif

      if inlist(m.cRest, "CI", "CE", "CY")
        if inlist(m.cRest, "CIO", "CIE", "CIA")
          cP= m.cP + "S"
          cS= m.cS + "X"
        else
          cP= m.cP + "S"
          cS= m.cS + "S"
        endif
        nCur= m.nCur + 2
        loop
      endif

      * else case
      cP= m.cP + 'K'
      cS= m.cS + 'K'

      if inlist(m.cRest, "C C", "C Q", "C G")
        nCur= m.nCur + 3
      else
        if inlist(m.cRest, "CC", "CK", "CQ")
          nCur= m.nCur + 2
        else
          nCur= m.nCur + 1
        endif
      endif

    case m.cLet = 'D'
      if m.cRest = "DG"
        if inlist(m.cRest, "DGI", "DGE", "DGY")
          cP = cP + 'J'
          cS = cS + 'J'
          nCur = nCur + 2
          loop
        else
          cP = cP + 'TK'
          cS = cS + 'TK'
          nCur= m.nCur + 2
          loop
        endif
      endif

      if inlist(m.cRest, "DT", "DD")
        cP = cP + "T"
        cS = cS + "T"
        nCur = nCur + 2
        loop
      endif

      cP = cP + "T"
      cS = cS + "T"
      nCur = nCur + 1

    case m.cLet = 'F'
      if m.cRest = "FF"
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "F"
      cS= m.cS + "F"

    case m.cLet = 'G'
      if m.cRest = "GH"
        if m.nCur > 1 and !is_vowel(m.cOrig, m.nCur - 1)
          cP= m.cP + "K"
          cS= m.cS + "K"
          nCur= m.nCur + 2
          loop
        endif

        * 'ghislane', 'ghiradelli'
        if m.nCur = 1
          if m.cRest = "GHI"
            cP= m.cP + "J"
            cS= m.cS + "J"
          else
            cP=m.cP + "K"
            cS= m.cS + "K"
          endif
          nCur= m.nCur + 2
          loop
        endif

        if (m.nCur > 2 and substr(m.cOrig, m.nCur - 2, 1) $ "BHD") ;
            or (m.nCur > 3 and substr(m.cOrig, m.nCur - 3, 1) $ 'BHD') ;
            or (m.nCur > 4 and substr(m.cOrig, m.nCur - 4, 1) $ 'BH')
          nCur= m.nCur + 2
          loop
        else
          if m.nCur > 3 and substr(m.cOrig, m.nCur - 1, 1) = "U" ;
              and substr(m.cOrig, m.nCur - 3, 1) $ 'CGLRT'
            cP= m.cP + 'F'
            cS= m.cS + 'F'
          else
            if (m.nCur > 1) and substr(m.cOrig, m.nCur - 1, 1) # 'I'
              cP= m.cP + 'K'
              cS= m.cS + 'K'
            endif
          endif
          m.nCur = m.nCur + 2
          loop
        endif
      endif

      if m.cRest = "GN"
        if m.nCur = 2 and is_vowel(m.cOrig, 1) and !m.isSlavo
          cP= m.cP + "KN"
          cS= m.cS + "N"
        else
          if m.cRest != "GNEY" and !m.isSlavo
            cP= m.cP + "N"
            cS= m.cS + "KN"
          else
            cP= m.cP + "KN"
            cS= m.cS + "KN"
          endif
        endif
        nCur= m.nCur + 2
        loop
      endif

      * tagliaro
      if m.cRest= "GLI" and !m.isSlavo
        cP= m.cP + "KL"
        cS= m.cS + "L"
        nCur= m.nCur + 2
        loop
      endif

      * ges-, gep-, gel- at beginning
      if inlist(m.cOrig, "GES","GEP","GEB","GEL","GEY","GIB","GIL","GIN","GIE","GEI","GER","GY")
        cP= m.cP + "K"
        cS= m.cS + "J"
        nCur= m.nCur + 2
        loop
      endif

      * -ger-, -gy-
      if (m.cRest = "GER" or m.cRest = "GY") ;
          and !inlist(m.cOrig, "DANGER","RANGER", "MANGER") ;
          and !substr(m.cOrig, m.nCur - 1, 1) $ "EI" ;
          and !inlist(substr(m.cOrig, m.nCur - 1, 3), "RGY", "OGY")
        cP= m.cP + "K"
        cS= m.cS + "J"
        nCur= m.nCur + 2
        loop
      endif

      * italian e.g. 'biaggi'
      if inlist(m.cRest, "GE", "GI", "GY") ;
          or inlist(substr(m.cOrig, m.nCur - 1, 4), "AGGI", "OGGI")
        if inlist(m.cOrig, "VAN ", "VON ", "SCH") or m.cRest = "GET"
          cP= m.cP + "K"
          cS= m.cS + "K"
        else
          if m.cRest = "GIER "
            cP= m.cP + "J"
            cS= m.cS + "J"
          else
            cP= m.cP + "J"
            cS= m.cS + "K"
          endif
        endif
        nCur= m.nCur + 2
        loop
      endif

      if m.cRest = "GG"
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "K"
      cS= m.cS + "K"

    case m.cLet = "H"
      if (m.nCur = 1 or is_vowel(m.cOrig, m.nCur - 1)) and is_vowel(m.cOrig, m.nCur + 1)
        cP= m.cP + "H"
        cS= m.cS + "H"
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif

    case m.cLet = "J"
      * obvious spanish, 'jose', 'san jacinto'
      if m.cRest = "JOSE" ;
          or m.cOrig = "SAN "
        if (m.nCur = 1 and substr(m.cOrig, m.nCur + 4, 1) = " ") ;
            or m.cOrig = "SAN "
          cP= m.cP + "H"
          cS= m.cS + "H"
        else
          cP= m.cP + "J"
          cS= m.cS + "H"
        endif
        nCur= m.nCur + 1
        loop
      endif

      if m.nCur = 1 and m.cRest # "JOSE"
        cP= m.cP + "J"
        cS= m.cS + "A"
      else
        * spanish pron. of .e.g. 'bajador'
        if is_vowel(m.cOrig, m.nCur - 1) ;
            and !m.isSlavo ;
            and (m.cRest = "JA" ;
            or m.cRest = "JO")
          cP= m.cP + "J"
          cS= m.cS + "H"
        else
          if m.nCur = m.nLen
            cP= m.cP + "J"
            cS= m.cS + ""
          else
            if !inlist(m.cRest, "JL","JT","JK","JS","JN","JM","JB","JZ") ;
                and !substr(m.cOrig, m.nCur - 1, 1) $ "SKL"
              cP= m.cP + "J"
              cS= m.cS + "J"
            endif
          endif
        endif
      endif

      if m.cRest = "JJ"
        nCur= m.nCur + 2
      else
        nCur = m.nCur + 1
      endif

    case m.cLet = "K"
      if m.cRest = "KK"
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "K"
      cS= m.cS + "K"

    case m.cLet = "L"
      if m.cRest = "LL"
        && spanish e.g. 'cabrillo', 'gallegos'
        if (m.nCur = m.nLen - 3 ;
            and inlist(substr(m.cOrig, m.nCur - 1, 4), "ILLO", "ILLA", "ALLE")) ;
            or ((inlist(right(m.cOrig, 2), "AS", "OS") ;
            or right(m.cOrig, 1) $ "AO") ;
            and substr(m.cOrig, m.nCur - 1, 4) = "ALLE")
          cP= m.cP + "L"
          cS= m.cS + ""
          nCur= m.nCur + 2
          loop
        endif
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "L"
      cS= m.cS + "L"

    case m.cLet = "M"
      if (substr(m.cOrig, m.nCur - 1, 3) = "UMB" ;
          and m.nCur + 1 = m.nLen) ;
          or substr(m.cOrig, m.nCur + 2, 2) = "ER" ;
          or m.cRest = "MM"
        *'dumb', 'thumb'
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "M"
      cS= m.cS + "M"

    case m.cLet= "N"
      if m.cRest = "NN"
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "N"
      cS= m.cS + "N"

    case m.cLet = chr(209) && 
      nCur= m.nCur + 1
      cP= m.cP + "N"
      cS= m.cS + "N"

    case m.cLet = "P"
      if m.cRest = "PH"
        nCur= m.nCur + 2
        cP= m.cP + "F"
        cS= m.cS + "F"
        loop
      endif
      * also account for "campbell" and "raspberry"
      if inlist(m.cRest, "PP", "PB")
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "P"
      cS= m.cS + "P"

    case m.cLet = "Q"
      if m.cRest = "QQ"
        nCur= m.nCur + 2
      else
        nCur = m.nCur + 1
      endif
      cP= m.cP + "K"
      cS= m.cS + "K"

    case m.cLet = "R"
      * french e.g. 'rogier', but exclude 'hochmeier'
      if m.nCur = m.nLen and !m.isSlavo ;
          and substr(m.cOrig, m.nCur - 2, 2) = "IE" ;
          and !inlist(substr(m.cOrig, m.nCur - 4, 2), "ME", "MA")
        cP= m.cP + ""
        cS= m.cS + "R"
      else
        cP= m.cP + "R"
        cS= m.cS + "R"
      endif

      if m.cRest = "RR"
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif

    case m.cLet = "S"
      * special cases 'island', 'isle', 'carlisle', 'carlysle'
      if inlist(substr(m.cOrig, m.nCur - 1, 3), "ISL", "YSL")
        nCur= m.nCur + 1
        loop
      endif

      * special case 'sugar-'
      if m.nCur = 1 and m.cOrig = "SUGAR"
        cP= m.cP + "X"
        cS= m.cS + "S"
        nCur= m.nCur + 1
        loop
      endif

      if m.cRest = "SH"
        * germanic
        if inlist(m.cRest, "SHEIM","SHOEK","SHOLM","SHOLZ")
          cP= m.cP + "S"
          cS= m.cS + "S"
        else
          cP= m.cP + "X"
          cS= m.cS + "X"
        endif
        nCur= m.nCur + 2
        loop
      endif

      * italian & armenian 
      if inlist(m.cRest, "SIO", "SIA")
        if !m.isSlavo
          cP= m.cP + "S"
          cS= m.cS + "X"
        else
          cP= m.cP + "S"
          cS= m.cS + "S"
        endif
        nCur= m.nCur + 3
        loop
      endif

      * german & anglicisations, e.g. 'smith' match 'schmidt', 'snider' match 'schneider'
      * also, -sz- in slavic language altho in hungarian it is pronounced 's'
      if (m.nCur = 1 and inlist(m.cRest, "SM","SN","SL","SW")) ;
          or m.cRest = "SZ"
        cP= m.cP + "S"
        cS= m.cS + "X"

        if m.cRest = "SZ"
          nCur= m.nCur + 2
        else
          nCur= m.nCur + 1
        endif
        loop
      endif

      if m.cRest = "SC"
        * Schlesinger's rule
        if m.cRest = "SCH"
          * dutch origin, e.g. 'school', 'schooner'
          if inlist(m.cRest, "SCHOO","SCHER","SCHEN","SCHUY","SCHED","SCHEM")
            * 'schermerhorn', 'schenker' 
            if inlist(m.cRest, "SCHER", "SCHEN")
              cP= m.cP + "X"
              cS= m.cS + "SK"
            else
              cP= m.cP + "SK"
              cS= m.cS + "SK"
            endif
            nCur= m.nCur + 3
            loop
          else
            if m.nCur = 1 ;
                and !is_vowel(m.cOrig, 3) ;
                and m.cRest # "SCHW"
              cP= m.cP + "X"
              cS= m.cS + "S"
            else
              cP= m.cP + "X"
              cS= m.cS + "X"
            endif
            nCur= m.nCur + 3
            loop
          endif
        endif && H

        if inlist(m.cRest, "SCI", "SCE", "SCY")
          cP= m.cP + "S"
          cS= m.cS + "S"
          nCur= m.nCur + 3
          loop
        endif

        cP= m.cP + "SK"
        cS= m.cS + "SK"
        nCur= m.nCur + 3
        loop
      endif    && "SC"

      * french e.g. 'resnais', 'artois'
      if m.nCur = m.nLen and inlist(right(m.cOrig, 2), "AI", "OI")
        cP= m.cP + ""
        cS= m.cS + "S"
      else
        cP= m.cP + "S"
        cS= m.cS + "S"
      endif

      if inlist(m.cRest, "SS", "SZ")
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif

    case m.cLet = "T"
      if inlist(m.cRest, "TION", "TIA", "TCH")
        cP= m.cP + "X"
        cS= m.cS + "X"
        nCur= m.nCur + 3
        loop
      endif

      if m.cRest = "TH" or m.cRest = "TTH"
        * special case 'thomas', 'thames' or germanic
        if inlist(m.cRest, "THOM", "THAM") ;
            or inlist(m.cOrig, "VAN ", "VON ", "SCH")
          cP= m.cP + "T"
          cS= m.cS + "T"
        else
          cS= m.cS + "O"
          cS= m.cS + "T"
        endif
        nCur= m.nCur + 2
        loop
      endif

      if inlist(m.cRest, "TT", "TD")
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "T"
      cS= m.cS + "T"

    case m.cLet = "V"
      if m.cRest = "VV"
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif
      cP= m.cP + "F"
      cS= m.cS + "F"

    case m.cLet = "W"
      * can also be in middle of word
      if m.cRest = "WR"
        cP= m.cP + "R"
        cS= m.cS + "R"
        nCur= m.nCur + 2
        loop
      endif

      if m.nCur = 1 ;
          and (is_vowel(m.cOrig, m.nCur + 1) ;
          or m.cRest = "WH")
        * Wasserman should match Vasserman 
        if is_vowel(m.cOrig, m.nCur + 1)
          cP= m.cP + "A"
          cS= m.cS + "F"
        else
          cP= m.cP + "A"
          cS= m.cS + "A"
        endif
        nCur= m.nCur + 2
        loop
      endif

      && Arnow should match Arnoff
      if (m.nCur = m.nLen and is_vowel(m.cOrig, m.nCur - 1)) ;
          or inlist(substr(m.cOrig, m.nCur - 1, 5), "EWSKI","EWSKY","OWSKI","OWSKY") ;
          or m.cOrig = "SCH"
        cP= m.cP + ""
        cS= m.cS + "F"
        nCur= m.nCur + 1
        loop
      endif

      if inlist(m.cRest, "WICZ","WITZ")
        cP= m.cP + "TS"
        cS= m.cS + "FX"
        nCur= m.nCur + 4
        loop
      endif

      nCur= m.nCur + 1

    case m.cLet = "X"
      * french e.g. breaux 
      if !(m.nCur = m.nLen ;
          and (inlist(substr(m.cOrig, m.nCur - 3, 3), "IAU", "EAU") ;
          or inlist(substr(m.cOrig, m.nCur - 2, 2), "AU", "OU")))
        cP= m.cP + "KS"
        cS= m.cS + "KS"
      endif

      if inlist(m.cRest, "XX", "XC")
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif

    case m.cLet = "Z"
      * chinese pinyin e.g. 'zhao' 
      if m.cRest = "ZH"
        cP= m.cP + "J"
        cS= m.cS + "J"
        nCur= m.nCur + 2
        loop
      else
        if inlist(m.cRest, "ZO", "ZA", "ZI") ;
            or (m.isSlavo ;
            and (m.nCur > 1 and substr(m.cOrig, m.nCur - 1, 1) # "T"))
          cP= m.cP + "S"
          cS= m.cS + "TS"
        else
          cP= m.cP + "S"
          cS= m.cS + "S"
        endif
      endif

      if m.cRest = "ZZ"
        nCur= m.nCur + 2
      else
        nCur= m.nCur + 1
      endif

    otherwise
      nCur= m.nCur + 1
    endcase
  enddo
  cP= padr(m.cP, 4)
  cS= padr(m.cS, 4)

  return m.cP
endfunc

function is_vowel(cStr, nPos)
  return substr(m.cStr, m.nPos, 1) $ 'AEIOUY'
endfunc

function Slavo_Germanic(cStr)
  return occurs("W", m.cStr) > 0 ;
    or occurs("K", m.cStr) > 0 ;
    or occurs("CZ", m.cStr) > 0 ;
    or occurs("WITZ", m.cStr) > 0
endfunc
```


```XBase
### Example

set procedure to Phonetics.prg
clear
?double_metaphone("foxpro")    && FKSP
?double_metaphone("phoxpro")  && FKSP
?double_metaphone("phocksprow")  && FKSP
```
