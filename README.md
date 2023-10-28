# rsync-server

A dockerized `rsyncd` server.

## Start the server

```shell
docker run \
    --name backup \
    -p 873:873 \
    -e USERNAME=username \
    -e PASSWORD=password \
    aggurio/gordetxe-backup:latest
```
Variable options:

* `USERNAME` - `rsync` username. Defaults to `username`.
* `PASSWORD` - `rsync` password. Defaults to `password`.
* `POOL_NAME` - The main ZPS pool name.
* `DATASETS` - Space separated list of ZFS dataset names in the format '<pool_name>/<dataset>'
* `FORMAT_DISK` - Name of the external drive to reformat as a ZFS pool, for example '/dev/sda'

## Usage

```shell
rsync -av /your/folder/ rsync://username@localhost:8073/pool/dataset/
```
