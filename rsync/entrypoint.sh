#!/bin/bash
set -e

USERNAME=${USERNAME:-username}
PASSWORD=${PASSWORD:-password}
ALLOW=${ALLOW:-10.0.0.0/8 192.168.0.0/16 172.16.0.0/12 127.0.0.1/32}
VOLUME=${VOLUME:-/gordetxe}

. /zfs-utils.sh

if ! zfs_check_mounts; then
	echo "[ERROR] ZFS mount failed"
	exit 1
fi

if [ ! -d "${VOLUME}" ]; then
	echo "[ERROR] ${VOLUME} does not exist"
	exit 1
fi

setup_volume() {
	_volume="${1}"
	_volname="$(basename "${1}")"
	_volume_entry=$(cat <<EOF
[${_volname}]
	uid = root
	gid = root
	hosts deny = *
	hosts allow = ${ALLOW}
	read only = false
	path = ${_volume}
	comment = ${_volname} directory
	auth users = ${USERNAME}
	secrets file = /etc/rsyncd.secrets

EOF
)
	echo "${_volume_entry}" >> /etc/rsyncd.conf
	echo "[INFO] ${_volname} volume setup done"
}

setup_volumes() {
	_volumes="${1}"
	[ -z "${_volumes}" ] && echo "[FATAL]: No volumes provided" && exit 1
	for _vol in ${_volumes}; do
		setup_volume "${_vol}"
	done
}

echo "$USERNAME:$PASSWORD" > /etc/rsyncd.secrets
chmod 0400 /etc/rsyncd.secrets
[ -f /etc/rsyncd.conf ] || cat > /etc/rsyncd.conf <<EOF
log file = /dev/stdout
timeout = 300
max connections = 10
port = 873
EOF

setup_volumes "${DATASETS}"

exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"
