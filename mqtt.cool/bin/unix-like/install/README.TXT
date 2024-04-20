MQTT.Cool INSTALL INSTRUCTIONS FOR UNIX-LIKE SYSTEMS
======================================================================

Quick Install requires a very limited UNIX knowledge and is geared towards
fresh installations. Using the install scripts listed above also works
for upgrades, but YOU ARE GOING to lose any customization for those config
files owned by the MQTT.Cool package.

------------
INTRODUCTION
------------

Inside this directory you can find ready-to-use install scripts for the
major Linux distributions and their derivatives (for example: the Debian
install script also works on Ubuntu, etc), OpenBSD, FreeBSD, macOS and
Solaris.
These are BASH scripts, please use at least version 3 (ksh should be
OK as well).

Debian/
---> install.sh
---> init/mqttcool

FreeBSD/
---> install.sh
---> init/mqttcool

Gentoo/
---> install.sh
---> init/mqttcool

macOS/
---> install.sh
---> init/com.mqttcool.server.plist

OpenBSD/
---> install.sh
---> init/mqttcool

openSUSE/
---> install.sh
---> init/mqttcool

Redhat/
---> install.sh
---> init/mqttcool

Solaris/
---> install.sh
---> init/http-mqttcool
---> init/http-mqttcool.xml


The install script must be run as root, using the following call:

# cd <DISTRO> && bash install.sh

The default installation directory is set by the DESTDIR env variable.
If this variable is set, MQTT.Cool will be installed in
MC_DESTDIR="${DESTDIR}/opt/mqtt.cool" and the installed launch script
will address the Server through a path relative to MC_DESTDIR.
On the other hand, if DESTDIR is not set, MQTT.Cool will be installed
in MC_DESTDIR="/opt/mqtt.cool" and the installed launch script
will address the Server through an absolute path.

In both cases, you can override MC_DESTDIR by prefixing the install.sh
call with MC_DESTDIR=/my/other/full/path, example:

# cd <DISTRO> && MC_DESTDIR=/my/other/root bash install.sh


By default, a "mqttcool" user belonging to a "mqttcool"
group will be referred and, if needed, created to be both the owner
of all the files deployed in MC_DESTDIR and the user that will be
running the installed instance.

In order to refer to a different user, you can override the MC_USER
and MC_GROUP variables at install time as follows:

# cd <DISTRO> && MC_USER=myuser MC_GROUP=mygroup bash install.sh

For macOS only, if a new user/group has to be created, they will
be assigned the ID 8888. If needed, the settings can be changed by
overriding the MC_NEW_USER_ID and MC_NEW_GROUP_ID variables at install
time as follows:

# cd <DISTRO> && MC_NEW_USER_ID=9876 MC_NEW_GROUP_ID=6789 bash install.sh


The installation is interactive and you will need to press Enter
before the actual process starts.

-------------------------
OTHER LINUX DISTRIBUTIONS
-------------------------

If your distribution doesn't belong to any of the above, you can
still manually install MQTT.Cool by copying the whole
package content to /opt/mqtt.cool and following the standard
MQTT.Cool deployment documentation.
In particular, you should run MQTT.Cool as unprivileged
user using the startup scripts at bin/unix-like/.

--------------------------
RUNNING THE SERVER AS ROOT
--------------------------

If you need to install MQTT.Cool having it run as root,
you can either change MC_USER and MC_GROUP variables in
/etc/init.d/mqttcool after installation or override the same
at install time as follows:

# cd <DISTRO> && MC_USER=root MC_GROUP=root bash install.sh

In the latter case, note that all the files deployed in MC_DESTDIR
will have root as their owner; you may change the owner to a suitable
user by acting manually.

You may need to run the Server as root in order to let it listen
on HTTP port 80 or HTTPS port 443, as recommended in production
environments (although other ways to achieve that are available).

---------------------------------------------
JAVA_HOME, JAVA_OPTS AND OTHER CUSTOMIZATIONS
---------------------------------------------

You are asked to properly configure JAVA_HOME and JAVA_OPTS inside
${MC_DESTDIR}/bin/unix-like/mc.sh after install to match your environment.
If you choose to supply JAVA_HOME as an environment variable,
the variable needs to be included in the installation execution environment.
Not doing so, may result in a startup failure.

In some environments, a proper configuration of MC_FILELIMIT in
${MC_DESTDIR}/bin/unix-like/mc.sh may also be needed, to ensure that the
Server is granted the desired number of file descriptors (for TCP sockets).

On the other hand, overriding the default path of the Server main
configuration file is not supported for this kind of installation.

--------------------------------------
RUNNING THE INSTALLER PROGRAMMATICALLY
--------------------------------------
In order to use install.sh inside 3rd party code, it is
possible to tweak its behaviour through several environment
variables:

- MC_INTERACTIVE="0"
Disable install.sh script interactivity.

- MC_ADD_SERVICE="0"
Disable MQTT.Cool service (init script) activation.

MC_INTERACTIVE and MC_ADD_SERVICE are both set to "1" by default.
