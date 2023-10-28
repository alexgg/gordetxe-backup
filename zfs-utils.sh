#!/bin/bash

set -e

pool_name="${2:-${POOL_NAME}}"
datasets="${3:-"${DATASETS}"}"

zfs_setup() {
    local _disk
    local _pool_name
    local _datasets
    local _dataset
    _disk="${1}"
    _pool_name="${2:-${pool_name}}"
    _datasets="${3:-${datasets}}"

    [ -z "${_disk}" ] && echo "ERROR: No disk provided" && exit 1
    [ -z "${pool_name}" ] && echo "ERROR: No pool name provided" && exit 1

    if findmnt -no SOURCE "${_disk}" > /dev/null; then
        echo "ERROR: Disk ${_disk} is mounted"
        exit 1
    fi

    echo "[WARN]: About to format ${_disk} - all data will be lost!"
    sleep 30

    echo "[INFO]: Creating zpool ${_pool_name} in ${_disk}"

    zpool create -f "${_pool_name}" "${_disk#/dev/}"

    for _dataset in ${_datasets}; do
        echo "[INFO]: Creating dataset ${_dataset}"
        zfs create "${_dataset}"
        zfs set compression=lz4 "${_dataset}"
        if [ "$(zfs get compression -H -o value "${_dataset}")" != "lz4" ]; then
            echo "ERROR: Failed to set compression for ${_dataset}"
            exit 1
        fi
    done
}

zfs_import() {
    local _pool_name
    _pool_name="${2:-${pool_name}}"
    [ -z "${pool_name}" ] && echo "ERROR: No pool name provided" && exit 1
    if ! zpool import "${_pool_name}"; then
        echo "ERROR: Failed to import ${_pool_name}"
        exit 1
    fi
}

zfs_snapshot_dataset() {
    local _dataset
    local _snapshot
    _dataset="$1"
    _snapshot="${2:-$(date +%s)}"

    [ -z "${_dataset}" ] && echo "ERROR: No dataset provided" && exit 1
    [ -z "${_snapshot}" ] && echo "ERROR: No snapshot provided" && exit 1

    echo "[INFO]: Creating snapshot ${_snapshot} for ${_dataset}"
    zfs snapshot "${_dataset}@${_snapshot}"
}

zfs_snapshot() {
    local _dataset
    local _datasets
    _datasets="${1:-${datasets}}"

    for _dataset in ${_datasets}; do
        if ! zfs_snapshot_dataset "${_dataset}"; then
            return 1
        fi
    done
}

zfs_check_mounts() {
    local _dataset
    local _datasets
    _datasets="${1:-${datasets}}"

    for _dataset in ${_datasets}; do
        if [ "$(zfs get mounted -H -o value "${_dataset}")" != "yes" ]; then
            if ! zfs mount "${_dataset}"; then
                echo "ERROR: Dataset ${_dataset} is not mounted"
                return 1
            fi
        fi
    done
}
