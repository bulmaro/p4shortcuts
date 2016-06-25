setlocal
set P4PORT=0novwseap4proxy.tsi.lan:1670
set STREAM=//depot/main
p4 login -p
%~dp0\enlist //depot/main d:\p4\ops
