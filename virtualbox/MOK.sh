
#!/bin/bash

set -e

#
# VBoxNetAdpCtl: Error while adding new interface: failed to open /dev/vboxnetctl: No such file or directory.
# Or
# Could not load 'vboxdrv'
#

openssl req -new -x509 -newkey rsa:2048 -keyout MOK.priv -outform DER -out MOK.der -nodes -days 36500 -subj "/CN=MOK Signing/"

for modfile in $(dirname $(modinfo -n vboxdrv))/*.ko; do
  echo "Signing $modfile"
  /usr/src/linux-headers-$(uname -r)/scripts/sign-file sha256 ./MOK.priv ./MOK.der "$modfile"
done

sudo mokutil --import MOK.der && echo "Reboot you system ..."


