@echo off
cls
where /q portqry
IF ERRORLEVEL 1 (
    echo The portqry binary is missing. You can download and install it using the following link: https://www.microsoft.com/download/details.aspx?id=17148
    echo.
    pause...
    exit /B
) ELSE (
    echo The portqry binary exists. Beginning the operations.
    echo.
)
echo This utility will prompt you to provide a hostname / IP address and a TCP port(s) to scan.
SET /P server=Please enter the hostname / IP address here and press enter: 
SET /P ports=Please enter the port(s) to scan here (seperated by comma, e.g. 8080,443,123) and press enter: 
echo.
portqry -n %server% -p tcp -o %ports% -l .\%server%_tcp_connectivity_results.txt
echo.
echo The output file has been saved on the following path: .\%server%_tcp_connectivity_results.txt
pause...