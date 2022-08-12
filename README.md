# Z is for zipper, a S3 gateway

zgw-dbstore is a light weight S3 server dialect based on the Ceph object
gateway that persists objects and metadata into a SQLite database.

The Ceph object gateway has conventionally has been the radosgw, or rgw for short.
Sans RADOS, the rgw is the /zgw/.

This was made possible by the Zipper initiative, which introduced a layering API
based on stackable modules/driver, similar to Unix filesystems (VFS). Other
store drivers are starting to be developed:

* DBstore
* [CORTX](https://github.com/Seagate/cortx) [cortx-rgw](https://github.com/Seagate/cortx-rgw)
* [DAOS](https://github.com/daos-stack/daos) [daos](https://github.com/ceph/ceph/pull/45888)
* [s3gw](https://github.com/aquarist-labs/s3gw-tools/) [sfs](https://github.com/aquarist-labs/ceph/tree/s3gw/src/rgw/store/sfs)

This repository is intended to provide tooling to build container images for
the Ceph object gateway with the dbstore store driver, which persists objects
and metadata in a sqlite database.

# Getting Started

## Running zgw-dbstore with Kubernetes

```
kubectl apply -f zgw-dbstore.yaml
```

## Running zgw-dbstore with docker

Set environmental variables if you want to override the default set of
credentials for the `zippy` user.

```
podman run -it rgw-dbstore:latest \
  -v /mnt:/var/lib/ceph \
  -e ACCESS_KEY=$ACCESS_KEY \
  -e SECRET_KEY=$SECRET_KEY
```

# Toolbox

The toolbox includes pre-configured CLI tools to interact with zgw-dbstore:

* s5cmd: blazing fast s3 client
* warp: s3 benchmarking

## Running the toolbox in Kubernetes

```
kubectl apply -f zgw-toolbox.yaml
```

## Enter zgw-toolbox pod

```
kubectl exec --stdin --tty <TOOLBOX POD ID> -- /bin/bash
```

## Using s5cmd

The container entrypoint sets up credentials for s5cmd.

```
s5cmd mb s3://warp-benchmark
```

## Run warp benchmark
```
warp put --host 127.0.0.1:7480 \
         --access-key zippy \
         --secret-key zippy \
         --duration 10s
```

# Building containers

## Building zgw:dbstore container

```
docker build -t rgw-dbstore docker/zgw-dbstore
```
