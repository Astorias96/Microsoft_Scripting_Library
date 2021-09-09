@echo off
cls
set Hostname=%COMPUTERNAME%
Gpresult /h .\GPResult_%Hostname%.html /f
echo The report for the user "%username%" on "%hostname%" has been generated and saved to the following path:
echo %cd%\GPResult_%Hostname%.html
echo.
pause