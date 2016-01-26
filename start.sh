#!/bin/bash

IP=$(ip a s | sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}')

if [ -n "${MASTER_PORT_9990_TCP_ADDR}" ]; then
  DOMAIN="-Djboss.domain.master.address=$MASTER_PORT_9990_TCP_ADDR --host-config=host-slave.xml"
  BASE=$(echo -n $HOSTNAME | base64) && sed -i "s/\<secret value=.*/secret value=\"$BASE\" \/>/" /opt/jboss/infinispan-server/domain/configuration/host-slave.xml
else
  DOMAIN=""
  START=1
  for (( c=$START; c<=$SLAVES-1; c++)) 
   do
    echo "Creating user for slave $c"
    /opt/jboss/infinispan-server/bin/add-user.sh -u slave$1 -p slave$1 
   done
fi


exec /opt/jboss/infinispan-server/bin/domain.sh -Djboss.bind.address.management=0.0.0.0 $DOMAIN -Djgroups.bind_addr=$IP -Djboss.bind.address=$IP -Djgroups.join_timeout=1000 "$@"

