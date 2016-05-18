#!/bin/bash

IP=$(ip addr list eth0 |grep "inet " |cut -d' ' -f6|cut -d/ -f1)

if [ -n "${MASTER_PORT_9990_TCP_ADDR}" ]; then
  DOMAIN="-Djboss.domain.master.address=$MASTER_PORT_9990_TCP_ADDR --host-config=host-slave.xml"
  BASE=$(echo -n $HOSTNAME | base64) && sed -i "s/\<secret value=.*/secret value=\"$BASE\" \/>/" /opt/jboss/infinispan-server/domain/configuration/host-slave.xml
else
  DOMAIN=""
  START=1
  /opt/jboss/infinispan-server/bin/add-user.sh -u admin -p admin 
  for (( c=$START; c<=$SLAVES; c++)) 
   do
    echo "Creating user for slave $c"
    /opt/jboss/infinispan-server/bin/add-user.sh -u slave$c -p slave$c 
   done
fi


exec /opt/jboss/infinispan-server/bin/domain.sh -Djboss.bind.address.management=0.0.0.0 $DOMAIN -Djgroups.bind_addr=$IP -Djboss.bind.address=$IP -Djgroups.join_timeout=1000 "$@"

