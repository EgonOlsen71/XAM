c1541 -format brotquest,bq d64 brotquest.d64
call compile.cmd
call ..\build\c1541 ..\build\brotquest.d64 -write ++brotquest.prg brotquest,p
call ..\build\c1541 ..\build\brotquest.d64 -write ++xam.prg xam,p
cd ..\build
cd ..\seq
for %%f in (*.*) do call :add "%%f"
cd ..\build
goto :EOF

:add
..\build\c1541 ..\build\brotquest.d64 -write %1 %1,s
