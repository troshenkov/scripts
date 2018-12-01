echo off

net time \\server /set /yes
cscript.exe \\server\netlogon\Drv_Ren.vbs //B "Z:\" %username%" (Document Server)" 
reg import \\server\netlogon\proxy-nimb-nnov-ru.reg
REG ADD "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\Autorun.inf" /ve /d "@SYS:DoesNotExist" /

