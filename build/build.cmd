del brotquest_AD.d64
c1541 -format brotquest,bq d64 brotquest_AD.d64
call compile.cmd
call ..\build\c1541 ..\build\brotquest_AD.d64 -write ++brotquest.prg brotquest,p
call ..\build\c1541 ..\build\brotquest_AD.d64 -write ++xam-c.prg xam,p
call ..\build\c1541 ..\build\brotquest_AD.d64 -write raster.prg xam2,p
cd ..\build
cd ..\seq
for %%f in (*.*) do call :add "%%f"
cd ..\build
goto :EOF

:add
..\build\c1541 ..\build\brotquest_AD.d64 -write %1 %1,s
