#!/usr/bin/env sh

OS_VERSION=$(echo "$BALENA_HOST_OS_VERSION" | cut -d " " -f 2)
echo "OS Version is $OS_VERSION"

. /usr/src/app/zfs-utils.sh

for file in "$MOD_PATH"/spl.ko "$MOD_PATH"/zfs.ko; do
	_modname="$(basename --suffix=.ko "${file}")"
	if ! lsmod | grep -w -q "${_modname}" && ! grep -q -w "${_modname}" "/lib/modules/$(uname -r)/modules.builtin"; then
		echo Loading module from "$file"
		insmod "$file" || true
	fi
done

if ! lsmod  | grep -q zfs; then
	echo "[FATAL]: ZFS module not loaded."
	exit 1
fi

if [ -n "${FORMAT_DISK}" ]; then
	zfs_setup "$FORMAT_DISK"
else
	zfs_import
fi

if ! zfs_check_mounts; then
	echo "[FATAL]: No ZFS mounts found. Format disk?"
	exit 1
fi

echo "[INFO] All ZFS mounts are present."

if ! zfs_snapshot; then
	echo "[FATAL]: Failed to create snapshot."
	exit 1
fi

while true; do sleep infinity; done
