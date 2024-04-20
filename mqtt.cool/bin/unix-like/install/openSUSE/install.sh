#!/bin/sh

_MC_SOURCE=$(dirname "${0}")
if [[ "${_MC_SOURCE}" = "." ]]; then
    _MC_SOURCE=$(dirname "${PWD}")
else
    _MC_SOURCE=$(dirname "${_MC_SOURCE}")
fi
_MC_SOURCE=$(dirname "${_MC_SOURCE}")
_MC_SOURCE=$(dirname "${_MC_SOURCE}")
MC_SOURCE=$(dirname "${_MC_SOURCE}")
export MC_SOURCE

## DISTRO SPECIFIC PART
MC_DISTRO="openSUSE"
MC_USERADD_ARGS="-m"
MC_USERADD_HOME="/home/mqttcool"
MC_USERADD_SHELL="/bin/sh"
export MC_DISTRO USERADD_ARGS MC_USERADD_HOME MC_USERADD_SHELL

add_service() {
    if [ "${MC_ADD_SERVICE}" != "0" ]; then
        chkconfig "${SOURCE_INIT_NAME}" on
        echo
        echo "Now type: /etc/init.d/mqttcool start"
        echo "to start MQTT.Cool"
    fi
    return 0
}
## END: DISTRO SPECIFIC PART

. "${MC_SOURCE}/bin/unix-like/install/common.inc"

show_intro || exit 1

echo "Installing to ${MC_DESTDIR}..."
setup_user_group && \
    copy_to_destdir && \
    setup_init_script && \
    add_service
