## VARIABLES
MY_DESTDIR="${DESTDIR:-/}"
MC_DESTDIR="${MC_DESTDIR:-${MY_DESTDIR}/opt/mqtt.cool}"
MC_USER="${MC_USER:-mqttcool}"
MC_GROUP="${MC_GROUP:-mqttcool}"
# set to "0" to disable interactivity
MC_INTERACTIVE="${MC_INTERACTIVE:-1}"
# set to "0" to disable MQTT.Cool service activation
MC_ADD_SERVICE="${MC_ADD_SERVICE:-1}"
# make possible to override default MC_USER home directory
# (for Solaris)
MC_USERADD_HOME="${MC_USERADD_HOME:-/dev/null}"
# Linux useradd, default options
MC_USERADD_ARGS="${MC_USERADD_ARGS:--M -N}"
# Default MC_USER shell exec
MC_USERADD_SHELL="${MC_USERADD_SHELL:-/bin/false}"

# MC_DISTRO is set by the caller
SOURCE_INIT_NAME="${SOURCE_INIT_NAME:-mqttcool}"
SOURCE_INIT_PATH="${MC_SOURCE}/bin/unix-like/install/${MC_DISTRO}/init/${SOURCE_INIT_NAME}"
INIT_DIR="${INIT_DIR:-${MY_DESTDIR}/etc/init.d}"
INIT_PATH="${INIT_DIR}/${SOURCE_INIT_NAME}"
# manifest file supporting INIT_PATH, if needed
# this file, if provided, is part of the init system
# (on Solaris, for example)
MANIFEST_PATH="${MANIFEST_PATH:-}"
XML_INIT="${XML_INIT:-}"
# mktemp wrapper, required for FreeBSD and macOS
MKTEMP="${MKTEMP:-mktemp}"

block_non_root() {
    if [ "$(whoami)" != "root" ]; then
        echo "Please run this as superuser" >&2
        exit 1
    fi
}
block_non_root

show_intro() {
    echo "======================================================================="
    echo "MQTT.Cool Server Installation"
    echo
    echo "Source directory: MC_SOURCE = ${MC_SOURCE}"
    echo "Install (target) directory: DESTDIR = ${MY_DESTDIR}"
    echo "MQTT.Cool (target) directory: MC_DESTDIR = ${MC_DESTDIR}"
    echo "You can override DESTDIR and MC_DESTDIR"
    echo
    echo "Will create user: ${MC_USER}, group: ${MC_GROUP}"
    echo "You can override MC_USER and MC_GROUP"
    echo
    echo "JAVA_HOME and JAVA_OPTS are taken from mc.sh,"
    echo "as well as the optional MC_FILELIMIT;"
    echo "JAVA_HOME can be omitted if it is available"
    echo "in the installation execution environment;"
    echo "please edit bin/unix-like/mc.sh accordingly."
    echo "On the other hand, MC_CONFIG cannot be customized"
    echo "with this installation utility."
    echo
    echo "You need the following UNIX tools"
    echo "cp, grep, mv, sed"
    echo
    echo "======================================================================="
    echo
    if [ "${MC_INTERACTIVE}" != "0" ]; then
        echo "Press Enter to confirm, CTRL+C to cancel"
        read || exit 1
    fi
}

user_available() {
    grep "^${MC_USER}:" /etc/passwd > /dev/null
    return "${?}"
}

setup_user_group() {
    local res

    groupadd "${MC_GROUP}" 2> /dev/null
    res="${?}"
    if [ "${res}" != "9" ] && [ "${res}" != "0" ]; then
        # 9 is "group already exists"
        echo "Cannot add group ${MC_GROUP}" >&2
        return 1
    fi
    if ! user_available; then
        useradd ${MC_USERADD_ARGS} -d "${MC_USERADD_HOME}" -g "${MC_GROUP}" -s "${MC_USERADD_SHELL}" \
            "${MC_USER}" 2> /dev/null
        res="${?}"
        if [ "${res}" = "2" ]; then
            # wrong syntax, we have strict POSIX useradd
            useradd -d "${MC_USERADD_HOME}" -g "${MC_GROUP}" -s "${MC_USERADD_SHELL}" \
                "${MC_USER}" 2> /dev/null
            res="${?}"
        fi
        if [ "${res}" != "0" ]; then
            echo "Cannot add user ${MC_USER}" >&2
            return 1
        fi
    fi
    return 0
}

copy_to_destdir() {
    if [ ! -d "${MC_DESTDIR}" ]; then
        echo "Creating ${MC_DESTDIR}"
        mkdir -p "${MC_DESTDIR}" || return 1
    fi
    if [ ! -d "${MC_SOURCE}" ]; then
        echo "${MC_SOURCE} does not exist, exiting..." >&2
        return 1
    fi
    cp -Rp "${MC_SOURCE}"/* "${MC_DESTDIR}"/ || return 1
    chown -R "${MC_USER}":"${MC_GROUP}" "${MC_DESTDIR}" || return 1

    # make sure mc.sh is executable
    chmod 755 "${MC_DESTDIR}/bin/unix-like/mc.sh" || return 1

    echo "File copy complete"
}

copy_init_script() {
    if [ ! -d "${INIT_DIR}" ]; then
        echo "${INIT_DIR} not a directory" >&2
        return 1
    fi
    cp -p "${SOURCE_INIT_PATH}" "${INIT_DIR}/" || return 1
    chown root "${INIT_PATH}" || return 1
    # root group can be unavailable (macOS)
    chgrp root "${INIT_PATH}" &> /dev/null
    return 0
}

setup_init_script_perms() {
    chmod 744 "${INIT_PATH}" || return 1
}

setup_init_script() {
    copy_init_script || return 1

    # Tweak %MC_HOME%, %MC_USER%, %MC_GROUP%
    # Do it in a POSIX way
    tmp_file=$(${MKTEMP})
    if [ -z "${tmp_file}" ]; then
        return 1
    fi
    for path in "${INIT_PATH}" "${MANIFEST_PATH}"; do
        if [ -z "${path}" ]; then
            continue
        fi
        if [ -n "${XML_INIT}" ]; then
            sed -e "s:%MC_HOME%:${MC_DESTDIR/${DESTDIR}}:" -e \
                "s:%MC_USER%:${MC_USER}:" -e \
                "s:%MC_GROUP%:${MC_GROUP}:" "${path}" > "${tmp_file}" || return 1
        else
            sed -e "s:%MC_HOME%:\"${MC_DESTDIR/${DESTDIR}}\":" -e \
                "s:%MC_USER%:\"${MC_USER}\":" -e \
                "s:%MC_GROUP%:\"${MC_GROUP}\":" "${path}" > "${tmp_file}" || return 1
        fi
        cat "${tmp_file}" > "${path}" || return 1
        rm -f "${tmp_file}"
    done
    setup_init_script_perms || return 1
}
