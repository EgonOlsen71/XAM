0 if lf=0 then lf=1:load "xam2",8,1
5 sys 832
10 print chr$(14);chr$(147);:poke 53280,0:poke 53281,0:poke 646,7
20 x=0:y=0:d=1
30 read c,a$:if a$="***" then 500
40 l=len(a$):hl=l/2:dp=int(20-hl)
50 if l>0 then gosub 2000:d=d*-1
60 y=y+1:goto 30

500 get a$:if a$="" then 500
505 for i=0 to 24:sys 59626:next
510 poke 646,1:printchr$(147);"Stelle Zeit auf 1984...":poke 646,0
520 sys 921:for i=0 to 10
530 print "load";chr$(34);"xam";chr$(34);",8,1":next
535 print chr$(19);
540 poke 631,13:poke 632,82:poke 633,85:poke 634,78
550 poke 636,58:poke 635,13:poke 198,6
560 end

600 x2=x:if x2<0 then x2=0
610 poke 781,y:poke 782,x2:poke 783,0:sys 65520:return

2000 poke 646,c:s=39:if d=1 then s=-l
2010 for x=s to dp step d
2020 b$=a$:if (x+l>39) then b$=left$(a$, -x+39+1)
2030 if x<0 then b$=right$(a$, x+l)
2040 gosub 600:print b$;:next:return

10000 data 1," BROTQUEST "
10010 data 12," --------- ",0,""
10020 data 7," ein Textadventure von ",5," EgonOlsen71 ",0,"",0,""
10030 data 1," Die Sommerferien '84 beginnen ",15," und der Wunsch nach "
10040 data 12," einem dieser neuen Heimcomputer ", 11," ist stark in dir! "
10050 data 0,"",0,"",1," Nutze Befehle wie: ", 10," schau schrank "
10060 data 15," oder ", 10," benutze hammer mit nagel ", 12," oder auch "
10070 data 10," gib mann die diskette ", 11," um zum Ziel zu kommen. "
10080 data 0,"",0,"",3," powered by ",14," XAM - XML Adventure Machine "
11000 data 0,"***"
