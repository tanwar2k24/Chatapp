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
MC_DISTRO="Solaris"
MC_GROUP="mqttc"
MC_USER="mqttc"
MC_USERADD_HOME=/
export MC_DISTRO MC_GROUP MC_USER MC_USERADD_HOME

## END: DISTRO SPECIFIC PART

. "${MC_SOURCE}/bin/unix-like/install/common.inc"

# Override defaults in common.inc
SOURCE_INIT_DIR="${MC_SOURCE}/bin/unix-like/install/${MC_DISTRO}/init"
INIT_PATH="/lib/svc/method/http-mqttcool"
MANIFEST_PATH="/lib/svc/manifest/network/http-mqttcool.xml"
INIT_DIR=$(basename "${INIT_PATH}")

copy_init_script() {
    local manifest_name=$(basename "${MANIFEST_PATH}")
    local method_name=$(basename "${INIT_PATH}")
    cp -p "${SOURCE_INIT_DIR}/${manifest_name}" "${MANIFEST_PATH}" || return 1
    cp -p "${SOURCE_INIT_DIR}/${method_name}" "${INIT_PATH}" || return 1
}

setup_init_script_perms() {
    chmod 555 "${INIT_PATH}" || return 1
    chmod 444 "${MANIFEST_PATH}" || return 1
}

add_service() {
    if [ "${MC_ADD_SERVICE}" != "0" ]; then
        local mc_serv="svc:/network/http:mqttcool"
        svcadm restart "svc:/system/manifest-import" "${mc_serv}" &> /dev/null
        sleep 2
        svcadm enable "${mc_serv}" &> /dev/null
        echo "Init script installed at: ${INIT_PATH}"
        echo "It is set to automatically start at boot (and is also now online)"
        echo "You can restart MQTT.Cool using:"
        echo "  svcadm restart ${mc_serv}"
    fi
    return 0
}

show_intro || exit 1

echo "Installing to ${MC_DESTDIR}..."
setup_user_group && \
    copy_to_destdir && \
    setup_init_script && \
    add_service
