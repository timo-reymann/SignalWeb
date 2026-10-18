#!/bin/sh
#
# Recreate /run/dbus, because 08-clear-tmp-dir.sh wipes /run on every start.
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

mkdir -p /run/dbus
chown "${USER_ID:-1000}:${GROUP_ID:-1000}" /run/dbus

# vim:ft=sh:ts=4:sw=4:et:sts=4
