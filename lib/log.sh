#!/bin/bash

case $LOG_LEVEL in
        error)
               LOG_LEVEL=4
               ;;
        warn)
               LOG_LEVEL=3
               ;;
        info)
               LOG_LEVEL=2
               ;;
        debug)
               LOG_LEVEL=1
               ;;
        all)
               LOG_LEVEL=0
               ;;
        *)
               LOG_LEVEL=2
               ;;
esac

die()
{
    log_error "$*"
    exit 1
}

log_error()
{
        [ ${LOG_LEVEL} -le 4 ] || return 0
        date +"[ERROR] %F %T ${0##*/}: $*" >&2
}

log_warn()
{
        [ ${LOG_LEVEL} -le 3 ] || return 0
        date +"[WARN] %F %T ${0##*/}: $*" >&2
}

log_info()
{
        [ ${LOG_LEVEL} -le 2 ] || return 0
        date +"[INFO] %F %T ${0##*/}: $*"
}

log_debug()
{
        [ ${LOG_LEVEL} -le 1 ] || return 0
        date +"[DEBUG] %F %T ${0##*/}: $*"
}

