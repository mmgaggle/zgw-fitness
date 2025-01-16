# Z is for zipper: S3 gateway

zgw-dbstore is a light weight S3 server dialect based on the Ceph object
gateway that persists objects and metadata into a SQLite database. If you've
ever wanted to use Ceph's object gateway, without deploying a cluster, this is
for you!

The Ceph object gateway has conventionally carried the name radosgw, or rgw for
short. [RADOS](https://ceph.com/assets/pdfs/weil-rados-pdsw07.pdf) is Ceph's
native object storage system. Sans RADOS, the radosgw is the /zgw/.

This was made possible by the Zipper initiative, which introduced a layering API
based on stackable modules/drivers, similar to Unix filesystems (VFS). A number
of store drivers SALs exist already:

* [DBstore](https://github.com/ceph/ceph/tree/main/src/rgw/store/dbstore) - Reference implementation
* [cortx-rgw](https://github.com/Seagate/cortx-rgw) for [Seagate CORTX](https://github.com/Seagate/cortx)
* [daos](https://github.com/ceph/ceph/pull/47709) for [Intel DAOS](https://github.com/daos-stack/daos)
* [sfs](https://github.com/aquarist-labs/ceph/tree/s3gw/src/rgw/store/sfs) for [SUSE s3gw](https://github.com/aquarist-labs/s3gw-tools/)

This repository is intended to provide tooling to build container images for
the Ceph object gateway with the dbstore store driver.

# minikube zgw-dbstore

## Create zgw-dbstore resources

```
kubectl apply -f zgw-dbstore.yaml
```

## Create toolbox resources

The toolbox includes pre-configured CLI tools to interact with zgw-dbstore:

* s5cmd: blazing fast s3 client
* warp: s3 benchmarking utility

To create a toolbox pod, use:

```
kubectl apply -f zgw-toolbox.yaml
```

## Enter zgw-toolbox pod

```
TOOLBOX_ID=$(kubectl get po | grep toolbox | awk '{print $1}')
kubectl exec --stdin --tty ${TOOLBOX_ID} -- /bin/bash
```

## Using s5cmd

The container entrypoint sets up credentials for s5cmd.

```
s5cmd --endpoint-url http://s3.default.svc.cluster.local \
  mb s3://mybucket
```

Grab some sample data and upload it.

```
cd /tmp
curl -LO https://d37ci6vzurychx.cloudfront.net/misc/taxi+_zone_lookup.csv
s5cmd --endpoint-url http://s3.default.svc.cluster.local \
  cp taxi+_zone_lookup.csv s3://mybucket
```

## Query sample CSV object with S3 Select
```
aws s3api select-object-content \
  --endpoint-url http://s3.default.svc.cluster.local \
  --bucket 'mybucket' \
  --key 'taxi+_zone_lookup.csv' \
  --expression "SELECT * FROM S3Object s where s._2='\"Brooklyn\"'" \
  --expression-type 'SQL' \
  --input-serialization '{"CSV": {"FieldDelimiter": ",","RecordDelimiter": "\n" ,  "FileHeaderInfo": "IGNORE" }}' \
  --output-serialization '{"CSV": {"FieldDelimiter": ":"}}' /dev/stdout
```

## Run warp benchmark
```
warp put --host s3.default.svc.cluster.local:80 \
  --access-key zippy \
  --secret-key zippy \
  --duration 15s
```

# podman zgw-dbstore

Set environmental variables if you want to override the default set of
credentials for the `zippy` user.

```
podman run -it zgw:latest \
  -v /mnt:/var/lib/ceph \
  -e ACCESS_KEY=$AWS_ACCESS_KEY \
  -e SECRET_KEY=$AWS_SECRET_KEY
```

# Building containers

## Building zgw:dbstore container

```
docker build -t zgw docker/zgw
```
