#!/bin/bash


command -v realpath > /dev/null || {
    echo "you need install realpath before doing anything"
    exit 1
}

WORKSPACE="$(dirname $(realpath $0))"

. ${WORKSPACE}/lib/os/os_info.sh
. ${WORKSPACE}/lib/log.sh

get_os_info

install_file="${WORKSPACE}/lib/install/${OS}/${OS_VERSION}/install.sh"
[ -f "${install_file}" ] || die "cannot find install file for you os: ${OS}, os_version: ${OS_VERSION}"

. ${install_file}

install_tmux
install_zsh
install_tm

echo ""
log_info "you can start to use tm after re-login"
log_info "you can start to use tm after re-login"
log_info "you can start to use tm after re-login"
