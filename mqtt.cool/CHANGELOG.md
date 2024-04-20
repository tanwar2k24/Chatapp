2.1.0 build 691 (04 Sep 2021)
-----------------------------

**Improvements**

- Embedded new Lightstreamer Server version 7.2.0: see the related 
  [changelog](https://www.lightstreamer.com/repo/distros/Lightstreamer_7_2_0_YYYYMMDD.zip%23/Lightstreamer/CHANGELOG.HTML#server") for details.

- Increased minimum required Java version to 11.

- Revised the following files to reflect changes relative to new embedded version of Lightstreamer Server (see inline comments for details):
  - `<MQTT.COOL_HOME>/conf/configurations.xml`
  - `<MQTT.COOL_HOME>/conf/log_configuration.xml`
  - `<MQTT.COOL_HOME>/conf/editions.xml`
  - `<MQTT.COOL_HOME>/PRODUCTION_SECURITY_NOTES.TXT`
  - `<MQTT.COOL_HOME>/Lightstreamer Software License Agreement.pdf`

- Revised the launch scripts `mc.bat` and `mc.sh` to look for a JAVA_HOME environment variable, unless a JAVA_HOME variable setting is manually added in the script.

- Updated the included version of the _mqtt.cool-hook-java-api_ library from `1.2.0` to `1.3.0`: see the related [changelog](https://github.com/MQTTCool/mqtt.cool-hook-java-api/blob/v1.3.0/CHANGELOG.md) for details. The library is now packaged with full version in the file name (`mqtt.cool-hook-java-api-1.3.0.jar`).

- Updated the included version of the third-party libraries of Test Client as follows:
  - _jquery_, from `3.2.1` to `3.5.1`
  - _bootstrap_, from `4.1.1` to `4.6.0`
  - _mqtt.cool-web-client_, from `1.2.0` to `1.2.4`

- Updated the included versions of some third-party libraries; also added a few more libraries and removed some.

- Modified the documentation under `<MQTT.COOL_HOME>/docs` as follows as per new embedded version of Lightstreamer Server:
  - Updated `MQTT.Cool Clustering.html`.
  - Applied slight style changes to `MQTT.Cool SSl Certificates.html`.
  - Slightly revised the _Quick Start_ section of `MQTT.Cool Getting Started Guide.html`, with the new instructions about the `JAVA_HOME` variable.
  - Updated references to the latest versions of `mqtt.cool-client-web` and `mqtt.cool-hook-java-api` in `MQTT.Cool Getting Started Guide.html`.


**Bug Fixes**

- Fixed the `<MQTT.COOL_HOME>/audit/README.TXT` file, by adding a statement relative to the online license validation.
- Added references to _MQTT.Cool Hook Java API_ in the `<MQTT.COOL_HOME>/Third-Party License Agreements.txt` file.
- Removed duplication of _Font Awesome Free License_ in the `<MQTT.COOL_HOME>/Third-Party License Agreements.txt` file.
- Fixed typos in this changelog.



2.0.0 build 541 (18 Mar 2020)
-----------------------------

**Improvements**

- Embedded new Lightstreamer Server version 7.1.0: see the related 
  [changelog](https://www.lightstreamer.com/repo/distros/Lightstreamer_7_1_0_20200124.zip%23/Lightstreamer/CHANGELOG.HTML#server") for details.
- Renamed the configuration files under `<MQTT.COOL_HOME>/conf` as follows:
  - From `lightstreamer_conf.xml` to `configuration.xml` (renamed the root element `<lightstreamer_conf>` as `<mqttcool>`).
  - From `lightstreamer_log_conf.xml` to `log_configuration.xml`.
  - From `mqtt_edition_conf.xml` to `edition.xml` (renamed root element `<mqttcool_edition_conf>` as `<mqttcool_edition>`).

  Furthermore, these files have been revised to reflect changes relative to new embedded version of Lightstreamer Server (see inline comments for details).
- Removed the `<MQTT.COOL_HOME>/mqtt_connectors` folder, whose files have been rearranged as follows:
   - Moved the `mqtt_master_connector_conf.xml` file to `<MQTT.COOL_HOME>/conf/brokers_configurations.xml`. In addition:
     - Renamed root element `<mqtt_master_connector_config>` as `<mqttcool_brokers_config>`.
     - Removed log configuration parameter (`<param name="log_config">..</param>`), which now is no longer needed.
     - Simplified previous Hook configuration (`<param name="hook">..</param>`),through the new `<hook_class>` element. 
     - Renamed element `<master_connector>` as `<configurations>`.
     - Introduced a new configuration parameter (`<param name=<connection_alias>.basic_statistics_log_interval>..</param>`) to log basic statistics.  
     See inline comments for details.
   - Merged `<MQTT.COOL_HOME>/mqtt_connectors/mqtt_master_connector_log_conf.xml` into `<MQTT.COOL_HOME>/conf/log_configuration.xml`, by moving the  MQTT.Cool specific logging settings to the first part of the file.
   - Moved the `<MQTT.COOL_HOME>/mqtt_connectors/lib` folder to `<MQTT.COOL_HOME>/hook`, the brand new folder for the deployment of custom Hooks.
   - Moved Truststore and Keystore example files (`mosquitto_keystore_example.jks` and `mosquitto_truststore_example.jks`) into `<MQTT.COOL_HOME>/conf`.
- Renamed the batch files under `<MQTT.COOL_HOME>/bin/windows` as follows:
  - From `start_mc_as_application.bat` to `start.bat.`
  - From `stop_mc_as_application.bat` to `stop.bat`.
  - From `restart_mc_as_application.bat` to `restart.bat`.
  - From `background_start_mc_as_application.bat` to `background_start.bat`.
  - From `install_mc_as_service-nt.bat` to `install_as_service.bat`.
  - From `uninstall_mc_as_service-nt.bat` to `uninstall_as_service-nt.bat`.
- Updated the following documentation (under `<MQTT.COOL_HOME>/docs`) as per new embedded version of Lightstreamer Server:
  - `MQTT.Cool Clustering.html`.
  - `MQTT.Cool SSL Certificates.html`.
- Updated the Software license agreement file (`<MQTT.COOL_HOME>/Lightstreamer Software License Agreement.pdf`).
- Revised `<MQTT.COOL_HOME>/PRODUCTION_SECURITY_NOTES.TXT` and `<MQTT.COOL_HOME>/audit/README.TXT` with adjusted references to renamed configuration files.
- Updated the Test Client with a new predefined configuration relative to the public MQTT broker hosted at `tcp://broker.mqtt.cool`. Futhermore, improved instructions in the related `README.txt` file (under `<MQTT.COOL_HOME>/pages/test_client`).
- Updated the _MQTT.Cool Getting Started Guide_ as follows:
  - Introduced a new paragraph dedicated to the official [MQTT.Cool Docker image](https://hub.docker.com/r/mqttcool/mqtt.cool) in Section "Quick Start".
  - Adjusted references to the renamed and/or rearranged configuration and batch files.
  - To avoid confusion with the new  _MQTT 5 Shared Subscriptions_, the previous concept of "Shared subscriptions" has been now clarified and renamed as _Fanout subscriptions_, which supports a very different purpose.
  - Introduced the new `<MQTT.COOL_HOME>/hook` deployment folder in Section "The MQTT.Cool Hook".
  - Added clarifications relative to the `<MQTT.COOL_HOME>/hook/lib` folder in Section "Packaging, Configuration, and Deployment". In the same section, adjusted the instructions on how to specify the full qualified class name of the Hook.
  - Added explanation and example about new configuration parameter `basic_statistics_log_interval` in Appendix `Connection Parameters`.
  - Fixed various typos.

**Bug Fixes**

- Fixed the URL of the MQTT.Cool site linked by logo image in the courtesy HTML error page.
- Fixed the layout of the _JVM Memory Heap_ and _JVM Threads_ charts in the Monitoring Dashboard.


1.2.0 build 450 (19 Nov 2018)
-----------------------------

**Improvements**

- Embedded new Lightstreamer Server version 7.0.2: see the related [changelog](https://www.lightstreamer.com/repo/distros/Lightstreamer_7_0_2_20181003.zip%23/Lightstreamer/CHANGELOG.HTML#server") for details.
- Ensured runtime compatibility with Java 11 through the following steps:
    - Updated the included version of the _Javassist_ library from `3.22.0` to `3.23.0`.
    - Updated the launch script files (both `<MQTT.COOL_HOME>/bin/unix/mc.sh` and `<MQTT.COOL_HOME>\bin\windows\mc.bat`).
- Renamed the `mqttcool_edition.conf.xml` file as `mqttcool_edition_conf.xml`.
- Introduced new configuration elements in the `<enterprise_edition_details>` block of the `<MQTT.COOL_HOME>/conf/mqttcool_edition_conf.xml` file, in order to enable cloud-based license validation. See inline comments for details.
- Updated the included version of the _mqtt.cool-hook-java-api_ library from `1.1.0` to `1.2.0`: see the related [changelog](https://github.com/MQTTCool/mqtt.cool-hook-java-api/blob/v1.2.0/CHANGELOG.md) for details.
- Restyled the changelog file in _Markdown_: previous `<MQTT.COOL_HOME>/CHANGELOG.html` has been replaced with `<MQTT.COOL_HOME>/CHANGELOG.md`.
- Updated the included Welcome page, Monitoring Dashboard, and Test Client as follows:
    - Changed palette in order to adjust colors to the brand new [MQTT.Cool](https://mqtt.cool) site.
    - Replaced links to `lightstreamer.com` with new links to `mqtt.cool`.
- Updated the Test Client as follows:
    - Upgraded the included version of the _mqtt.cool-web-client_ library from `1.1.2` to `1.2.0`.
    - Added the `brokers.json` file into the Test Client deployment folder (`<MQTT.COOL_HOME>/pages/test_client`), in order to customize the predefined configurations of contactable MQTT brokers.
- Removed the `DOCS-SDKs` folder from the distribution package: now each SDK has its own [dedicated section](https://mqtt.cool/download) on the MQTT.Cool site.
- Revised the included documentation as follows:
  - Restyled `Lightstreamer Clustering.pdf` and `Lighstreamer SSL Certificates.pdf` in _AsciiDoc_. Moreover, the files have been renamed, respectively, as `MQTT.Cool Clustering` and `MQTT.Cool SSL Certificates`.  
    The HTML versions have been included into the distribution package inside the new `<MQTT.COOL_HOME>/doc` folder.  
    The PDF versions can be directly downloaded from the MQTT.Cool site, from the following locations:
    - [MQTT.Cool Clustering.pdf](https://docs.mqtt.cool/server/guides/MQTT.Cool+Clustering.pdf)
    - [MQTT.Cool SSL Certificates.pdf](https://docs.mqtt.cool/server/guides/MQTT.Cool+SSL+Certificates.pdf)
  - Removed `MQTT.Cool Getting Started Guide.pdf`, which can be downloaded from [MQTT.Cool Getting Started Guide.pdf](https://docs.mqtt.cool/server/guides/MQTT.Cool+Getting+Started+Guide.pdf), and moved `MQTT.Cool Getting Started Guide.html` into the `<MQTT.COOL_HOME>/doc` folder.

**Bug Fixes**

- Added the _log4j-over-slf4j_ module, which may be used by for logging purpose by some third-party libraries included in the MQTT.Cool server.
- Switched the positions of the launch buttons in the Welcome page.
- Fixed visualization of logo in the Courtesy Page in the case the internal Web Server is not enabled.



1.1.0 build 360 (30 Mar 2018)
-----------------------------

**Improvements**

- Embedded new Lightstreamer Server version 7: see the related [changelog](https://www.lightstreamer.com/repo/distros/Lightstreamer_7_0_0_20180228.zip%23/Lightstreamer/CHANGELOG.HTML#server") for details.
- Revised the license configuration, with the introduction of new `<MQTT.COOL_HOME>/conf/mqttcool_edition.conf.xml` configuration file, which replaces previous `<MQTT.COOL_HOME>/conf/mqttcool_version_conf.xml`. See inline comments for details.  
  In addition, a new mandatory `<edition_conf>` configuration element in the main configuration file `<MQTT.COOL_HOME>/conf/lightstreamer_conf.xml` has been introduced, replacing previous `<version_conf>`. See inline comments in the factory configuration file for details.
- Increased minimum required Java version to 8.

**Bug Fixes**

- Fixed typos in the `<MQTT.COOL_HOME>/mqtt_connectors/mqtt_master_connector_conf.xml` file.
- Fixed typos and statements in the _MQTT.Cool Getting Started Guide_.



1.0.3 b3 build 302 (11 Jan 2018)
-------------------------------

**Improvements**

- Enabled TLS/SSL connections between MQTT.Cool and MQTT brokers.  
  Secure channels can be either configured through new connection parameters to be specified in the
  `<MQTT.COOL_HOME>/mqtt_connectors/mqtt_master_connector_conf.xml` file, or by deploying custom Hooks that provide instances of the new `SecurityParams` class. See docs for more information.
- Added new sample configurations in `<MQTT.COOL_HOME>/mqtt_connectors/mqtt_master_connector_conf.xml`, along with related _JKS_ sample files, to show how to configure encrypted connections.
- Added the dedicated `MQTTCoolLogger.connections.ssl` logger in `<MQTT.COOL_HOME>/mqtt_connectors/mqtt_master_connector_log_conf.xml`, to report issues relative to TLS/SSL handshake management.  
  Changed default logging levels and improved inline comments of many loggers.
- Enabled the Test Client to specify the protocol to use for each new broker configuration. Users can now set up either plain or TLS/SSL connection by selecting the right schema from a list.  
  Improved management of broker configurations: it is now possible to change all parameters of the selected configuration.

**Bug Fixes**

- Fixed a bug that, in the case of only one client connected through a _Shared Connection_, prevented an unsubscribe request from reaching the MQTT broker.
- Fixed generation of log messages for the `MQTTCoolLogger` logger.  
  Added and improved log messages for initialization activities.


**1.0.3 b2 build 279 (16 Nov 2017)**
------------------------------------

**Improvements**

- Introduced a very simple MQTT.Cool test client (a.k.a _Test Client_), which can be launched from the Welcome page, for the purpose of testing the interaction between the MQTT.Cool server and MQTT brokers.



**1.0.3 b1 build 266 (29 Sep 2017)**
------------------------------------

First public release.
