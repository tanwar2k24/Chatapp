#!/bin/sh

_MC_SOURCE=$(dirname "${0}")
if [[ "${_MC_SOURCE}" = "." ]]; then
    _MC_SOURCE=$(dirname "${PWD}")
elif [[ -z "$(echo ${_MC_SOURCE} | grep "^/" 2> /dev/null)" ]]; then
    _MC_SOURCE="${PWD}"
else
    _MC_SOURCE=$(dirname "${_MC_SOURCE}")
fi
_MC_SOURCE=$(dirname "${_MC_SOURCE}")
_MC_SOURCE=$(dirname "${_MC_SOURCE}")
MC_SOURCE=$(dirname "${_MC_SOURCE}")
export MC_SOURCE

## DISTRO SPECIFIC PART
MC_DISTRO="Gentoo"
export MC_DISTRO

add_service() {
    if [ "${MC_ADD_SERVICE}" != "0" ]; then
        rc-update add "${SOURCE_INIT_NAME}" default 2> /dev/null
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
