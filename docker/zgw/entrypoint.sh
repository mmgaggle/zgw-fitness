#!/bin/bash
set -e

if [ "${COMPONENT}" == "zgw" ]
then
  # need to test if user already exists
  radosgw-admin user create \
    --uid zippy \
    --display-name zippy \
    --access-key ${AWS_ACCESS_KEY_ID:-zippy} \
    --secret-key ${AWS_SECRET_ACCESS_KEY:-zippy}

  /usr/bin/radosgw \
    --cluster ceph \
    --setuser $(id -u) \
    --setgroup $(id -g) \
    --default-log-to-stderr=true \
    --err-to-stderr=true \
    --default-log-to-file=false \
    --foreground \
    -n client.rgw \
    --no-mon-config
elif [ "${COMPONENT}" == "zgw-toolbox" ]
then
  sleep infinity
fi
