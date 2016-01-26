## Clustered Infinispan Server domain mode Docker image

### Quick Start

First launch the master that host the domain controller. The variable SLAVES must contain
the number of slaves that the cluster will have so that proper credentials can be created
beforehand. For a 3 node slave:

```
docker run -it --name master -h master -e "SLAVES=3" gustavonalle/infinispan-server-domain
```

Then launch the slaves, giving the proper host names:

```
docker run -it --link master:master -h slave1 gustavonalle/infinispan-server-domain
docker run -it --link master:master -h slave2 gustavonalle/infinispan-server-domain
docker run -it --link master:master -h slave3 gustavonalle/infinispan-server-domain
```

To access the admin console, first obtain the master IP:
```
docker inspect --format '{{ .NetworkSettings.IPAddress }}' master
```
and then go to 

```
http://master:9990
```

Credentials are admin/admin 

### MacOS users only


To be able to reach the containers by their IP directly, the following route can be added: 

```
sudo route -n add 172.17.0.0./16 `docker-machine ip default`

``` 

