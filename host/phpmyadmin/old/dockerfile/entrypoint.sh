#!/bin/sh

# Support for stopping container with `Ctrl+C`

set -e

#xec apache2-foreground
rm -f /usr/local/apache2/logs/httpd.pid
/usr/sbin/apachectl -D FOREGROUND "$@"

