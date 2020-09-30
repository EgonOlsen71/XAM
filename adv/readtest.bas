10 gosub 63300:gosub 60000:gosub 61200:gosub 48000:gosub 61500
20 rn$="haus.rom":gosub 63300
30 gosub 40100
40 gosub 50000:gosub 40000
50 gosub 52000:gosub 40000
60 goto 40

40000 rem print error message
40010 if er=0 then return
40020 if er=1 then print "Das klappt so nicht!"
40030 if er=2 then print "Das verstehe ich nicht!"
40040 if er=3 then print "Das bewirkt nichts mehr!"
40050 er=0:return

40100 rem init room with name in rn$
40110 gosub 62000:gosub 62600:gosub 62500:return

40500 rem print object description in t%
40510 for i=0 to 5:a$=id$(t%,i)
40520 if len(a$)=0 then return
40530 print a$:next:return

40600 rem print can-not-do-that-message
40610 print"Das kann ich nicht ";cv$(t%);"!":er=0
40620 return

40700 rem print inventory
40710 print:print"Du hast bei dir:"
40715 if ic%=0 then printtab(2);"nichts":return
40720 for i=0 to ic%-1:pp%=iv%(i)
40730 if uv%(i)=0 then printtab(2);it$(pp%)
40740 next:return

40800 rem take all (special case)
40805 if tc%=0 then return
40810 rr%=0:for i=0 to tc%-1:t%=ip%(i):gosub 40900
40820 if rt%=1 then rr%=1:rt%=0
40830 next
40840 if rr%=1 then gosub 59000
40850 return

40900 rem take one item (id in t%)
40910 rt%=0:if mv%(t%)=1 then 40930
40920 print "Ich kann ";it$(t%);" nicht nehmen!":rt%=2:return
40930 iv%(ic%)=t%:print it$(t%);" genommen!":ic%=ic%+1:rs%(t%)=0
40940 for pp=0 to 8:if rv%(rd%,pp)=t% then rv%(rd%,pp)=-1
40950 next pp:rt%=1:return

41000 rem try to guess an intended direction command
41005 if len(cc$)<2 then return
41010 a$=left$(cc$,len(cc$)-1)
41020 if len(a$)<3 then 41100
41030 gosub 41200:if a$="up" or a$="hoch" then cc$="geh "+cc$:return
41040 if a$="down" or a$="runter" then cc$="geh "+cc$:return
41050 if len(a$)>6 then a$=left$(a$,5)
41060 if a$="nordo" or a$="nordw" then cc$="geh "+cc$:return
41070 if a$="suedo" or a$="suedw" then cc$="geh "+cc$:return
41090 return
41100 if a$="n" or a$="s" or a$="w" or a$="o" then cc$="geh "+cc$:return
41110 if a$="no" or a$="so" or a$="nw" or a$="sw" then cc$="geh "+cc$:return
41120 if a$="h" or a$="r" or a$="d" or a$="u" then cc$="geh "+cc$:return
41130 return

41200 rem remap up/down directions in a$
41210 if a$="unten" then a$="runter"
41220 if a$="oben" or a$="rauf" then a$="hoch"
41230 return

41300 rem add room inventory items to visible items
41310 for i=0 to 8:p=rv%(rd%,i):ff%=0
41320 if p=-1 then 41360
41325 if ic%=0 then 41350
41330 for ii=0 to ic%-1:if iv%(ii)=p then ff%=1:ii=ic%
41340 next ii:if ff%=1 then 41360
41350 ip%(tc%)=p:tc%=tc%+1
41360 next:return

41400 rem drop item in t%
41410 rt%=0:c%=0:for p=0 to 8:if rv%(rd%,p)=-1 then c%=c%+1
41415 next
41420 if c%<3 then print"Hier ist kein Platz mehr!":rt%=2:return
41430 for p=0 to 8:if rv%(rd%,p)=-1 then rv%(rd%,p)=t%:p=9
41440 next:for p=0 to ic%-1:c%=iv%(p)
41450 if c%<>t% then 41500
41460 if p=ic%-1 then ic%=ic%-1:p=256:goto 41500
41470 for pp=p to ic%-2:iv%(pp)=iv%(pp+1):next:ic%=ic%-1:pp=256
41500 next
41510 rs%(t%)=1:print it$(t%);" abgelegt!":rt%=1:return

42000 rem load room operations
42010 for i=0 to 10
42015 if a$="?" then a$="-1"
42020 op%(oc%,i)=val(a$):input#2,a$:next
42040 for i=0 to 5:op$(oc%,i)="":next:ii=0
42050 tx$=a$:gosub 61000:op$(oc%,ii)=tx$:input#2,a$:ii=ii+1
42060 if a$="***" then oc%=oc%+1:return
42070 goto 42050

42200 rem apply room command (c%=item1,c2%=item2,t%=command)
42210 p=op%(t2%,1):pp=op%(t2%,8):gosub 42900:if rt%=0 then return
42220 uq%=op%(t2%,2):if uq%<>1 then 42270: rem non-unique
42230 gosub 43000:if rt%=1 then return
42270 for i=0 to 5:a$=op$(t2%,i):if len(a$)=0 then i=5:goto 42290
42280 gosub 59100
42290 next:for i=0 to 10:ac%(i)=op%(t2%,i):next
42300 gosub 43400
42330 return

42400 rem error check
42410 if i>=255 then return
42420 print"Fehler: Array voll!":end

42500 rem add item to room
42510 for i=0 to 8:if rv%(rd%,i)=-1 then rv%(rd%,i)=c%:i=256
42520 next:gosub 42400
42530 gosub 62600:rt%=1:return

42600 rem add item to inventory
42605 print it$(c%);" erhalten!"
42610 iv%(ic%)=c%:ic%=ic%+1:rs%(c%)=0
42620 gosub 62600:rt%=1:return

42700 rem apply item command (c%=item1,c2%=item2,t%=command)
42710 p=og%(t2%,1):pp=og%(t2%,8):gosub 42900:if rt%=0 then return
42730 rt%=0:uq%=og%(t2%,2):if uq%<>1 then 42780: rem non-unique
42740 gosub 43000:if rt%=1 then return
42780 for i=0 to 5:a$=og$(t2%,i):if len(a$)=0 then i=5:goto 42800
42790 gosub 59100
42800 next:for i=0 to 10:ac%(i)=og%(t2%,i):next
42810 gosub 43400
42830 return

42900 rem check item availability
42910 rt%=0:c%=cv%(1):c2%=cv%(2)
42920 if pp<>-1 then 42950
42930 if p=c% and c2%=-1 then gosub 43500
42940 return
42950 if (p=c% and pp=c2%) or (p=c2% and pp=c%) then gosub 43500
42960 return

43000 rem check uniqueness and set accordingly
43010 rt%=0:gosub 43100:if od%=0 then 43050
43030 for i=0 to od%-1:if od$(i)=tf$ then er=3:rt%=1:return
43040 next
43050 gosub 43150:return

43100 rem calculate unique flag (c%,c2%,t%)
43110 i=c%:p=c2%:if i>p then p=i:i=c2%: rem swap if needed
43120 tf$=str$(t%)+"."+str$(i)+"."+str$(p):return

43150 rem flag as unique
43160 od$(od%)=tf$:od%=od%+1:if od%>mx% then 42420
43170 return

43200 rem remove from inventory (i.e. flag as used, id in c%)
43210 if ic%=0 then return
43220 for ii=0 to ic%-1
43230 if iv%(ii)=c% and uv%(ii)=0 then uv%(ii)=1:return
43240 next:return

43400 rem apply actions of current operation
43410 rr%=ac%(9):if rr%<>0 then gosub 43800: rem both items from inv (flagged)
43420 rem from here on, c% is no longer the c% its used to be..watch out
43430 c%=ac%(3):if c%<>-1 then gosub 43200: rem item from inv (flagged)
43435 c%=ac%(4):if c%<>-1 then gosub 43900: rem item from room
43440 c%=ac%(5):if c%<>-1 then gosub 42500: rem item to room
43450 c%=ac%(6):if c%<>-1 then gosub 42600: rem item to inv
43455 c%=ac%(7):if c%<>-1 then gosub 44000: rem unlock direction
43490 rt%=1:return

43500 rem check items with inv/room
43510 if pp=-1 then 43530
43520 rr%=c2%:gosub 43600:if rt%=0 then return
43530 rr%=c%:gosub 43600:return

43600 rem check item against inv/room (id in rr%)
43610 rt%=0:if ic%=0 then 43670
43620 for i=0 to ic%-1
43630 if iv%(i)=rr% and uv%(i)=0 then rt%=1:return
43640 next
43670 if tc%=0 then 43710
43680 for i=0 to tc%-1
43690 if ip%(i)=rr% and mv%(rr%)=0 then rt%=1:return
43700 next
43710 gosub 53450:return

43800 rem flag both item (in c% and c2%)
43810 rr%=c%:gosub 43200:c%=c2%:gosub 43200:c%=rr%:return

43900 rem remove item from room (by putting it into inv an uving it)
43910 gosub 42610: rem add to inv...
43920 gosub 43200: rem ...add flag it -> gone
43930 return

44000 rem unlock direction
44010 for i=0 to 3:if len(lx$(rd%,i))>0 then 44040
44020 lx$(rd%,i)=dr$(c%)
44030 gosub 62500:i=256
44040 next:gosub 42400
44060 return

48000 rem load item operations
48010 lg$="Lade Operationen...":gosub 63000
48015 open 2,8,2,"operations.def":gc%=0
48020 for i=0 to 10
48030 input#2,a$:if a$="?" then a$="-1"
48040 og%(gc%,i)=val(a$):next
48050 for i=0 to 5:og$(gc%,i)="":next:ii=0
48060 input#2,tx$
48070 if tx$="***" then 48090
48080 gosub 61000:og$(gc%,ii)=tx$::ii=ii+1:goto 48060
48090 gc%=gc%+1:if st<>64 then 48020
48100 lg$=str$(gc%)+" Operationen geladen!"
48110 gosub 63000:close 2:return

50000 rem enter and parse command
50010 print cb$;:cc$="":input cc$
50020 if len(cc$)=0 then 50010
50030 er=0:tx$=cc$:gosub 63100:cc$=tx$+" ": rem add space to ease lexing
50035 gosub 41000
50040 cc%=0:for i=1 to len(cc$):c$=mid$(cc$,i,1):c%=asc(c$)
50045 if c%=128 then c%=32: rem handle shifted space
50050 if (c%<65 or c%>90) and c%<>32 then 50100: rem skip bogus char
50060 if c%<>32 then ct$=ct$+c$:goto 50080
50070 if len(ct$)>0 then cp$(cc%)=ct$:ct$="":cc%=cc%+1
50080 if cc%=9 then i=256
50100 next i:for i=0 to 8:cv%(i)=-1:next
50110 pp%=cc%:co%=cc%:cc%=0:for i=0 to pp%-1
50120 a$=cp$(i):t%=-1
50130 for p=0 to tb%:for ii=0 to ms%:b$=cm$(p,ii)
50135 if len(b$)=0 then 50150
50140 if b$=a$ then t%=p:ii=256:p=256
50150 next ii,p
50155 if t%<>-1 and cv%(0)<>-1 then er=1:return
50160 if t%<>-1 then cv%(0)=t%:t%=-1:goto 50230
50170 for p=0 to ti%:if il$(p)=a$ then t%=p:p=256
50180 next
50190 if t%=-1 then 50230
50200 if cv%(1)=-1 then cv%(1)=t%:t%=-1
50210 if cv%(2)=-1 then cv%(2)=t%:t%=-1
50220 if t%<>-1 then er=1:return
50230 next: rem next part
50240 for i=0 to 8:if cv%(i)<>-1 then cc%=cc%+1:goto 50260
50250 if cc%=0 then er=2:return
50260 next
50270 rem for i=0 to cc%:print cv%(i),:next
50280 return

52000 rem evaluate parsed command
52005 rr%=0:rt%=0:ff%=0
52010 if er<>0 or cc%=0 then return
52012 t%=cv%(0):on t%+1 goto 52200,52030,52500,52300,52700,52900,53200
52013 on t%-6 goto 53500,53600,53700,53800,53850
52014 er=2:return

52022 rem 
52025 rem cmd schau
52030 rem
52040 if co%=1 then gosub 59000:return 
52050 if cc%=2 and co%<5 then t%=cv%(1):goto 52070
52060 gosub 40600:return
52065 if tc%=0 then 52085
52070 for i=0 to tc%-1:pp%=ip%(i):if pp%=t% then gosub 40500:return
52080 next
52085 if ic%=0 then 52110
52090 for i=0 to ic%-1:pp%=iv%(i):if pp%=t% and uv%(i)=0then gosub 40500:return
52100 next
52110 print it$(t%)+" ist hier nicht!":sk%=1:return

52200 rem 
52202 rem cmd quit
52204 rem
52220 if co%<>1 then 52280
52230 print:print "Wirklich beenden (j/n)?";
52240 geta$:if a$="" then 52240
52250 if a$="j" then print:print "Bis bald!":end
52260 if a$="n" then return
52270 goto 52230
52280 gosub 40600:return

52300 rem 
52302 rem cmd inventar
52304 rem
52320 if co%<>1 then gosub 40600:return
52330 gosub 40700:return

52500 rem 
52502 rem cmd nimm
52504 rem
52510 ff%=0
52520 if cc%=1 and co%=2 and (cp$(0)=al$ or cp$(1)=al$) then gosub 40800:return
52525 if cc%=1 then gosub 40600:return
52530 for i=1 to cc%-1:t%=cv%(i):rt%=0
52540 rr%=0:if tc%=0 then 52580
52545 for ii=0 to tc%-1:pp%=ip%(ii):if pp%=t% then gosub 40900
52550 if rt%=1 then ff%=1
52560 if rt%>0 then rr%=rt%:rt%=0:ii=256
52570 next ii
52580 if rr%=0 then print it$(t%)+" ist hier nicht!"
52590 next i
52600 if ff%=1 then gosub 59000
52610 return

52700 rem 
52702 rem cmd geh
52704 rem
52720 if co%=2 then 52740
52730 gosub 40600:return
52740 a$=cp$(1):gosub 41200
52745 if len(a$)>2 and len(a$)<7 then a$=left$(a$,1)
52750 if len(a$)>6 then a$=left$(a$,5)
52760 if a$="nordo" then a$="no":goto 52800
52770 if a$="nordw" then a$="nw":goto 52800
52780 if a$="suedo" then a$="so":goto 52800
52790 if a$="suedw" then a$="sw"
52800 if a$="u" then a$="h"
52810 if a$="d" then a$="r"
52820 for i=0 to xc%:tx$=xp$(i):gosub 63100:b$=tx$
52830 if a$=b$ then rn$=xx$(i)+".rom":gosub 40100:return
52840 next
52850 print"Da geht es nicht lang!":return

52900 rem 
52902 rem cmd info
52904 rem
53100 print " Simple Adventure Engine 0.1"
53110 print " by EgonOlsen71 / 2020"
53120 print fre(0);"Bytes frei"
53130 print " Status: ";ic%;"/";tc%
53140 return

53200 rem 
53202 rem cmd lege
53204 rem
53210 ff%=0:if ic%=0 then print "Du hast nichts!":return
53220 if cc%=1 then gosub 40600:return
53230 for i=1 to cc%-1:t%=cv%(i)
53240 rr%=0:for ii=0 to ic%-1:pp%=iv%(ii):rt%=0
53245 if pp%=t% and uv%(ii)=0 then gosub 41400
53250 if rt%=1 then ff%=1
53260 if rt%>0 then rr%=rt%:rt%=0:ii=256
53270 next ii
53280 if rr%=0 then rr%=t%:gosub 53450
53290 next i
53300 if ff%=1 then gosub 59000
53310 return

53450 rem havenot message
53460 print it$(rr%);" hast du nicht!":sk%=1:return

53500 rem 
53502 rem cmd oeffne
53504 rem
53510 if cc%<>2 then gosub 40600:return
53520 co%=7:gosub 58500:return

53600 rem 
53602 rem cmd benutze
53604 rem
53610 if cc%>3 or cc%<2 then gosub 40600:return
53620 co%=8:gosub 58500:return

53700 rem 
53702 rem cmd schlage
53704 rem
53710 if cc%>3 or cc%<2 then gosub 40600:return
53720 co%=9:gosub 58500:return

53800 rem
53802 rem cmd load
53804 rem
53810 if cc%>1 then gosub 40600:return
53820 ff%=0:gosub 59200:return

53850 rem
53852 rem cmd save
53854 rem
53860 if cc%>1 then gosub 40600:return
53865 open 1,8,15,"s:"+fi$:close 1
53870 ff%=1:gosub 59200:return

58500 rem generic command
58510 sk%=0:if oc%=0 then 58700
58520 rt%=0:for j=0 to oc%:t%=op%(j,0)
58530 if t%=co% then t2%=j:gosub 42200
58540 if rt%=1 then return
58550 next
58700 rem generic item operations
58710 rt%=0:for j=0 to gc%:t%=og%(j,0)
58720 if t%=co% then t2%=j:gosub 42700
58730 if rt%=1 then return
58740 next
58750 if sk%=0 then t%=cv%(0):gosub 40600
58760 return

59000 rem show room description
59010 print:for i=0 to pl%-1:a$=rd$(i)
59020 gosub 59100
59040 next:gosub 62600:gosub 62500:return

59100 rem print without line break
59110 if len(a$)=40 then print a$;:return
59120 print a$:return

59200 rem load/save combined (ff%=0 or 1)
59210 print:p=0:if ff%=0 then open 2,8,2,fi$+",r":print"Lade...";
59220 if ff%=1 then open 2,8,2,fi$+",w":print"Speichere...";
59230 c%=ic%:gosub 59900:ic%=c%
59240 c%=od%:gosub 59900:od%=c%
59250 for i=0 to mi%
59260 c%=iv%(i):gosub 59900:iv%(i)=c%
59270 c%=uv%(i):gosub 59900:uv%(i)=c%
59280 c%=rs%(i):gosub 59900:rs%(i)=c%
59290 next
59300 for i=0 to mr%:for ii=0 to 8
59310 c%=rv%(i,ii):gosub 59900:rv%(i,ii)=c%
59315 if ii<4 then a$=lx$(i,ii):gosub 59950:lx$(i,ii)=a$
59320 next ii,i
59330 a$=rn$:gosub 59950:rn$=a$
59340 for i=0 to mx%
59350 a$=od$(i):gosub 59950:od$(i)=a$
59360 next
59370 close 2
59380 if ff%=0 then gosub 63300:gosub 40100
59390 return

59800 rem io-error
59810 print:print "IO-Error: ";st:end

59850 p=p+1:if p>40 then print".";:p=0
59860 if (st and 191)<>0 then goto 59800
59870 return

59900 rem actual load/save of ints
59910 if ff%=0 then input#2,c%
59920 if ff%=1 then print#2,c%
59925 gosub 59850
59930 return

59950 rem actual load/save of strings
59960 if ff%=0 then input#2,a$:goto 59980
59965 if a$="" then a$="?"
59970 if ff%=1 then print#2,a$
59980 gosub 59850:if a$="?" then a$=""
59990 return



60000 rem init
60002 print "Einen Moment..."
60005 mx%=50:mr%=50:mi%=10:mc%=15:cb$=chr$(13)+"Was jetzt"
60006 al$="alles":ms%=5:dim i,ii,p,pp:fi$="savegame.dat"
60010 dim it$(10), il$(10), mv%(10), ti%: rem all items (mi%)
60020 dim rd$(22), pl%, rd%: rem current room's description
60030 dim ex$(8), xn$(8), lk%(8), el%: rem crt. room's exits and names
60035 dim lx$(50,3): rem flag, which exits are unlocked (mr%)
60040 dim ri$(8), il%: rem current room's items
60050 dim iv%(10), ic%: rem inventory (mi%)
60055 dim ip%(10), tc%: rem items still in the room (mi%)
60060 dim uv%(10): rem used (flag) from inventory (mi%)
60070 dim xp$(8), xx$(8), xc%: rem exits usable in the room
60080 dim cp$(8), cp%(8): rem lexer results
60090 dim cm$(mc%, 5), cv$(mc%): rem commands
60100 dim id$(10,5): rem item descriptions (mi%)
60110 dim rv%(50,8): rem additional room inventory (mr%)
60120 dim rs%(10): rem flag, that an item lies somewhere else (mi%)
60130 for i=0 to mr%:for p=0 to 8:rv%(i,p)=-1:next p,i: rem clear room inv.
60140 dim dr$(9):for i=0 to 9:read dr$(i):next: rem direction strings
60150 dim op%(8,10), op$(8,5), oc%: rem possible operations in a room
60160 dim od$(50), od%: rem operations applied (command ID_item 1_item_2) (mx%)
60170 dim og%(10,10), og$(10,5), gc%: rem ops. on items in the inventory (mi%)
60180 dim ac%(10): rem actions of the current operation
60800 rem test data
60810 iv%(0)=3:iv%(1)=1:ic%=2:rem lx$(0,0)="N"
60900 return

61000 rem replace semicolon with komma
61002 sx$="":li=1:for i=1 to len(tx$)
61010 c$=mid$(tx$,i,1)
61020 if c$<>";" then 61040
61030 sx$=sx$+mid$(tx$,li,i-li)+",":li=i+1
61040 next
61050 sx$=sx$+mid$(tx$,li,i-li)
61060 tx$=sx$:return

61200 rem load items
61205 lg$="Lade Gegenstaende...":gosub 63000
61206 ii=0:p=0
61220 open 2,8,2,"items.def"
61230 input#2,a$:ii=ii+1
61250 id$="":for i=1 to len(a$)
61260 sx$=mid$(a$,i,1):if sx$=";" then 61280
61270 id$=id$+sx$:next
61280 ii=val(id$):tf$=mid$(a$,i+1,1):mv%(ii)=1
61290 if tf$="0" then mv%(ii)=0
61300 it$(ii)=right$(a$,len(a$)-i-2)
61302 tx$=it$(ii):gosub 63100:il$(ii)=tx$
61305 gosub 61400
61310 if st=64 then 61330
61320 p=p+1:goto 61230
61330 lg$=str$(p+1)+" Gegenstaende geladen!"
61340 gosub 63000:ti%=p:close 2:return

61400 rem read item description
61405 t%=0
61410 input#2,a$: if a$="***" then return
61420 tx$=a$:gosub 61000:id$(ii,t%)=tx$:t%=t%+1:goto 61410

61500 rem load commands
61510 lg$="Lade Befehle...":gosub 63000
61520 p=0:open 2,8,2,"commands.def"
61530 input#2,a$:ii=val(a$)
61540 input#2,a$:pp=val(a$)
61545 input#2,a$:cv$(ii)=a$
61550 for i=0 to pp-1:input#2,a$
61560 cm$(ii,i)=a$
61570 next:if st<>64 then p=p+1:goto 61530
61580 lg$=str$(p+1)+" Befehle geladen!"
61590 gosub 63000:tb%=p:close 2:return

62000 rem load room data
62005 gosub 62100:open2,8,2,rn$:input#2,a$:rd%=val(a$)
62010 input#2,a$
62020 if a$="***" then md%=md%+1:goto 62050
62030 tx$=a$:gosub 61000:a$=tx$
62040 on md% gosub 62200, 62300, 62400, 42000
62050 if st=64 then close 2:gosub 62800:return
62060 goto 62010

62100 rem init room data
62110 for i=0 to pl%:rd$(i)="":next
62120 md%=1:pl%=0:el%=0:il%=0:oc%=0
62130 return

62200 rem assign room description
62210 rd$(pl%)=a$
62220 if (len(a$)=40) then print a$;:goto 62240
62230 print a$
62240 pl%=pl%+1:return

62300 rem assign exits
62305 if len(a$)=0 then return
62310 ii=1:for i=1 to len(a$)
62320 if (mid$(a$,i,1)=",") then ii=i:i=256
62330 next
62340 ex$(el%)=right$(a$,len(a$)-ii-2)
62350 xn$(el%)=left$(a$,ii-1)
62360 lk%(el%)=val(mid$(a$,ii+1,1))
62370 el%=el%+1:return

62400 rem assign items
62405 if len(a$)=0 then return
62410 ri$(il%)=a$
62420 il%=il%+1:return

62500 rem print out directions
62510 gosub 62900
62520 if xc%=0 then return
62530 print "Ausgaenge sind: ";
62540 xc%=xc%-1:for i=0 to xc%
62550 if i>0 then print ", ";
62560 print xp$(i);:next:print:return

62600 rem print out items
62610 gosub 62750
62660 if tc%=0 then return
62670 print "Du siehst: ";
62680 for i=0 to tc%-1
62690 if i>0 then print ", ";
62700 print it$(ip%(i));:next:print:return

62750 rem calculate visible items
62752 if il%=0 then 62795
62755 tc%=0:for i=0 to il%-1:p=val(ri$(i)):ff%=0:if ic%=0 then 62775
62760 for ii=0 to ic%-1:if iv%(ii)=p then ff%=1:ii=ic%
62770 next ii:if ff%=1 then 62790
62775 if rs%(p)=1 then 62790
62780 ip%(tc%)=p:tc%=tc%+1
62790 next i
62795 gosub 41300:return

62800 rem adjust counts
62840 return

62900 rem calculate usable exits
62910 xc%=0:for i=0 to el%-1:p=1:if lk%(i)=0 then 62940
62920 p=0:for ii=0 to 3:tx$=lx$(rd%, ii):gosub 63100:a1$=tx$
62925 tx$=ex$(i):gosub 63100:a2$=tx$:if a1$=a2$ then p=1:ii=4
62930 next ii:if p=0 then 62950
62940 xp$(xc%)=ex$(i):xx$(xc%)=xn$(i):xc%=xc%+1
62950 next i:return

63000 rem output log message 
63010 print lg$chr$(13);:return

63100 rem convert tx$ to lower case
63105 c%=len(tx$):if c%=0 then return
63106 if c%=1 then gosub 63180:return
63110 sx$="":for pp=1 to len(tx$)
63120 c%=asc(mid$(tx$,pp,1))
63130 gosub 63250
63150 sx$=sx$+chr$(c%)
63160 next:tx$=sx$:return
63180 c%=asc(tx$): rem shortcut for one char
63190 gosub 63250
63210 tx$=chr$(c%):return

63250 rem convert
63260 if c%>=192 then c%=c%-128
63270 if c%>90 then c%=c%-32
63280 return

63300 rem clear output
63310 print chr$(14);chr$(147);:return

63400 data "n", "s", "w", "o", "nw", "sw", "no", "so", "h", "r"



