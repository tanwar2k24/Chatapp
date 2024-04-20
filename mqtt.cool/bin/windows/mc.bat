@echo off
rem Do not remove this line. File tag: mqtt.cool_windows_launch-2.1.0.

if "%OS%" == "Windows_NT" setlocal

rem ====================================================================
rem === CHECK THIS OUT
rem ====================================================================
rem JAVA_HOME should point to your Java Development Kit installation.
rem By default, a JAVA_HOME variable is looked up in the environment;
rem if missing, a java installation reachable from the system path is tried;
rem any explicit setting provided here will override.
rem
rem set JAVA_HOME=C:\Java\jdk-11

rem =======================================================================
rem === CHECK THIS OUT
rem =======================================================================
rem JAVA_OPTS should contain any Java Virtual Machine options. Here are some tips:
rem 1) Always use the "-server" option, when available.
rem 2) Give more RAM to the server process, especially with heavy traffic, by specifying a min and max "heap"
rem    E.g.: If you have 4 GB and the box is dedicated to MQTT.Cool, you might set 1 GB min heap and 3 GB max
rem    heap with these options: "-Xms1G -Xmx3G"
rem 3) Choose a better "garbage collector" if you want to reduce latency. This should not be needed since Java 9,
rem    but if you are using Java 8 (apart from early versions) we suggest you enforcing:
rem    "-XX:+UseG1GC". For previous versions, an option that often gives good results is:
rem    "-XX:+UseConcMarkSweepGC". Many other tuning options are available (please see Oracle docs).
rem 4) Configure the garbage collector in such a way as to prevent long pauses. If your Java installation
rem    offers a "pauseless" collector, we encourage you to use it. Otherwise, choose the maximum pause
rem    to be enforced, based on your latency and throughput requirements, but consider anyway that GC pauses
rem    cause the connection to stay idle and pauses longer than 4 or 5 seconds may cause the clients
rem    to timeout and reconnect.
set JAVA_OPTS=-server -XX:MaxGCPauseMillis=1000

rem --------------------------------------------------------------------


echo Java environment:
if "%JAVA_HOME%" == "" goto defaultJVMConfig
echo JAVA_HOME = %JAVA_HOME%
set JAVA="%JAVA_HOME%\bin\java.exe"
goto doneJVMConfig
:defaultJVMConfig
echo no JAVA_HOME defined: looking for java.exe on the system path
set JAVA="java.exe"
:doneJVMConfig
echo JAVA_OPTS = %JAVA_OPTS%
echo.

rem MC_HOME takes the current directory of mc.bat and goes up two dirs
set MC_HOME=%~dp0..\..\

echo MQTT.Cool Server directory:
echo MC_HOME = %MC_HOME%
echo.


rem Main configuration file: the default can be changed by the caller
rem by setting the optional MC_CONFIG variable to an absolute path

if not ""%MC_CONFIG%"" == """" goto doneConfig
set MC_CONFIG="%MC_HOME%\conf\configuration.xml"
:doneConfig

echo MQTT.Cool Server main configuration file:
echo MC_CONFIG = %MC_CONFIG%
echo.


rem Base Classpaths
set bootpath="%MC_HOME%\lib\ls-bootstrap.jar"
set kernelpath="%MC_HOME%\lib\lightstreamer.jar";"%MC_HOME%\lib\ls-adapter-interface.jar";"%MC_HOME%\lib\mqtt.cool-adapters.jar"

set intfpath="%MC_HOME%\lib\mqtt.cool-hook-java-api.jar"
set internalpath="%MC_HOME%\lib\ls-monitor.jar";"%MC_HOME%\lib\core\*"
set logpath="%MC_HOME%\lib\ls-logging-utilities.jar";"%MC_HOME%\lib\log\*"
set logbridgepath="%MC_HOME%\lib\log\bridge\*"

if ""%1"" == ""run"" goto doStart
if ""%1"" == ""silent"" goto doStart
if ""%1"" == ""background"" goto doStart
if ""%1"" == ""stop"" goto doStop
if ""%1"" == ""restart"" goto doStop
goto doHelp

:doStart

   echo Starting MQTT.Cool Server...
   echo Please check logs for detailed information.
   set class=com.lightstreamer.LS

   rem Classpath
   set cpath=%bootpath%;%intfpath%

   set KERNEL_LIB_PATH=-Dcom.lightstreamer.kernel_lib_path=%kernelpath%
   set INTERNAL_LIB_PATH=-Dcom.lightstreamer.internal_lib_path=%internalpath%;%logbridgepath%
   set LOGGING_LIB_PATH=-Dcom.lightstreamer.logging_lib_path=%logpath%

   goto doLaunch

:doStop

   echo Stopping MQTT.Cool Server...
   set class=com.lightstreamer.LS_Stop
   set JAVA_OPTS=

   rem Classpath
   set cpath=%bootpath%

   goto doLaunch

:doHelp

   echo Usage:  mc.bat ( command )
   echo commands:
   echo   run               Start MQTT.Cool Server in the current window
   echo   background        Start MQTT.Cool Server in a separate window
   echo   stop              Stop MQTT.Cool Server
   echo   restart           Stop MQTT.Cool Server and start a new instance in a separate window
   goto end


:doLaunch

rem Configuration file
set args=%MC_CONFIG%

if ""%1"" == ""run"" goto doForeground
if ""%1"" == ""silent"" goto doSilent
if ""%1"" == ""background"" goto doBackground
if ""%1"" == ""stop"" goto doStop
if ""%1"" == ""restart"" goto doSubcall

:doSubcall
   rem call command and wait
   set command=%JAVA% %JAVA_OPTS% -cp %cpath% %class% %args%
   call %command%
   %0 background
   goto end

:doForeground
   rem leave control to command
   set command=%JAVA% %JAVA_OPTS% %KERNEL_LIB_PATH% %INTERNAL_LIB_PATH% %LOGGING_LIB_PATH% -cp %cpath% %class% %args%
   %command%
   goto end

:doStop
   rem leave control to command
   set command=%JAVA% %JAVA_OPTS% -cp %cpath% %class% %args%
   %command%
   goto end

:doBackground
   rem call command in a separate window and leave
   set command=%JAVA% %JAVA_OPTS% %KERNEL_LIB_PATH% %INTERNAL_LIB_PATH% %LOGGING_LIB_PATH% -cp %cpath% %class% %args%
   if not "%OS%" == "Windows_NT" goto noTitle
   start "MQTT.Cool Server" %command%
   goto end
   :noTitle
      start %command%
      goto end

:doSilent
   rem rerun after output redirection (for run as a service)
   set output="%MC_HOME%\logs\LS.out"
   %0 run 1>> %output% 2>&1
   goto end

:end
exit /b %ERRORLEVEL%
