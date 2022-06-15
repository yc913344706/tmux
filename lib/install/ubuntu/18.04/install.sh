#!/bin/bash

apt_update()
{
	[ -n "${TMUX_APT_UPDATED}" ] || {
		apt update -y
		TMUX_APT_UPDATED=true
	}
}

install_tmux()
{
	command -v tmux > /dev/null && {
		log_info "tmux already installed"
		return 0
	}

	[ -f "/etc/apt/sources.list.tmux.bak" ] || mv /etc/apt/sources.list /etc/apt/sources.list.tmux.bak
	cp ${WORKSPACE}/lib/repos/${OS}/${OS_VERSION}/sources.list /etc/apt/sources.list

	apt_update
	apt install -y tmux || die "install pkg failed: tmux"
}

install_tm()
{
	command -v tm > /dev/null && {
		log_info "tm already installed"
		return 0
	}

	command -v groupadd || die "cannot find cmd: groupadd"
	groupadd tm_team

	[ -f "${WORKSPACE}/etc/$(basename $SHELL)/tm.conf" ] || die "cannot find right tm.conf"
	[ -f "${WORKSPACE}/bin/$(basename $SHELL)/tm" ] || die "cannot find right tm"

	cp ${WORKSPACE}/etc/$(basename $SHELL)/tm.conf /etc/

	[ -d "/usr/local/sbin" ] || mkdir -p /usr/local/sbin 
	echo $PATH | grep -qw /usr/local/sbin || {
		echo 'PATH=/usr/local/sbin:$PATH' >> /etc/profile
	}

	cp ${WORKSPACE}/bin/$(basename $SHELL)/tm /usr/local/sbin/
	chmod 777 /usr/local/sbin/tm

}

ask_for_zsh()
{
	USE_ZSH=false
	read -p "do you want to change default shell to zsh? [y|yes]" ans

	ans=$(echo "$ans" | tr '[:upper:]' '[:lower:]')
	[ "${ans}" == "yes"  ] && USE_ZSH=true
	[ "${ans}" == "y"  ]   && USE_ZSH=true
}

install_zsh()
{
	[ "$(basename ${SHELL})" == "zsh" ] && {
		log_info "current shell is already zsh"
		return 0
	}

	ask_for_zsh
	${USE_ZSH} || {
		log_info "user choose not change default shell to zsh"
		return 0
	}

	command -v zsh || {
		apt_update
		apt install -y zsh || die "install pkg failed: zsh"
	}

	chsh -s `which zsh`
	SHELL=$(which zsh)

	[ -f '/etc/zshrc' ] || cp ${WORKSPACE}/etc/zshrc /etc/

	grep -qw 'tmux added' /etc/profile || {
		cat >> /etc/profile <<-'EOF'

		# tmux added
		[ -f "${HOME}/.zshrc" ] || cp /etc/zshrc ${HOME}/.zshrc
		EOF
	}

}
