@echo off
net stop wuauserv
net stop cryptSvc
net stop bits
net stop msiserver
del /f /s /q "%systemroot%\SoftwareDistribution\*"
rd /s /q "%systemroot%\SoftwareDistribution"
del /f /s /q "%systemroot%\System32\catroot2\*"
rd /s /q "%systemroot%\System32\catroot2"
net start wuauserv
net start cryptSvc
net start bits
net start msiserver
