@echo off

@REM ------------------------------------------Run bash script with administrator privilege------------------------------
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

Title Batch Script to get CPU %% and MEM %% Usage

setlocal
set "CpuUsage=0"
set "Processors=0"

@REM example: set "SplunkHome=C:\Program Files\Splunk\bin"
set "SplunkHome=ADD YOUR SPLUNK_HOME PATH!"

@REM ---------------------------------------------------Create file log------------------------------------------------- 
@REM if exist %SplunkHome%\var\log\rammon.txt (
@REM     echo "Log file already exists!"
@REM ) else (
@REM     echo "Create log file. . . "
@REM     dir >> %SplunkHome%\var\log\rammon.txt
@REM )

%SystemRoot%\System32\wbem\wmic.exe CPU get loadpercentage >"%TEMP%\cpu_usage.tmp"
for /F "skip=1" %%P in ('type "%TEMP%\cpu_usage.tmp"') do (
    set /A CpuUsage+=%%P
    set /A Processors+=1
)
del "%TEMP%\cpu_usage.tmp"

rem ----------------------------------Calculate the CPU usage as percentage value of all processors.--------------------
set /A CpuUsage/=Processors
goto GetTotalMemory

:GetTotalMemory
for /F "skip=1" %%M in ('%SystemRoot%\System32\wbem\wmic.exe ComputerSystem get TotalPhysicalMemory') do set "TotalMemory=%%M" & goto GetAvailableMemory
:GetAvailableMemory
for /F "skip=1" %%M in ('%SystemRoot%\System32\wbem\wmic.exe OS get FreePhysicalMemory') do set "AvailableMemory=%%M" & goto ProcessValues

:ProcessValues
set "TotalMemory=%TotalMemory:~0,-6%"
set /A TotalMemory+=50
set /A TotalMemory/=1073

set /A TotalMemory*=1024

set /A AvailableMemory/=1024

set /A UsedMemory=TotalMemory - AvailableMemory

set /A UsedPercent=(UsedMemory * 100) / TotalMemory

if "%Processors%" == "1" (
    set "ProcessorInfo="
) else (
    set "ProcessorInfo= of %Processors% processors"
)

@REM Main loop 
:loop
    if %UsedPercent% gtr 80 (
        echo Memory usage: %UsedPercent%
        echo Restart Splunk!
        %SplunkHome%\splunk restart
    )
    timeout  2
    goto :loop
    endlocal
