#!/bin/bash

CBTP_DIRS="/usr/local/share/cbftp"

CBTP_FILES="/usr/local/bin/cbftp \
/usr/local/share/man/man1/cbftp.1"

user=`id -u -n`

[ "${user}" == "root" ] || {
  echo "Uninstall-bin.sh must be run as the root user."
  echo "Use 'sudo ./Uninstall-bin.sh ...'"
  echo "Exiting"
  exit 1
}

rm -f ${CBTP_FILES}
rm -rf ${CBTP_DIRS}
