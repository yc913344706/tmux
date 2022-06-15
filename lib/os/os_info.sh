#!/bin/bash

get_os_info()
{
    OS=$(cat /etc/os-release |grep ^NAME= | cut -d '"' -f 2 | tr [A-Z] [a-z])
    OS_VERSION=$(cat /etc/os-release |grep ^VERSION_ID= | cut -d '"' -f 2 | tr [A-Z] [a-z])

    [[ $OS =~ ^centos ]] && OS=$(cat /etc/os-release |grep ^ID= | cut -d '"' -f 2 | tr [A-Z] [a-z])
}
