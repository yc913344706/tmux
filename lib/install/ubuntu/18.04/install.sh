#!/bin/bash

apt_update()
{
	[ -n "${TMUX_APT_UPDATED}" ] || {
		apt update -y
		TMUX_APT_UPDATED=true
	}
}

prepare_repo()
{
	[ -f "/etc/apt/sources.list.tmux.bak" ] || mv /etc/apt/sources.list /etc/apt/sources.list.tmux.bak
	cp ${WORKSPACE}/lib/repos/${OS}/${OS_VERSION}/sources.list /etc/apt/sources.list
}

install_tmux()
{
	command -v tmux > /dev/null && {
		log_info "tmux already installed"
		return 0
	}

	apt_update
	apt install -y tmux || die "install pkg failed: tmux"
}

install_tm()
{
	command -v tm > /dev/null && {
		log_info "tm already installed"
		return 0
	}

	command -v groupadd > /dev/null || die "cannot find cmd: groupadd"
	grep -q '^tm_team:' /etc/group  || groupadd tm_team

	V_tmux=$(echo | awk "{printf (\"%.0f\n\",$(tmux -V | awk '{print $2}') * 1000)}" )
	V_2_1=$(echo  | awk '{printf ("%.0f\n",2.1 * 1000)}' )
	V_1_8=$(echo  | awk '{printf ("%.0f\n",1.8 * 1000)}' )

	if [ ${V_tmux} -ge ${V_2_1} ]; then
		TM_CONF="${WORKSPACE}/etc/tmux/$(basename $SHELL)/2.1/tm.conf"
	elif [ ${V_tmux} -eq ${V_1_8} ]; then
		TM_CONF="${WORKSPACE}/etc/tmux/$(basename $SHELL)/1.8/tm.conf"
	else
		die "cannot find right tm.conf for your version: ${V_tmux}"
	fi

	[ -f "${TM_CONF}" ] || die "cannot find right tm.conf"
	[ -f "${WORKSPACE}/bin/$(basename $SHELL)/tm" ] || die "cannot find right tm"

	cp ${TM_CONF} /etc/

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
