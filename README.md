# Monitorización SNMP
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

snmpwalk -v2c -c public 192.168.0.1 1.3.6.1.2.1.1
```
## Limpieza
* Salimos del contenedor snmpcli con "exit". El contenedor será destruido.
* Paramos el contenedor snmpd con "docker stop snmpd". El contenedor será destruido.
* Eliminamos la red con "docker network rm snmp-net"

Podemos comprobar que la limpieza ha funcionado con "docker ps -a" y "docker network ls". 
