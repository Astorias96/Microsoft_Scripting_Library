@echo off
cls
echo This utility will prompt you to provide a hostname / IP address to perform the tracert command.
SET /P server=Please enter the hostname / IP address here and press enter: 
echo.
echo Starting tracert. This can take some time (max 30 hops)... Use ctrl C to cancel the operation.
echo The output file on the following path is being appended: .\tracert_results.txt
echo.
tracert -d -w 5000 %server% > .\tracert_results.txt
echo.
echo The tracert has finished running and the output file has been saved.
pause...