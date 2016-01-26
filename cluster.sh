#!/bin/bash
set -e

N=${1:-2}
CUR_DIR="$PWD"

function run_master()
{
  echo "$(docker run -it --name master -h master -d gustavonalle/infinispan-server-test)"
}

function run_slave()
{
  echo "$(docker run -it --name $1 -h $1 --link master:master -d gustavonalle/infinispan-server-test)"
}

function ip()
{
  echo "$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' $1)" 
}

function exec_cmd()
{
  docker exec $*
}

function create_user()
{
  exec_cmd master /opt/jboss/infinispan-server/bin/add-user.sh -u $1 -p $1

}

echo "Creating a cluster of $N nodes"

IDMASTER=$(run_master)
create_user master

IP_MASTER=$(ip $IDMASTER)

echo "Master created, ip address is $IP_MASTER"

START=1
for (( c=$START; c<=$N-1; c++)) 
do
 echo "Creating user for slave"
 create_user slave$c 
 IDSLAVE=$(run_slave slave$c) 
 echo  "Slave slave$c launched"
done

