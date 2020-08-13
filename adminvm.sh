#! /bin/bash

# Elevate to correct privileges
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Back to base path
cd ~

# Connect to Admin WS
connect=$(tail gke-admin-ws-* | grep "ssh -i")
connect+=" -tt"
echo $connect
$connect <<'EOT'


# Logout
exit
EOT

# End of script