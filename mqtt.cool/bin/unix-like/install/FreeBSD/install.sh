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
MC_DISTRO="FreeBSD"
INIT_DIR="/usr/local/etc/rc.d"
MKTEMP="mktemp -t ls"
export MC_DISTRO INIT_DIR MKTEMP

add_service() {
    echo "Init script installed at: ${INIT_PATH}"
    echo "You should add mqttcool_enable=\"YES\""
    echo "to /etc/rc.conf in order to automatically start it"
    return 0
}

## END: DISTRO SPECIFIC PART

. "${MC_SOURCE}/bin/unix-like/install/common.inc"

user_available() {
    pw usershow "${MC_USER}" &> /dev/null
    return ${?}
}

setup_user_group() {
    pw groupshow "${MC_GROUP}" &> /dev/null
    if [ "${?}" != "0" ]; then
        # add group
        pw addgroup "${MC_GROUP}"
    fi
    if [ "${?}" != "0" ]; then
        echo "Cannot add group ${MC_GROUP}" >&2
        return 1
    fi

    if ! user_available; then
        pw useradd "${MC_USER}" -g "${MC_GROUP}" -d "${MC_USERADD_HOME}" -s /usr/bin/false
        if [ "${?}" != "0" ]; then
            echo "Cannot add user ${MC_USER}" >&2
            return 1
        fi
    fi
    return 0
}

show_intro || exit 1

echo "Installing to ${MC_DESTDIR}..."
setup_user_group && \
    copy_to_destdir && \
    setup_init_script && \
    add_service
