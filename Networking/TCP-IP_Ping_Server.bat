@echo off
cls
echo This utility will prompt you to provide a hostname or IP address to perform the ping request.
SET /P server=Please enter the information here and press enter: 
echo.
ping %server% -n 5
echo.
pause...