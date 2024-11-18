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
snmpwalk -v2c -c public snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public -On snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public -Of snmpd .1.3.6.1.2.1.1
snmpwalk -v2c -c public 192.168.0.1 1.3.6.1.2.1.1
```
