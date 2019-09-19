#!/usr/bin/env sh

set -xeo pipefail

setup-ntp -c chrony
setup-apkrepos http://dl-cdn.alpinelinux.org/alpine/v3.9/main/ http://dl-cdn.alpinelinux.org/alpine/v3.9/community/

apk add --no-cache expect  #util-linux coreutils
apk add --no-cache haveged

rc-update add haveged boot
service haveged start

export DISKOPTS="-L"
expect <<EOF
set timeout 300

spawn setup-alpine

expect "Select keyboard layout**"
send "fr\r"

expect "Select variant**"
send "fr-azerty\r"

expect "Enter system hostname**"
send "${VM_NAME}\r"

expect "Which one do you want to initialize**"
send "eth0\r"

expect "Ip address for eth0**"
send "dhcp\r"

expect "Do you want to do any manual network configuration**"
send "no\r"

expect "New password:"
send "${ROOT_PASSWORD}\r"

expect "Retype password:"
send "${ROOT_PASSWORD}\r"

expect "Which timezone are you in**"
send "Europe/Paris\r"

expect "HTTP/FTP proxy URL**"
send "none\r"

expect "Enter mirror number**"
send "done\r"

expect "Which SSH server**"
send "openssh\r"

expect "Which disk*s* would you like to use**"
send "vda\r"

expect "How would you like to use it**"
send "sys\r"

expect "WARNING: Erase the above disk*s* and continue**"
send "y\r"

expect eof
EOF

# Remove expect package
apk del --no-cache expect

sync

reboot
