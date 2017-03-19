#!/bin/sh

set -- $(cat /proc/cmdline)
for x in "$@"; do
    case "$x" in foreman_data_url=*)
        wget -q "${x#foreman_data_url=}" -O - | sh
        ;;
    esac
done

