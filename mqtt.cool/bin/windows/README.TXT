MQTT.Cool LAUNCH SCRIPTS FOR WINDOWS SYSTEMS
==============================================================

-------------
CONFIGURATION
-------------

Before launching any script, some configuration must be performed.

mc.bat leans on the JAVA_HOME environment variable. Follow the instructions
in the head section of the mc.bat file to supply it.
mc.bat also defines the JAVA_OPTS variable. Follow the instructions
in the head section of the mc.bat file to edit it.

On Windows systems it is possible to install MQTT.Cool as a Windows
service. A component called "NSSM" is used to wrap the MQTT.Cool
process within a Windows service in a transparent way. This means that
you can then start/stop MQTT.Cool through the standard Windows
Services console. MQTT.Cool is using a custom version of NSSM,
available (at the time of writing this document) at https://iain.cx/src/nssm.
The tool is available for both Windows 32 and 64-bit releases and the right
version is automatically selected for you by the provided helper batch files.

-----
USAGE
-----

- mc.bat

  General launch script. It must be called with one of the following options:

  - run         Start MQTT.Cool Server in the current shell window.
  - background  Start MQTT.Cool Server in a separate shell window.
  - stop        Stop MQTT.Cool Server.
  - restart     Stop MQTT.Cool Server and start a new instance
                in a separate shell window.

  The script also checks the MC_CONFIG environment variable;
  by setting it before running the script, it is possible to override
  the default path of the Server main configuration file.

  This script can be called from any directory.

- start.bat
- background_start.bat
- stop.bat
- restart.bat

  Shortcut scripts for "run", "background", "stop" and "restart" operations;
  they do not require parameters and can be invoked by point and click.
  These scripts can only be called from this directory.

NOTE on the "stop" and "restart" operations:
In order to stop a running Server, the "stop" and "restart" operations try
to access the Server process through the JMX interface; this requires that
the Server has successfully completed the initialization of JMX.
If the Server startup is slow, it is possible that an early attempt to stop
the Server will fail.

- install_mc_as_service-nt.bat
- uninstall_mc_as_service-nt.bat

  Scripts to be used to install and uninstall MQTT.Cool Server as a service;
  they do not require parameters and can be invoked by point and click.
  Please NOTE however that administrative privileges are required. So if you're
  running with unprivileged credentials, you have to make sure that the above
  scripts are executed with Administrator credentials.

  Furthermore, these scripts can only be called from this directory.
  Note that you shouldn't install MQTT.Cool Server in a user's folder,
  otherwise the service installed by the above script will not be able to start.
  In general, this is also a bad practice.

  If you want to change the default service display name, or the default service
  description, or the default service startup type, you may change the corresponding
  variables defined in the install_mc_as_service-nt.bat install script.
  Before running install_mc_as_service-nt.bat, we suggest checking if the
  Server configuration is correct by trying start.bat first.

  If you choose to supply JAVA_HOME as an environment variable,
  the variable needs to be included in the service execution environment.
  This has to be enforced manually.
  Likewise, If you want to override the default path of the Server main
  configuration file through the dedicated MC_CONFIG environment variable,
  the variable needs to be included in the service execution environment,
  and this has to be enforced manually.

- nssm.exe
- nssm_x64.exe

  Allows MQTT.Cool to be launched as a Windows service.
  This executable must not be invoked directly. While nssm.exe is
  for 32-bit architectures and nssm_x64.exe is for 64-bit ones,
  the batch files above are capable to select the right executable for
  your architecture automatically.

