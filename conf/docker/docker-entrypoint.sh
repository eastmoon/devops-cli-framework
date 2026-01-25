#!/bin/sh
# vim:sw=4:ts=4:et

set -e

if [ "$1" = "bash" ] || [ "$1" = "sh" ] || [ "$1" = "docker" ]; then
    exec "$@"
else
    devops-cli "$@"
fi
