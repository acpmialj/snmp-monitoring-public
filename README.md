# Monitorización SNMP y Zabbix
## Creación de imagen con snmp-net, basada en alpine
* Dockerfile
* Requiere snmpd.conf (la configuración del agente SNMP)
Se construye con
```
docker build -f ./Dockerfile -t snmpdalp .
```
Creamos una red snmp-net
```
docker network create snmp-net
```
Se ejecuta un contenedor objeto de monitorización con 
```
docker run --rm -d --network snmp-net --name snmpd snmpdalp
````
## Monitorización desde otro contenedor
Creamos un nuevo contenedor, que hará de "maganer", y en el mismo ejecutamos un shell:
```
docker run --rm -it --name snmpcli --network snmp-net snmpdalp sh
```
Desde ese shell del contenedor-manager, ejecutamos comandos para acceder a variables SNMP en el contenedor observado:
```
snmpget -v2c -c public snmpd .1.3.6.1.2.1.1.5.0
snmpget -v2c -c public snmpd SNMPv2-MIB::sysContact.0
snmpget -v2c -c public -Of snmpd .1.3.6.1.2.1.1.5.0
snmpget -v2c -c public -On snmpd .1.3.6.1.2.1.1.5.0

snmpwalk -v2c -c public snmpd .1.3.6.1.2.1.1
```

## Monitorización de un router SNMP
Suponemos que su dirección IP es 192.168.0.1, y que tiene SNMP activado. 
```
snmpget -v2c -c public 192.168.0.1 .1.3.6.1.2.1.1.5.0
snmpwalk -v2c -c public 192.168.0.1 1.3.6.1.2.1.1

```
## Limpieza
* Salimos del contenedor snmpcli con "exit". El contenedor será destruido.
* Paramos el contenedor snmpd con "docker stop snmpd". El contenedor será destruido.
* Eliminamos la red con "docker network rm snmp-net"

Podemos comprobar que la limpieza ha funcionado con "docker ps -a" y "docker network ls". 

## Lanzamiendo del servidor Zabbix
```
docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net
docker run --name mysql-server -t \
             -e MYSQL_DATABASE="zabbix" \
             -e MYSQL_USER="zabbix" \
             -e MYSQL_PASSWORD="zabbix_pwd" \
             -e MYSQL_ROOT_PASSWORD="root_pwd" \
             --network=zabbix-net \
             --restart unless-stopped \
             -d mysql:8.0-oracle \
             --character-set-server=utf8 --collation-server=utf8_bin \
             --default-authentication-plugin=mysql_native_password

docker run --name zabbix-server-mysql -t \
             -e DB_SERVER_HOST="mysql-server" \
             -e MYSQL_DATABASE="zabbix" \
             -e MYSQL_USER="zabbix" \
             -e MYSQL_PASSWORD="zabbix_pwd" \
             -e MYSQL_ROOT_PASSWORD="root_pwd" \
             --network=zabbix-net \
             -p 10051:10051 \
             --restart unless-stopped \
             -d zabbix/zabbix-server-mysql:alpine-7.0-latest

docker run --name zabbix-web-nginx-mysql -t \
             -e ZBX_SERVER_HOST="zabbix-server-mysql" \
             -e DB_SERVER_HOST="mysql-server" \
             -e MYSQL_DATABASE="zabbix" \
             -e MYSQL_USER="zabbix" \
             -e MYSQL_PASSWORD="zabbix_pwd" \
             -e MYSQL_ROOT_PASSWORD="root_pwd" \
             --network=zabbix-net \
             -p 8888:8080 \
             --restart unless-stopped \
             -d zabbix/zabbix-web-nginx-mysql:alpine-7.0-latest
```

## Lanzamiento de un host con un agente Zabbix
```
docker run --rm --name zagent2 --network zabbix-net \
        -e ZBX_HOSTNAME="zagent2" \
        -e ZBX_SERVER_HOST="zabbix-server-mysql" \
        --init -d zabbix/zabbix-agent2:alpine-7.0-latest
```

## Lanzamiento de un host con un agente SNMP
```
docker run --rm -d --name snmpd -p 161:161/udp --network zabbix-net snmpdalp
```

## Limpieza
Con estos comandos eliminamos contenedores y red:

```
docker stop mysql-server zabbix-server-mysql zabbix-web-nginx-mysql
docker rm mysql-server zabbix-server-mysql zabbix-web-nginx-mysql
docker stop zagent2
docker stop snmpd
docker network rm zabbix-net
```
Sin embargo, quedan creados una serie de volúmenes usados por Zabbix. Podemos borrarlos manualmente, o hacerlo de forma rápida (y peligrosa):
```
docker volume prune -a
```

