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
MC_DISTRO="macOS"
SOURCE_INIT_NAME="com.mqttcool.server.plist"
INIT_DIR="/Library/LaunchDaemons"
XML_INIT="1"
MKTEMP="mktemp -t ls"
export SOURCE_INIT_NAME INIT_DIR MC_DISTRO XML_INIT MKTEMP

add_service() {
    if [ "${MC_ADD_SERVICE}" != "0" ]; then
        launchctl unload "${INIT_PATH}" &> /dev/null
        launchctl load "${INIT_PATH}" 2> /dev/null || return 1
        echo "Init script installed at: ${INIT_PATH}"
        echo "It is set to automatically start at boot"
        echo "and to restart upon Server termination."
        echo "If you don't want this, please run:"
        echo "  sudo launchctl unload \"${INIT_PATH}\""
    fi
    return 0
}

## END: DISTRO SPECIFIC PART

MC_NEW_USER_ID="${MC_NEW_USER_ID:-8888}"
MC_NEW_GROUP_ID="${MC_NEW_GROUP_ID:-8888}"
. "${MC_SOURCE}/bin/unix-like/install/common.inc"

user_available() {
    dscl . -read /Users/"${MC_USER}" &> /dev/null
    return $?
}

group_available() {
    dscl . -read /Groups/"${MC_GROUP}" &> /dev/null
    return $?
}

setup_user_group() {
    group_available || {
        dscl . -create /Groups/"${MC_GROUP}" PrimaryGroupID "${MC_NEW_GROUP_ID}" &> /dev/null || {
            echo "Cannot add group ${MC_GROUP}" >&2
            exit 1;
        };
        dscl . -create /Groups/"${MC_GROUP}" RealName "MQTT.Cool" || exit 1
    }
    user_available || {
        dscl . -create /Users/"${MC_USER}" UniqueID "${MC_NEW_USER_ID}" || exit 1
        dscl . -create /Users/"${MC_USER}" RealName "MQTT.Cool" || exit 1
        dscl . -create /Users/"${MC_USER}" PrimaryGroupID "${MC_NEW_GROUP_ID}" || exit 1
        dscl . -create /Users/"${MC_USER}" UserShell /bin/bash || exit 1
        dscl . -append /Groups/"${MC_GROUP}" GroupMembership "${MC_USER}" || \
            exit 1;
     }
}

show_intro || exit 1

echo "Installing to ${MC_DESTDIR}..."
setup_user_group && \
    copy_to_destdir && \
    setup_init_script && \
    add_service
